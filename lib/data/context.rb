require "sqlite3"
require_relative "../domain/models.rb"

class Context
	def initialize(path)
		@db = SQLite3::Database.open path
	end

	def execute(query, *args, &block)
		result = []
		@db.execute(query, args) do |row|
			result << block.call(row)
		end
		result
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
			return Repository.new(self, "sqlar", [ "name", "page", "sz", "mtime" ], false, from_row, to_row)
		end

		if type == Document
			to_row = Proc.new do |obj|
				[ obj.id, obj.title, obj.timestamp, obj.location, obj.last_moved, obj.taken ]
			end
			from_row = Proc.new do |row|
				Document.new(row[0], row[1], row[2], row[3], row[4], row[5])
			end
			return Repository.new(self, "document", [ "id", "title", "timestamp", "location", "last_moved", "taken" ], true, from_row, to_row)
		end

		throw "No repository defined for type #{type}!"
	end
end

class Repository
	def initialize(context, table, fields, primary_from_db, from_row, to_row)
		@context = context
		@table = table
		@fields = fields
		@from_row = from_row
		@to_row = to_row
		@primary = fields[0]
		@primary_from_db = primary_from_db
	end

	def read(entity)
		res = @context.first("SELECT #{@fields.join(",")} FROM #{@table} WHERE #{@primary}=?;", primary_value(entity))
		return from_row(res)
	end

	def delete(entity)
		@context.execute("DELETE FROM #{@table} WHERE #{@primary}=?", primary_value(entity))
	end

	def update(entity)
		statements = @fields.select { |field| "#{field}=?" }
		@context.execute("UPDATE #{@table} SET #{statements.join(",")} WHERE #{@primary}=?;", *to_row(entity).append(primary_value(entity)))
	end

	def insert(entity)
		fields = @primary_from_db ? @fields.drop(1) : @fields
		values = @primary_from_db ? to_row(entity).drop(1) : to_row(entity)
		@context.execute("INSERT INTO #{@table} (#{fields.join(",")}) VALUES(#{Array.new(fields.length, "?").join(",")});", *values)
		return @context.last_insert_row_id
	end

	def primary_value(entity)
		@to_row.call(entity)[0]
	end

	def to_row(entity)
		@to_row.call(entity)
	end

	def from_row(row)
		@from_row.call(row)
	end
end