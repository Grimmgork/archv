module Archivum::Query::Document::ById
	module_function

	def call(context, id)
		repo = context.call(Archivum::Command::RepositoryFactory, Archivum::Model::Document)
		return repo.read(Archivum::Model::Document.new(id, nil, nil, nil, nil, nil))
	end
end