require_relative "../domain/logic.rb"

module CreateNewAttachment
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
		attachment = Logic.create_new_attachment(document, attachments, name, page)
		att_repo.insert(attachment)
	end
end