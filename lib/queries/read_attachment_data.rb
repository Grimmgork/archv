module ReadAttachmentData
	module_function

	def call(context, doc_id, name, handle = nil)
		repo = context.call(RepositoryFactory, Attachment)
		attachment = repo.read(Attachment.new(name, doc_id, nil, nil, nil))
		throw "attachment with name #{name} does not exist for document with id #{doc_id}" if not attachment
		
		data = nil
		query = "SELECT data FROM sqlar WHERE name=? LIMIT 1;"
		context.data.first(query, "/#{doc_id}/#{name}") do |row|
			data = row[0]
		end

		if handle
			handle.write(data)
		else
			data
		end
	end
end