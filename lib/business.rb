require_relative 'domain.rb'

module AttachmentManager
	def get_attachment_by_id(id)
		repo = get_repo(Attachment)
		attachment = repo.get_by_id(id)
		return attachment
	end

	def get_attachments_for_document(doc_id)
		repo = get_repo(Attachment)
		attachments = repo.where({ "where" => ["eq", ["prop", "doc_id"], doc_id] })
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

	def get_attachments_where(query)
		repo = get_repo(Attachment)
		attachments = repo.where(query)
		return attachments
	end

	def delete_attachment(id)
		repo = get_repo(Attachment)
		repo.delete(id)
	end

	def create_attachment_from_file(path, page: 0, doc_id: 0, name: nil)
		begin
			file = File.open(path, "rb")
			data = file.read()
		ensure
			file.close()
		end
		create_attachment(name || File.basename(path), data: data, page: page, doc_id: doc_id)
	end

	def write_attachment_to_file(id, fullpath: nil, dir: nil)
		attachment = transaction() do
			repo = get_repo(Attachment)
			attachment = repo.get_by_id(id)
			if not attachment
				raise "attachment with id #{id} does not exist!"
			end
			attachment.data = repo.load_property(attachment, :data)
			attachment
		end

		path = nil
		if fullpath
			path = fullpath
		else
			path = File.join(dir, attachment.name)
		end

		if File.exist?(path)
			raise "file '#{path}' already exists!"
		end

		begin
			file = File.open(path, "wb")
			file.write(attachment.data)
		ensure
			file.close() if file
		end
	end

	def create_attachment(name, data: nil, page: 0, doc_id: 0)
		raise "invalid name '#{name}'!" if not name =~ /^[a-zA-z0-9_.-]+$/
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
			
			doc_repo = get_repo(Document)
			if not doc_repo.get_by_id(doc_id)
				raise "document with id '#{doc_id}' does not exists!"
			end
			
			attachment.page = page
			attachment.doc_id = doc_id
			attachment.mtime = Time.now.to_i
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
			attachment.mtime = Time.now.to_i
			repo.update(attachment, :data)
		end
	end

	def read_attachment_data(id)
		repo = get_repo(Attachment)
		attachment = repo.get_by_id(id)
		return repo.load_property(attachment, :data).force_encoding(Encoding::UTF_8)
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

	def try_take_document(id)
		transaction() do
			repo = get_repo(Document)
			document = repo.get_by_id(id)
			raise "document with id '#{id}' does not exist!" if not document
			if document.taken == 1
				next false
			end
			document.taken = 1
			repo.update(document)
			true
		end
	end

	def free_document(id)
		transaction() do
			repo = get_repo(Document)
			document = repo.get_by_id(id)
			raise "document with id '#{id}' does not exist!" if not document
			document.taken = 0
			repo.update(document)
		end
	end

	def delete_document(id)
		transaction() do
			doc_repo = get_repo(Document)
			att_repo = get_repo(Attachment)
			document = doc_repo.get_by_id(id)
			raise "document with id '#{id}' does not exist!" if not document
			attachments = att_repo.where("doc_id=?", id)
			attachments.each { |att|
				att.doc_id = 0
				att_repo.update(att)
			}
			doc_repo.delete(id)
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

	def get_documents_where(query)
		@context.transaction() do
			repo = get_repo(Document)
			documents = repo.where(query)
			documents
		end
	end

	def get_document_by_id(id)
		repo = get_repo(Document)
		repo.get_by_id(id)
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
		@context = SQLiteContext.new(path)
	end

	def get_repo(type)
		@context.get_repo(type)
	end

	def transaction(&block)
		result = "nothin"
		@context.transaction do
			result = block.call
		end
		result
	end

	def close()
		@context.close()
	end
end