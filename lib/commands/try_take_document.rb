require_relative "../domain/logic.rb"

module TryTakeDocument
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id)
		repo = context.call(RepositoryFactory, Document)
		document = repo.read(Document.new(doc_id, nil, nil, nil, nil, nil))
		throw "document with id #{doc_id} does not exist!" if not document
		document = Logic.try_take_document(document)
		return false if not document
		repo.update(document)
		return true
	end
end