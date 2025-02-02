require_relative "../domain/logic.rb"

module MoveDocument
	module_function

	def transaction 
		:immediate
	end

	def call(context, doc_id, location)
		repo = context.call(RepositoryFactory, Document)
		document = repo.read(Document.new(doc_id, nil, nil, nil, nil, nil))
		throw "document with id #{doc_id} does not exist!" if not document
		document = Logic.move_document(document, location)
		repo.update(document)
	end
end