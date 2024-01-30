require_relative 'domain.rb'

class Archive
	def initialize(path)
		@path = path
	end

	def get_repo(type)
		return SQLiteRepository.new(@path, type)
	end
end

class AttachmentManager
	def initialize(context)
		@context = context
	end

	def get_by_id(id)
		repo = @context.get_repo(Attachment)
		attachment = repo.get_by_id(id)
		repo.close()
		return attachment
	end

	def get_for_document(doc_id)
		repo = @context.get_repo(Attachment)
		attachments = repo.where("doc_id=?", doc_id)
		repo.close()
		return attachments
	end

	def attach_to_document(id, doc_id)
		repo = @context.get_repo(Attachment)
		attachment = repo.get_by_id(id)
		attachment.doc_id = doc_id
		repo.update(attachment)
		repo.close()
	end

	def get_where(query, *args)
		repo = @context.get_repo(Attachment)
		attachments = repo.get_where(query, args)
		repo.close()
		return attachment
	end

	def delete(id)
		repo = @context.get_repo(Attachment)
		repo.delete(id)
	end

	def create(name, data: nil, page: 0, doc_id: 0)
		repo = @context.get_repo(Attachment)
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
		repo.close()
		return id
	end

	def update(attachment)
		repo = @context.get_repo(Attachment)
		repo.update(attachment)
		repo.close()
	end

	def rename(id, name)
		repo = @context.get_repo(Attachment)
		attachment = repo.get_by_id(id)
		attachment.name = name
		repo.update(attachment)
		repo.close()
	end

	def write_data(id, blob)
		repo = @context.get_repo(Attachment)
		attachment = repo.get_by_id(id)
		attachment.sz = blob.length
		attachment.data = blob
		repo.update(attachment, :data)
		repo.close()
	end

	def read_data(id)
		repo = @context.get_repo(Attachment)
		attachment = repo.get_by_id(id)
		repo.load_property(attachment, :data)
		repo.close()
		return attachment.data
	end
end

class DocumentManager
	def initialize(context)
		@context = context
	end

	def create(title)
		timestamp = Time.now.to_i
		repo = @context.get_repo(Document)
		id = repo.create()
		document = repo.get_by_id(id)
		document.title = title
		document.timestamp = timestamp
		document.location = "new"
		document.last_moved = timestamp
		document.taken = 0
		repo.update(document)
		repo.close()
		return id
	end

	def delete(id)
		repo = @context.get_repo(Document)
		repo.delete(id)
		repo.close()
	end

	def update(document)
		repo = @context.get_repo(Document)
		repo.update(document)
		repo.close()
	end

	def get_where(query, *args)
		repo = @context.get_repo(Document)
		documents = repo.where(query, args)
		repo.close()
		return documents
	end

	def move(id, location)
		repo = @context.get_repo(Document)
		document = repo.get_by_id(id)
		document.location = location
		document.last_moved = Time.now.to_i
		repo.update(document)
		repo.close()
	end
end

context = Archive.new("data.db")
attachments = AttachmentManager.new(context)
puts attachments.get_by_id(1).to_h
