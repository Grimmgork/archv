class Context
	def initialize(path)
		@db = SQLite3::Database.open path
	end

	def execute(query, *args, &block)
		@db.execute(query, args) do |row|
			block.call(row)
		end
	end

	def first(query, *args, &block)
		@db.get_first_value(query, args)
	end

	def transaction()
		@db.execute("BEGIN TRANSACTION;")
		result = nil
		begin
			result = yield()
		rescue
			@db.execute("ROLLBACK;")
			raise
		end

		@db.execute("COMMIT;")
		return result
	end

	def last_insert_row_id
		@db.last_insert_row_id
	end

	def close()
		@db.close()
	end

	def get_repo(type)
		if type == Attachment
			to_row = Proc.new do |obj|
				[ "/#{obj.doc_id}/#{obj.name}", obj.page, obj.size, obj.mtime ]
			end
			from_row = Proc.new do |row|
				name, doc_id = row[0].split("/").reject { |s| s.nil? || s.empty? }
				Attachment.new(name, doc_id, row[1], row[2], row[3])
			end
			return Repository.new(self, "sqlar", [ "name", "page", "size", "mtime" ], from_row, to_row)
		end

		if type == Document
			to_row = Proc.new do |obj|
				[ obj.id, obj.title, obj.timestamp, obj.location, obj.last_moved, obj.taken ]
			end
			from_row = Proc.new do |row|
				Document.new(row[0], row[1], row[2], row[3], row[4], row[5])
			end
			return Repository.new(self, "document", [ "id", "title", "timestamp", "location", "last_moved", "taken" ], from_row, to_row)
		end

		throw "no repository defined for type #{type}!"
	end
end