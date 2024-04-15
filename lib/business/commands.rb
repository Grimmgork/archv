require_relative "../domain/models.rb"
require_relative "../domain/logic.rb"
require_relative "queries.rb"
require_relative "injector.rb"

class Command
	include Injector
end

class RenameAttachment < Command
	inject(:context)
	inject(:archive)

	def initialize(doc_id, from, to)
		@doc_id = doc_id
		@from = from
		@to = to
	end

	def call()
		attachments = @archive.call(AttachmentsForDocument, @doc_id)
		repo = @context.get_repo(Attachment)
		attachment = rename_attachment(attachments, from, to)
		repo.update(attachment)
	end
end

class MoveDocument < Command
	inject(:context)

	def initialize(doc_id, location)
		@doc_id = doc_id
		@location = location
	end

	def call()
		repo = @context.get_repo(Document)
		document = repo.read(Document.new(@doc_id))
		document = move_document(document, @location)
		repo.update(document)
	end
end

class SetDocumentTitle < Command
	inject(:context)

	def initialize(doc_id, title)

	end

	def call()

	end
end

class CreateNewDocument < Command
	inject(:context)

	def initialize(title, location=nil)
		@title = title
		@location = location
	end

	def call()
		repo = @context.get_repo(Document)
		attachment = create_new_document(@title, @location || "new")
		repo.insert(attachment)
	end
end

class CreateNewAttachment < Command
	inject(:context)
	inject(:archive)

	def initialize(doc_id, name, page)
		@doc_id = doc_id
		@name = name
		@page = page
	end

	def call()
		doc_repo = @context.get_repo(Document)
		att_repo = @context.get_repo(Attachment)

		document = doc_repo.read(Document.new(@doc_id, nil, nil, nil, nil, nil))
		throw "document with id #{@doc_id} does not exists!" if not document

		attachments = @archive.call(AttachmentsForDocument, @doc_id)
		attachment = create_new_attachment(document, attachments, @name, @page)
		return att_repo.insert(attachment)
	end
end

class ReattachAttachment < Command
	inject(:context)
	inject(:archive)

	def initialize(doc_id, att_name, new_doc_id)
		@doc_id = doc_id
		@att_name = att_name
		@new_doc_id = new_doc_id
	end

	def call()
		doc_repo = @context.get_repo(Document)
		att_repo = @context.get_repo(Attachment)

		from_document = doc_repo.read(Document.new(@doc_id))
		to_document = doc_repo.read(Document.new(@new_doc_id))

		throw "document with id #{@doc_id} does not exist!" if not from_document
		throw "document with id #{@new_doc_id} does not exist!" if not to_document

		attachment = att_repo.read(Attachment.new(@doc_id, @att_name))
		throw "attachment with name #{@att_name} does not exist for document with id #{@doc_id}" if not attachment
		
		attachments = @archive.call(AttachmentsForDocument, @doc_id)
		attachment = reattach_attachment(attachment, to_document, attachments)

		att_repo.update(attachment)
	end
end

class WriteAttachmentDataToFile < Command
	inject(:content)

	def initialize(doc_id, name, filename)

	end

	def call()

	end
end

class CrateAttachmentFromFile < Command
	inject(:content)

	def initialize(doc_id, name, filename)

	end

	def call()

	end
end

class WriteAttachmentData < Command
	inject(:content)

	def initialize(doc_id, name, data)

	end

	def call()

	end
end

class DeleteAttachment < Command
	inject(:content)

	def initialize(doc_id, name)

	end

	def call()

	end
end
