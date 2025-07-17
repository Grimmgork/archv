
module Archivum::Command::Attachment::Create
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id, name, page)
		doc_repo = context.call(Archivum::Command::RepositoryFactory, Archivum::Model::Document)
		att_repo = context.call(Archivum::Command::RepositoryFactory, Archivum::Model::Attachment)

		document = doc_repo.read(Archivum::Model::Document.new(doc_id, nil, nil, nil, nil, nil))
		throw "document with id #{doc_id} does not exists!" if not document

		attachments = context.call(Archivum::Query::Document::Attachments, doc_id)
		attachment = Archivum::Logic.create_new_attachment(document, attachments, name, page, Time.now.to_i)
		att_repo.insert(attachment)
	end
end