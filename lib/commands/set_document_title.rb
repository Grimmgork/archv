require_relative "../domain/logic.rb"

module SetDocumentTitle
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id, title)
		repo = context.call(RepositoryFactory, Document)
		document = repo.read(Document.new(doc_id, nil, nil, nil, nil, nil))
		throw "not implemented!"
	end
end