require_relative "../lib/archive.rb"
require 'tempfile'

class WorkerContext
	def initialize(archive, document, attachments)
		@archive = archive
		@document = document
		@attachments = attachments
		@actions = []
		@tempfiles = []
		@ensures = []
	end

	def ensure(&block)
		@ensures << block 
	end

	def document
		@document
	end

	def attachments
		@attachments
	end

	def read_attachment_data(name, handle = nil)
		@archive.call(Archivum::Query::Attachment::ReadData, @document.id, name, handle)
	end

	def delete_attachment(name)
		@actions << DeleteAttachmentAction.new(@document.id, name)
	end

	def create_attachment(name, page, path)
		@actions << CreateAttachmentAction.new(@document.id, name, page, path)
	end

	def create_tempfile(extension: nil, binmode: false, &block)
		file = Tempfile.new(['', ".#{extension || "tmp"}" ], binmode: binmode)
		@tempfiles << file
		begin
			block.call(file) if block_given?
		ensure
			file.close
		end
		return file.path
	end

	def actions
		@actions
	end

	def tempfiles
		@tempfiles
	end

	def ensures
		@ensures
	end
end

class DeleteAttachmentAction
	def initialize(document_id, name)
		@document_id = document_id
		@name = name
	end

	def execute(archive)
		archive.call(Archivum::Command::Attachment::Delete, @document_id, @name)
	end
end

class CreateAttachmentAction
	def initialize(document_id, name, page, path)
		@document_id = document_id
		@name = name
		@page = page
		@path = path
	end

	def execute(archive)
		fh = File.new(@path, "rb")
		begin
			archive.call(Archivum::Command::Attachment::CreateFromFileHandle, @document_id, @name, @page, fh)
		ensure 
			fh.close
		end
	end
end

class Worker
	def initialize(location, filenames, &block)
		@work = block
		@location = location
		@filenames = filenames
	end

	def run(archive)
		return unless @work
		return unless @location

		documents = archive.call(Archivum::Query::Document::UntakenByLocation, @location)
		documents = documents.sort_by { |doc| doc.last_moved } # least recently moved document first
		
		return unless documents.any?
		document = documents.first

		puts "kek"

		return unless archive.call(Archivum::Command::Document::TryTake, document.id)

		# TODO read the document again to prevent changes before locking
		
		attachments = archive.call(Archivum::Query::Document::Attachments, document.id, *@filenames)
		context = WorkerContext.new(archive, document, attachments)
		begin
			next_location = @work.call(context)
			archive.transaction do 
				# move to new location
				archive.call(Archivum::Command::Document::Move, document.id, next_location || @location)

				# apply calculated changes
				context.actions.each do |action|
					puts action
					action.execute(archive)
				end
			end
			puts "#{@location} DONE: #{document.id} -> #{next_location}"
		rescue => error
			archive.call(Archivum::Command::Document::Move, document.id, "error")
			puts "#{@location} ERROR: #{error}"
		end

		context.ensures.each do |block|
			begin 
				block.call
			rescue => error
				puts error
			end
		end
		
		archive.call(Archivum::Command::Document::Free, document.id)
		# maybe a retry here?

		# dispose tempfiles
		context.tempfiles.each do |file|
			file.close
			file.unlink
		end
	end
end