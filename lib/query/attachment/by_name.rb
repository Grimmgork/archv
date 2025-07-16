module Archivum::Query::Attachment::ByName
	module_function

	def call(context, doc_id, name)
		repo = context.call(RepositoryFactory, Attachment)
		return repo.read(Attachment.new(name, doc_id, nil, nil, nil))
	end
end