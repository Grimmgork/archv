require_relative "../domain/models.rb"

AttachmentQueryMatch = Data.define(:document_id, :document_title, :page, :name)

class Query
	include Injector
end

class AttachmentsForDocument < Query
	inject(:context)

	def initialize(doc_id)
		@doc_id = doc_id
	end

	def call()
		attachments = @context.execute("SELECT name, page, sz, mtime, doc_id FROM sqlar WHERE doc_id=?", @doc_id) do |row|
			Attachment.new(*row)
		end
		return attachments
	end
end

class ReadAttachmentData < Query
	inject(:context)

	def initialize(doc_id, name)

	end

	def call()

	end
end

class GetAttachmentById < Query
	inject(:context)

	def initialize(doc_id, name)

	end

	def call()

	end
end

class KeywordSearch < Query
	inject(:context)

	def initialize(keyword)

	end

	def call()

	end
end

class GetDocumentsByLocation < Query
	inject(:context)

	def initialize(location)

	end

	def call()

	end
end

class GetAttachmentsForDocument < Query
	inject(:context)

	def initialize(keyword)

	end

	def call()

	end
end

class ReadAttachmentData < Query
	inject(:context)

	def initialize(doc_id, name)

	end

	def call()

	end
end