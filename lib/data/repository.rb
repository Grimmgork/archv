class Repository
	def initialize(context, table, primary, fields, from_row, to_row)
		@context = context
		@table = table
		@fields = fields
		@from_row = from_row
		@to_row = to_row
		@primary = fields[0]
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
		@context.execute("INSERT INTO #{@table} (#{@fields.join(",")}) VALUES(#{Array.new(@fields.length, "?").join(",")});", *to_row(entity))
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