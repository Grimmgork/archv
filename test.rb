require "sqlite3"

@db = SQLite3::Database.open "data.db"

def execute(query, *args, &block)
	result = []
	@db.execute(query, args) do |row|
		result << block.call(row)
	end
	result
end

rows = execute("SELECT * FROM document") do |row|
	row
end

puts rows.length