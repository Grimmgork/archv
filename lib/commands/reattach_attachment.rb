require_relative "../domain/logic.rb"

module ReattachAttachment
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
		attachment = Logic.reattach_attachment(attachment, to_document, attachments)

		att_repo.update(attachment)
	end
end