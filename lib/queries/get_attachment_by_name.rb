module GetAttachmentByName
	module_function

	def call(context, doc_id, name)
		repo = context.get_repo(Attachment)
		return repo.read(Attachment.new(name, doc_id, nil, nil, nil))
	end
end