module Archivum::Query::Attachment::ByName
	module_function

	def call(context, doc_id, name)
		repo = context.repository(Archivum::Model::Attachment)
		return repo.read(Archivum::Model::Attachment.new(name, doc_id, nil, nil, nil))
	end
end