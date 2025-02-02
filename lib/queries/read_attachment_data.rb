module ReadAttachmentData
	module_function

	def call(context, doc_id, name)
		repo = context.call(RepositoryFactory, Attachment)
		attachment = repo.read(Attachment.new(name, doc_id, nil, nil, nil))
		context.data.first("SELECT data FROM sqlar WHERE name=?;", name) do |row|
			row[0]
		end
	end

	def call(context, doc_id, name, handle = nil)
		repo = context.call(RepositoryFactory, Attachment)
		attachment = repo.read(Attachment.new(name, doc_id, nil, nil, nil))
		throw "attachment with name #{name} does not exist for document with id #{doc_id}" if not attachment
		
		data = nil
		context.data.first("SELECT data FROM sqlar WHERE name=? LIMIT 1;", name) do |row|
			data = row[0]
		end

		if handle
			handle.write(data)
		else
			data
		end
	end
end