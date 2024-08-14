
module RepositoryFactory
	module_function

	def call(context, type)
		if type == Attachment
			to_row = Proc.new do |obj|
				[ "/#{obj.doc_id}/#{obj.name}", obj.page, obj.size, obj.mtime ]
			end
			from_row = Proc.new do |row|
				doc_id, name = row[0].split("/").reject { |s| s.nil? || s.empty? }
				Attachment.new(name, doc_id, row[1], row[2], row[3])
			end
			return Repository.new(context.data, "sqlar", [ "name", "page", "sz", "mtime" ], false, from_row, to_row)
		end

		if type == Document
			to_row = Proc.new do |obj|
				[ obj.id, obj.title, obj.timestamp, obj.location, obj.last_moved, obj.taken ]
			end
			from_row = Proc.new do |row|
				Document.new(row[0], row[1], row[2], row[3], row[4], row[5])
			end
			return Repository.new(context.data, "document", [ "id", "title", "timestamp", "location", "last_moved", "taken" ], true, from_row, to_row)
		end

		throw "No repository defined for type #{type}!"
	end
end

module RenameAttachment
	extend DomainLogic
	module_function

	def transaction 
		:immediate
	end

	def call(context, doc_id, from, to)
		attachments = context.call(AttachmentsForDocument, doc_id)
		repo = context.call(RepositoryFactory, Attachment)
		attachment = rename_attachment(attachments, from, to)
		repo.update(attachment)
	end
end

module MoveDocument
	extend DomainLogic
	module_function

	def transaction 
		:immediate
	end

	def call(context, doc_id, location)
		repo = context.call(RepositoryFactory, Document)
		document = repo.read(Document.new(doc_id, nil, nil, nil, nil, nil))
		throw "document with id #{doc_id} does not exist!" if not document
		document = move_document(document, location)
		repo.update(document)
	end
end

module SetDocumentTitle
	extend DomainLogic
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id, title)
		repo = context.call(RepositoryFactory, Document)
		document = repo.read(Document.new(doc_id, nil, nil, nil, nil, nil))
		throw "not implemented!"
	end
end

module CreateNewDocument
	extend DomainLogic
	module_function

	def transaction
		:immediate
	end

	def call(context, title, location)
		repo = context.call(RepositoryFactory, Document)
		attachment = create_new_document(title, location || "new")
		repo.insert(attachment)
	end
end

module CreateNewAttachment
	extend DomainLogic
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id, name, page, data=nil)
		doc_repo = context.call(RepositoryFactory, Document)
		att_repo = context.call(RepositoryFactory, Attachment)

		document = doc_repo.read(Document.new(doc_id, nil, nil, nil, nil, nil))
		throw "document with id #{doc_id} does not exists!" if not document

		attachments = context.call(GetAttachmentsForDocument, doc_id)
		attachment = create_new_attachment(document, attachments, name, page)
		att_repo.insert(attachment)
	end
end

module ReattachAttachment
	extend DomainLogic
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id, att_name, new_doc_id)
		doc_repo = context.call(RepositoryFactory, Document)
		att_repo = context.call(RepositoryFactory, Attachment)

		from_document = doc_repo.read(Document.new(doc_id))
		to_document = doc_repo.read(Document.new(new_doc_id))

		throw "document with id #{doc_id} does not exist!" if not from_document
		throw "document with id #{new_doc_id} does not exist!" if not to_document

		attachment = att_repo.read(Attachment.new(att_name, doc_id, nil, nil, nil))
		throw "attachment with name #{att_name} does not exist for document with id #{doc_id}" if not attachment
		
		attachments = context.call(AttachmentsForDocument, doc_id)
		attachment = reattach_attachment(attachment, to_document, attachments)

		att_repo.update(attachment)
	end
end

module WriteAttachmentDataToFileHandle
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id, name, handle)
		repo = context.call(RepositoryFactory, Attachment)
		attachment = repo.read(Attachment.new(name, doc_id, nil, nil, nil))
		throw "attachment with name #{name} does not exist for document with id #{doc_id}" if not attachment
		data = context.call(ReadAttachmentData, doc_id, name)
		handle.write(data)
	end
end

module CreateAttachmentFromFileHandle
	extend DomainLogic
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id, name, page, handle)
		att_repo = context.call(RepositoryFactory, Attachment)
		doc_repo = context.call(RepositoryFactory, Document)
		document = doc_repo.read(Document.new(doc_id, nil, nil, nil, nil, nil))
		throw "document with id #{doc_id} does not exist!" if not document
		attachments = context.call(GetAttachmentsForDocument, doc_id)
		attachment = create_new_attachment(document, attachments, name, page)
		att_repo.insert(attachment)
		data = handle.read()
		archive.call(WriteAttachmentData, doc_id, name, data)
	end
end

module TryTakeDocument
	extend DomainLogic
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id)
		repo = context.call(RepositoryFactory, Document)
		document = repo.read(Document.new(doc_id, nil, nil, nil, nil, nil))
		throw "document with id #{doc_id} does not exist!" if not document
		document = try_take_document(document)
		return false if not document
		repo.update(document)
		return true
	end
end

module FreeDocument
	extend DomainLogic
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id)
		repo = context.call(RepositoryFactory, Document)
		document = repo.read(Document.new(doc_id, nil, nil, nil, nil, nil))
		throw "document with id #{doc_id} does not exist!" if not document
		document = free_document(document)
		repo.update(document)
	end
end

module WriteAttachmentData
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id, name, data)
		repo = context.call(RepositoryFactory, Attachment)
		attachment = repo.read(Attachment.new(name, doc_id, nil, nil, nil))
		throw "attachment with name #{name} does not exist for document with id #{doc_id}!" if not attachment
		name = "/#{doc_id}/#{name}"
		context.data.execute("UPDATE sqlar SET data=?, sz=? WHERE name=?;", data, data.length, name)
	end
end

module DeleteAttachment
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id, name)
		repo = context.call(RepositoryFactory, Attachment)
		repo.delete(Attachment.new(name, doc_id, nil, nil, nil))
	end
end
