require_relative "../domain/logic.rb"

module FreeDocument
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id)
		repo = context.call(RepositoryFactory, Document)
		document = repo.read(Document.new(doc_id, nil, nil, nil, nil, nil))
		throw "document with id #{doc_id} does not exist!" if not document
		document = Logic.free_document(document)
		repo.update(document)
	end
end