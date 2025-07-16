require_relative "../../domain/logic.rb"

module Archivum::Command::Document::TryTake
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id)
		repo = context.call(RepositoryFactory, Archivum::Model::Document)
		document = repo.read(Archivum::Model::Document.new(doc_id, nil, nil, nil, nil, nil))
		throw "document with id #{doc_id} does not exist!" if not document
		document = Archivum::Logic.try_take_document(document)
		return false if not document
		repo.update(document)
		return true
	end
end