require_relative "../domain/logic.rb"

module CreateAttachmentFromFileHandle
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
		attachment = Logic.create_new_attachment(document, attachments, name, page)
		att_repo.insert(attachment)
		data = handle.read()
		archive.call(WriteAttachmentData, doc_id, name, data)
	end
end