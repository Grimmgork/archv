require_relative 'domain.rb'

module AttachmentManager
	def get_attachment_by_id(id)
		repo = get_repo(Attachment)
		attachment = repo.get_by_id(id)
		return attachment
	end

	def get_attachments_for_document(doc_id)
		repo = get_repo(Attachment)
		attachments = repo.where("doc_id=?", doc_id)
		return attachments
	end

	def attach_attachment_to_document(id, doc_id)
		start_transaction()
		repo = get_repo(Attachment)
		attachment = repo.get_by_id(id)
		attachment.doc_id = doc_id
		repo.update(attachment)
		end_transaction()
	end

	def get_attachment_where(query, *args)
		repo = get_repo(Attachment)
		attachments = repo.get_where(query, args)
		return attachment
	end

	def delete_attachment(id)
		repo = get_repo(Attachment)
		repo.delete(id)
	end

	def create_attachment(name, data: nil, page: 0, doc_id: 0)
		start_transaction()
		repo = get_repo(Attachment)
		id = repo.create()
		attachment = repo.get_by_id(id)
		attachment.name = name
		attachment.data = data

		if data
			attachment.sz = data.length
		else
			attachment.sz = 0
		end

		attachment.page = page
		attachment.doc_id = doc_id
		repo.update(attachment, :data)
		end_transaction()
		return id
	end

	def update_attachment(attachment)
		start_transaction()
		repo = get_repo(Attachment)
		repo.update(attachment)
		end_transaction()
	end

	def rename_attachment(id, name)
		repo = get_repo(Attachment)
		attachment = repo.get_by_id(id)
		attachment.name = name
		repo.update(attachment)
	end

	def write_attachment_data(id, blob)
		start_transaction()	
		repo = get_repo(Attachment)
		attachment = repo.get_by_id(id)
		attachment.sz = blob.length
		attachment.data = blob
		repo.update(attachment, :data)
		end_transaction()	
	end

	def read_attachment_data(id)
		repo = get_repo(Attachment)
		attachment = repo.get_by_id(id)
		repo.load_property(attachment, :data)
		return attachment.data
	end
end

module DocumentManager
	def create_document(title)
		start_transaction()
		timestamp = Time.now.to_i
		repo = get_repo(Document)
		id = repo.create()
		document = repo.get_by_id(id)
		document.title = title
		document.timestamp = timestamp
		document.location = "new"
		document.last_moved = timestamp
		document.taken = 0
		repo.update(document)
		end_transaction()
		return id
	end

	def delete_document(id)
		start_transaction()
		repo = get_repo(Document)
		repo.delete(id)
		end_transaction()
	end

	def update_document(document)
		start_transaction()
		repo = get_repo(Document)
		repo.update(document)
		end_transaction()
	end

	def get_document_where(query, *args)
		start_transaction()
		repo = get_repo(Document)
		documents = repo.where(query, args)
		end_transaction()
		return documents
	end

	def move_document(id, location)
		start_transaction()
		repo = get_repo(Document)
		document = repo.get_by_id(id)
		document.location = location
		document.last_moved = Time.now.to_i
		repo.update(document)
		end_transaction()
	end
end

class Archive

	include AttachmentManager
	include DocumentManager

	def initialize(path)
		@db = SQLite3::Database.open path
		@db.results_as_hash = true
	end

	def start_transaction()
		@db.execute("BEGIN TRANSACTION;")
	end

	def end_transaction(rollback=false)
		if rollback
			@db.execute("ROLLBACK;")
		else 
			@db.execute("COMMIT;")
		end
	end

	def get_repo(type)
		return SQLiteRepository.new(@db, type)
	end

	def close()
		@db.close() if @db
		@db = nil
	end
end
