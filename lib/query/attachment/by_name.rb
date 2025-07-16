module Archivum::Query::Attachment::ByName
	module_function

	def call(context, doc_id, name)
		repo = context.call(Archivum::Command::RepositoryFactory, Archivum::Model::Attachment)
		return repo.read(Archivum::Model::Attachment.new(name, doc_id, nil, nil, nil))
	end
end