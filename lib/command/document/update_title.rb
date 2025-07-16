require_relative "../../domain/logic.rb"

module Archivum::Command::Document::UpdateTitle
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id, title)
		repo = context.call(RepositoryFactory, Archivum::Model::Document)
		document = repo.read(Archivum::Model::Document.new(doc_id, nil, nil, nil, nil, nil))
		throw "not implemented!"
	end
end