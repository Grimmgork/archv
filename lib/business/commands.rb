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
		document = repo.read(Document.new(@doc_id, nil, nil, nil, nil, nil))
		throw "document with id #{@doc_id} does not exist!" if not document
		document = move_document(document, @location)
		repo.update(document)
	end
end

class SetDocumentTitle < Command
	inject(:context)

	def initialize(doc_id, title)
		@doc_id = doc_id
		@title = title
	end

	def call()
		repo = @context.get_repo(Document)
		document = repo.read(Document.new(@doc_id, nil, nil, nil, nil, nil))
		throw "not implemented!"
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

	def initialize(doc_id, name, page, data=nil)
		@doc_id = doc_id
		@name = name
		@page = page
		@data = data
	end

	def call()
		doc_repo = @context.get_repo(Document)
		att_repo = @context.get_repo(Attachment)

		document = doc_repo.read(Document.new(@doc_id, nil, nil, nil, nil, nil))
		throw "document with id #{@doc_id} does not exists!" if not document

		attachments = @archive.call(AttachmentsForDocument, @doc_id)
		attachment = create_new_attachment(document, attachments, @name, @page)
		att_repo.insert(attachment)
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

		attachment = att_repo.read(Attachment.new(@att_name, @doc_id, nil, nil, nil))
		throw "attachment with name #{@att_name} does not exist for document with id #{@doc_id}" if not attachment
		
		attachments = @archive.call(AttachmentsForDocument, @doc_id)
		attachment = reattach_attachment(attachment, to_document, attachments)

		att_repo.update(attachment)
	end
end

class WriteFileFromAttachment < Command
	inject(:context)
	inject(:archive)

	def initialize(doc_id, name, handle)
		@doc_id = doc_id
		@name = name
		@handle = handle
	end

	def call()
		repo = @context.get_repo(Attachment)
		attachment = repo.read(Attachment.new(@name, @doc_id, nil, nil, nil))
		throw "attachment with name #{@name} does not exist for document with id #{@doc_id}" if not attachment
		data = @archive.call(ReadAttachmentData, @doc_id, @name)
		@handle.write(data)
	end
end

class CreateAttachmentFromFile < Command
	inject(:context)
	inject(:archive)

	def initialize(doc_id, name, page, handle)
		@doc_id = doc_id
		@name = name
		@handle = handle
		@page = page
	end

	def call()
		att_repo = @context.get_repo(Attachment)
		doc_repo = @context.get_repo(Document)
		document = doc_repo.read(Document.new(@doc_id, nil, nil, nil, nil, nil))
		throw "document with id #{@doc_id} does not exist!" if not document
		attachments = @archive.call(GetAttachmentsForDocument, @doc_id)
		attachment = create_new_attachment(document, attachments, @name, @page)
		att_repo.insert(attachment)
		data = @handle.read()
		@archive.call(WriteAttachmentData, @doc_id, @name, data)
	end
end

class TryTakeDocument < Command
	inject(:context)
	transaction(:immediate)

	def initialize(doc_id, timeout=nil)
		@doc_id = doc_id
	end

	def call()
		repo = @context.get_repo(Document)
		document = repo.read(Document.new(@doc_id, nil, nil, nil, nil, nil))
		throw "document with id #{@doc_id} does not exist!" if not document
		document = try_take_document(document)
		return false if not document
		repo.update(document)
		return true
	end
end

class FreeDocument < Command
	inject(:context)

	def initialize(doc_id)
		@doc_id = doc_id
	end

	def call()
		repo = @context.get_repo(Document)
		document = repo.read(Document.new(@doc_id, nil, nil, nil, nil, nil))
		throw "document with id #{@doc_id} does not exist!" if not document
		document = free_document(document)
		repo.update(document)
	end
end

class WriteAttachmentData < Command
	inject(:context)

	def initialize(doc_id, name, data)
		@doc_id = doc_id
		@name = name
		@data = data
	end

	def call()
		repo = @context.get_repo(Attachment)
		attachment = repo.read(Attachment.new(@name, @doc_id, nil, nil, nil))
		throw "attachment with name #{@name} does not exist for document with id #{@doc_id}!" if not attachment
		name = "/#{@doc_id}/#{@name}"
		@context.execute("UPDATE sqlar SET data=?, sz=? WHERE name=?;", @data, @data.length, name)
	end
end

class DeleteAttachment < Command
	inject(:context)

	def initialize(doc_id, name)
		@doc_id = doc_id
		@name = name
	end

	def call()
		repo = @context.get_repo(Attachment)
		repo.delete(Attachment.new(@doc_id, @name, nil, nil, nil))
	end
end
