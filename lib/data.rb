require 'sqlite3'

Attachment = Struct.new(:name, :mtime, :sz, :page, :doc_id)
Document = Struct.new(:id, :title, :timestamp, :location, :last_moved, :taken)

def start_transaction(db)
	db.execute("BEGIN DEFERRED TRANSACTION;");
end

def end_transaction(db, rollback=false)
	if rollback
		db.execute("ROLLBACK;");
	else
		db.execute("COMMIT;");
	end
end

class AttachmentRepository
	def initialize(db)
		@db = db
	end

	def create(name, doc_id=0)
		@db.execute("INSERT INTO sqlar (name, mtime, doc_id) VALUES(?, ?, ?);", name, Time.now.to_i, doc_id)
		return @db.last_insert_row_id
	end

	def delete(name)
		@db.execute("DELETE FROM sqlar WHERE name=?", name)
	end

	def read_data(name)
		@db.get_first_value("SELECT data FROM sqlar WHERE name=? LIMIT 1;", name)
	end

	def write_data(name, data)
		blob = SQLite3::Blob.new data
		@db.execute("UPDATE sqlar SET data=? WHERE name=?;", blob, name)
	end

	def rename(from, to)
		@db.execute("UPDATE sqlar SET name=? WHERE name=?;", to, from)
	end

	def get_by_name(name)
		res = @db.get_first_row("SELECT name, mtime, sz, page, doc_id FROM sqlar WHERE name=? LIMIT 1;", name)
		return Attachment.new(res[0], res[1], res[2], res[3], res[4])
	end

	def get_by_document(id)
		res = @db.execute("SELECT name, mtime, sz, page, doc_id FROM sqlar WHERE doc_id=? LIMIT 1;", id)
		attachments = []
		res.each do |row|
			attachments.append(Attachment.new(res[0], res[1], res[2], res[3], res[4]))
		end
		return attachments
	end
end

class DocumentRepository
	def initialize(db)
		@db = db
	end

	def get_by_location(location)
		res = @db.execute("SELECT id, title, timestamp, location, last_moved, taken FROM documents WHERE location=? ORDER BY last_moved DESC;", location)
		documents = []
		res.each do |row|
			documents.append(Document.new(row[0], row[1], row[2], row[3], row[4], row[5]))
		end
		return documents
	end

	def get_by_id(id)
		res = @db.get_first_row("SELECT id, title, timestamp, location, last_moved, taken FROM documents WHERE id=? LIMIT 1;", id)
		return Document.new(res[0], res[1], res[2], res[3], res[4], res[5])
	end

	def create(location)
		@db.execute("INSERT INTO documents (timestamp, location) VALUES(?, ?);", Time.now.to_i, location)
		return @db.last_insert_row_id 
	end

	def delete(id)
		@db.execute("DELETE FROM documents WHERE id = ?;", id)
	end

	def update(document)
		@db.execute("UPDATE documents SET timestamp=?, title=?, location=?, last_moved=?, taken=? WHERE id=?;", 
			document.timestamp, 
			document.title, 
			document.location, 
			document.last_moved, 
			document.taken,
			document.id
		)
	end
end