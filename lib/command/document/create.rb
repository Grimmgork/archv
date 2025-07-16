require_relative "../../domain/logic.rb"

module Archivum::Command::Document::Create
	module_function

	def transaction
		:immediate
	end

	def call(context, title, location)
		repo = context.call(RepositoryFactory, Archivum::Model::Document)
		document = Archivum::Logic.create_new_document(title, location || "new")
		repo.insert(document)
	end
end