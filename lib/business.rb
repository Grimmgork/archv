require "./lib/data.rb"

class Archive
	def initialize(path)
		@db = SQLite3::Database.open path

		@documents = DocumentRepository.new(@db)
		@attachments = AttachmentRepository.new(@db)
	end

	def close()
		@db.close() if @db
	end

	def create_document(location)
		raise "location must not be empty!" if not location or location==""
		return @documents.create(location)
	end

	def get_documents_from_location(location)
		return @documents.get_by_location(location)
	end

	def move_document(id, location)
		start_transaction(@db)
		doc = @documents.get_by_id(id)
		doc.location = location
		doc.last_moved = Time.now.to_i
		@documents.update(doc)
		end_transaction(@db)
	end

	def write_attachment_data(name, data)
		@attachments.write_data(name, data)
	end

	def read_attachment_data(name)
		return @attachments.read_data(name)
	end

	def get_attachment_by_name(name)
		return @attachments.get_by_name(name)
	end

	def get_attachments_of_document(id)
		return @attachments.get_by_document(id)
	end

	def try_take_document(id)
		start_transaction(@db)
		doc = @documents.get_by_id(id)
		if doc.taken == 0
			doc.taken = 1
			@documents.update(doc)
			end_transaction(@db)
			return true
		end
		end_transaction(@db)
		return false
	end
end