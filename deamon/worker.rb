require_relative "../lib/archive.rb"

class WorkContext
	def initialize(archive, document, attachments)
		@archive = archive
		@document = document
		@attachments = attachments
	end

	def archive
		@archive
	end

	def document
		@document
	end

	def attachments
		@attachments
	end
end

class Worker
	def initialize(location, filenames, &block)
		@work = block
		@location = location
		@filenames = filenames
	end

	def run(archive)
		return if not @work
		return if not @location

		documents = archive.call(GetUntakenDocumentsByLocation, @location)
		documents = documents.sort_by { |doc| doc.last_moved } # least recently moved document first
		
		return if documents.length <= 0
		document = documents[0]

		if not archive.call(TryTakeDocument, document.id)
			return
		end

		attachments = archive.call(GetAttachmentsForDocument, document.id, *@filenames)

		begin
			next_location = archive.transaction() do 
				@work.call(archive, document, attachments)
			end
			archive.call(MoveDocument, document.id, next_location || @location)
			puts "#{@location} DONE: #{document.id} -> #{next_location}"
		rescue => error
			puts "#{@location} ERROR: #{error}"
			archive.call(MoveDocument, document.id, "error")
		end
		
		archive.call(FreeDocument, document.id)
	end
end