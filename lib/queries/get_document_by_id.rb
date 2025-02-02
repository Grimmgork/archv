module GetDocumentById
	module_function

	def call(context, id)
		repo = context.call(RepositoryFactory, Document)
		return repo.read(Document.new(id, nil, nil, nil, nil, nil))
	end
end