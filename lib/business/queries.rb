
AttachmentQueryMatch = Data.define(:document_id, :document_title, :page, :name)

module GetAttachmentsForDocument
	module_function

	def call(context, doc_id, *filenames)
		statements = []
		args = []
		filenames.each do |like| 
			statements << "name LIKE '/' || ? || '/' || ?"
			args << doc_id
			args << like
		end

		if filenames.length == 0
			statements << "name LIKE '/' || ? || '/%'"
			args << doc_id
		end
		
		context.data.execute("SELECT name, page, sz, mtime, doc_id FROM sqlar WHERE #{statements.join(" OR ")};", *args) do |row|
			doc_id, name = row[0].split("/").reject { |s| s.nil? || s.empty? }
			Attachment.new(name, doc_id, row[1], row[2], row[3])
		end
	end
end

module ReadAttachmentData
	module_function

	def call(context, doc_id, name)
		name = "/#{doc_id}/#{name}"
		context.data.first("SELECT data FROM sqlar WHERE name=?;", name) do |row|
			row[0]
		end
	end
end

module GetAttachmentByName
	module_function

	def call(context, doc_id, name)
		repo = context.get_repo(Attachment)
		return repo.read(Attachment.new(name, doc_id, nil, nil, nil))
	end
end

module KeywordSearch
	module_function

	def call(context)
		throw "not implemented!"
	end
end

module GetDocumentById
	module_function

	def call(context, id)
		repo = context.call(RepositoryFactory, Document)
		return repo.read(Document.new(id, nil, nil, nil, nil, nil))
	end
end

module GetUntakenDocumentsByLocation
	module_function

	def call(context, location)
		context.data.execute("SELECT id, title, timestamp, location, last_moved, taken FROM document WHERE location=? AND taken=0", location) do |row|
			Document.new(*row)
		end
	end
end