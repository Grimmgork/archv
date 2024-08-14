class Repository
	def initialize(data, table, fields, primary_from_db, from_row, to_row)
		@data = data
		@table = table
		@fields = fields
		@from_row = from_row
		@to_row = to_row
		@primary = fields[0]
		@primary_from_db = primary_from_db
	end

	def read(entity)
		res = @data.first("SELECT #{@fields.join(",")} FROM #{@table} WHERE #{@primary}=?;", primary_value(entity))
		return nil if not res
		return from_row(res)
	end

	def delete(entity)
		@data.execute("DELETE FROM #{@table} WHERE #{@primary}=?;", primary_value(entity))
	end

	def update(entity)
		statements = @fields.map { |field| "#{field}=?" }
		@data.execute("UPDATE #{@table} SET #{statements.join(",")} WHERE #{@primary}=?;", *to_row(entity).append(primary_value(entity)))
	end

	def insert(entity)
		fields = @primary_from_db ? @fields.drop(1) : @fields
		values = @primary_from_db ? to_row(entity).drop(1) : to_row(entity)

		@data.execute("INSERT INTO #{@table} (#{fields.join(",")}) VALUES(#{Array.new(fields.length, "?").join(",")});", *values)
		return @data.last_insert_row_id
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

	def get_fields()
		@fields
	end
end