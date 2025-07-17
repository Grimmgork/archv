
module Archivum::Command::Attachment::CreateFromFileHandle
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id, name, page, handle)
		att_repo = context.call(Archivum::Command::RepositoryFactory, Archivum::Model::Attachment)
		doc_repo = context.call(Archivum::Command::RepositoryFactory, Archivum::Model::Document)
		document = doc_repo.read(Archivum::Model::Document.new(doc_id, nil, nil, nil, nil, nil))
		raise "document with id #{doc_id} does not exist!" if not document
		attachments = context.call(Archivum::Query::Document::Attachments, doc_id)
		attachment = Archivum::Logic.create_new_attachment(document, attachments, name, page, Time.now.to_i)
		att_repo.insert(attachment)
		data = handle.read()
		context.call(Archivum::Command::Attachment::WriteData, doc_id, name, data)
	end
end