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
		transaction() do
			repo = get_repo(Attachment)
			attachment = repo.get_by_id(id)
			attachment.doc_id = doc_id
			repo.update(attachment)
		end
	end

	def get_attachment_where(query, *args)
		repo = get_repo(Attachment)
		attachments = repo.where(query, args)
		return attachments
	end

	def delete_attachment(id)
		repo = get_repo(Attachment)
		repo.delete(id)
	end

	def create_attachment(name, data: nil, page: 0, doc_id: 0)
		raise "name cannot be empty!" if not name
		raise "page cannot be negative!" if page < 0
		transaction() do
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
			id
		end
	end

	def update_attachment(update)
		transaction() do
			repo = get_repo(Attachment)
			attachment = repo.get_by_id(update.id)
			raise "name cannot be empty!" if update.name == nil or update.name == ""
			attachment.name = update.name
			raise "page cannot be negative!" if update.page < 0
			attachment.page = update.page
			repo.update(attachment)
		end
	end

	def rename_attachment(id, name)
		repo = get_repo(Attachment)
		attachment = repo.get_by_id(id)
		attachment.name = name
		repo.update(attachment)
	end

	def write_attachment_data(id, blob)
		transaction() do
			repo = get_repo(Attachment)
			attachment = repo.get_by_id(id)
			attachment.sz = blob.length
			attachment.data = blob
			repo.update(attachment, :data)
		end
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
		transaction() do
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
			id
		end
	end

	def delete_document(id)
		transaction() do
			repo = get_repo(Document)
			repo.delete(id)
		end
	end

	def update_document(update)
		transaction() do
			repo = get_repo(Document)
			document = repo.get_by_id(update.id)
			document.title = update.title
			repo.update(document)
		end
	end

	def get_document_where(query, *args)
		transaction() do
			repo = get_repo(Document)
			documents = repo.where(query, args)
			documents
		end
	end

	def move_document(id, location)
		transaction() do
			repo = get_repo(Document)
			document = repo.get_by_id(id)
			document.location = location
			document.last_moved = Time.now.to_i
			repo.update(document)
		end
	end
end

class Archive

	include AttachmentManager
	include DocumentManager

	def initialize(path)
		@db = SQLite3::Database.open path
		@db.results_as_hash = true
	end

	def transaction()
		@db.execute("BEGIN TRANSACTION;")
		begin 
			result = yield()
		rescue
			@db.execute("ROLLBACK;")
			raise
		end
		@db.execute("COMMIT;")
		return result
	end

	def get_repo(type)
		return SQLiteRepository.new(@db, type)
	end

	def close()
		@db.close() if @db
		@db = nil
	end
end