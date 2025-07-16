
module Archivum::Command::Attachment::CreateFromFileHandle
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id, name, page, handle)
		att_repo = context.call(RepositoryFactory, Archivum::Model::Attachment)
		doc_repo = context.call(RepositoryFactory, Archivum::Model::Document)
		document = doc_repo.read(Archivum::Model::Document.new(doc_id, nil, nil, nil, nil, nil))
		throw "document with id #{doc_id} does not exist!" if not document
		attachments = context.call(GetAttachmentsForDocument, doc_id)
		attachment = Archivum::Logic.create_new_attachment(document, attachments, name, page)
		att_repo.insert(attachment)
		data = handle.read()
		archive.call(WriteAttachmentData, doc_id, name, data)
	end
end