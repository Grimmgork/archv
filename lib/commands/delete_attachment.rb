require_relative "../domain/logic.rb"

module DeleteAttachment
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id, name)
		repo = context.call(RepositoryFactory, Attachment)
		repo.delete(Attachment.new(name, doc_id, nil, nil, nil))
	end
end