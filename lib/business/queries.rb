require_relative "../domain/models.rb"
require_relative "injector.rb"

AttachmentQueryMatch = Data.define(:document_id, :document_title, :page, :name)

class GetAttachmentsForDocument
	include Injector
	inject(:context)

	def initialize(doc_id, *filenames)
		@doc_id = doc_id
		@filenames = filenames
	end

	def call()
		statements = []
		args = []
		@filenames.each do |like| 
			statements << "name LIKE '/' || ? || '/' || ?"
			args << @doc_id
			args << like
		end

		if @filenames.length == 0
			statements << "name LIKE '/' || ? || '/%'"
			args << @doc_id
		end
		
		attachments = @context.execute("SELECT name, page, sz, mtime, doc_id FROM sqlar WHERE #{statements.join(" OR ")};", *args) do |row|
			doc_id, name = row[0].split("/").reject { |s| s.nil? || s.empty? }
			Attachment.new(name, doc_id, row[1], row[2], row[3])
		end
		return attachments
	end
end

class ReadAttachmentData
	include Injector
	inject(:context)

	def initialize(doc_id, name)
		@doc_id = doc_id
		@name = name
	end

	def call()
		name = "/#{@doc_id}/#{@name}"
		@context.first("SELECT data FROM sqlar WHERE name=?;", name) do |row|
			row[0]
		end
	end
end

class GetAttachmentByName
	include Injector
	inject(:context)

	def initialize(doc_id, name)
		@doc_id = doc_id
		@name = name
	end

	def call()
		repo = @context.get_repo(Attachment)
		return repo.read(Attachment.new(@name, @doc_id, nil, nil, nil))
	end
end

class KeywordSearch
	include Injector
	inject(:context)

	def initialize(keyword)

	end

	def call()

	end
end

class GetDocumentById
	include Injector
	inject(:context)

	def initialize(id)
		@id = id
	end

	def call()
		repo = @context.get_repo(Document)
		return repo.read(Document.new(@id, nil, nil, nil, nil, nil))
	end
end

class GetUntakenDocumentsByLocation
	include Injector
	inject(:context)

	def initialize(location)
		@location = location
	end

	def call()
		@context.execute("SELECT id, title, timestamp, location, last_moved, taken FROM document WHERE location=? AND taken=0", @location) do |row|
			Document.new(*row)
		end
	end
end