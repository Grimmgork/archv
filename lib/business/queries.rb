require_relative "../domain/models.rb"
require_relative "injector.rb"

AttachmentQueryMatch = Data.define(:document_id, :document_title, :page, :name)

class Query
	include Injector
end

class GetAttachmentsForDocument < Query
	inject(:context)

	def initialize(doc_id, filename=nil)
		@doc_id = doc_id
		@filename = filename
	end

	def call()
		attachments = @context.execute("SELECT name, page, sz, mtime, doc_id FROM sqlar WHERE name LIKE '/' || ? || '/' || ?;", @doc_id, @filename || "%") do |row|
			Attachment.new(*row)
		end
		return attachments
	end
end

class ReadAttachmentData < Query
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

class GetAttachmentByName < Query
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

class KeywordSearch < Query
	inject(:context)

	def initialize(keyword)

	end

	def call()

	end
end

class GetDocumentById < Query
	inject(:context)

	def initialize(id)
		@id = id
	end

	def call()
		repo = @context.get_repo(Document)
		return repo.read(Document.new(@id, nil, nil, nil, nil, nil))
	end
end

class GetUntakenDocumentsByLocation < Query
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