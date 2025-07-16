
module Archivum::Command::Attachment::Create
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id, name, page)
		doc_repo = context.call(RepositoryFactory, Archivum::Model::Document)
		att_repo = context.call(RepositoryFactory, Archivum::Model::Attachment)

		document = doc_repo.read(Archivum::Model::Document.new(doc_id, nil, nil, nil, nil, nil))
		throw "document with id #{doc_id} does not exists!" if not document

		attachments = context.call(GetAttachmentsForDocument, doc_id)
		attachment = Archivum::Logic.create_new_attachment(document, attachments, name, page)
		att_repo.insert(attachment)
	end
end