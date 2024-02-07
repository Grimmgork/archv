require 'set'
require 'sqlite3'

module Entity
	def self.included(base)
		base.class_eval do
			@properties = []
			@primary_key = :id
			@lazy = Set.new()

			def self.property(symbol, lazy=false)
				attr_accessor symbol
				@properties.append(symbol)
				@lazy.add(symbol) if lazy
			end

			def self.get_properties(lazy=false)
				if not block_given?
					return @properties.select { |prop| 
						lazy and not @lazy.include?(prop) or not lazy
					}
				end

				@properties.each { |prop|
					next if lazy and @lazy.include?(prop)
					yield prop
				}
			end

			def self.get_table
				return @table
			end

			def self.table(name)
				@table = name
			end

			def self.get_primary_key
				return @primary_key
			end

			def self.primary_key(symbol)
				@primary_key = symbol
			end

			def to_h(lazy=false)
				res = {}
				self.class.get_properties(lazy) do |prop|
					res[prop.to_s] = send(prop)
				end
				return res
			end

			def to_json(options={})
				to_h().to_json(options)
			end

			def self.from_h(hash)
				entity = self.new()
				@properties.each { |prop|
					entity.send("#{prop}=", hash[prop.to_s])
				}
				return entity
			end
		end
	end
end

class SQLiteContext
	def initialize(path)
		@db = SQLite3::Database.open path
		@db.results_as_hash = true
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

	def execute(query, *args)
		@db.execute(query, args)
	end

	def get_repo(type)
		return SQLiteRepository.new(@db, type)
	end

	def close()
		@db.close() if @db
		@db = nil
	end
end

class SQLiteRepository
	def initialize(db, entity_type)
		@entity_type = entity_type
		@db = db
		@primary_key = @entity_type.get_primary_key()
		@tablename = @entity_type.get_table()
		@properties = @entity_type.get_properties(true)
	end

	def create()
		entity = @entity_type.new()
		hash = entity.to_h(true)
		@db.execute("INSERT INTO #{@tablename} (#{hash.keys.join(",")}) VALUES(#{Array.new(hash.keys.length){"?"}.join(",")});", hash.values)
		return @db.last_insert_row_id
	end

	def get_by_id(id)
		res = @db.get_first_row("SELECT #{@properties.join(",")} FROM #{@tablename} WHERE #{@primary_key}=?", id)
		return nil if not res
		return @entity_type.from_h(res)
	end

	# def where(expr)
	# 	args = []
	# 	sql = parse_expr(expr, args)
	# 	res = @db.execute("SELECT #{@properties.join(",")} FROM #{@tablename} WHERE (#{sql});", args)
	# 	entities = []
	# 	res.each do |row|
	# 		entities.append @entity_type.from_h(row)
	# 	end
	# 	return entities
	# end

	def where(query)
		where = query["where"]
		sort = query["sort"]
		skip = query["skip"] || 0
		take = query["take"]

		args = []
		sql = "SELECT #{@properties.join(",")} FROM #{@tablename} WHERE (#{parse_expr(where, args)}) #{sql_sort(sort, args)} #{sql_pagination(skip, take, args)};"
		res = @db.execute(sql, args)
		entities = []
		res.each do |row|
			entities.append @entity_type.from_h(row)
		end
		return entities
	end

	def sql_pagination(skip, take, out_args)
		return "" if take == nil
		sql = ""
		out_args.append(take)
		sql += "LIMIT ? "
		out_args.append(skip)
		sql += "OFFSET ?"
		return sql
	end

	def sql_sort(sort, out_args)
		return "" if not sort or sort.keys.length == 0
		sql = "ORDER BY "
		statements = []
		sort.keys.each { |prop|
			statements.append "#{prop_safe(prop)} #{sort[prop] ? "ASC" : "DESC"}"
		}
		sql += statements.join(", ")
		return sql
	end

	def update(entity, *lazy_properties)
		hash = entity.to_h(true)
		lazy_properties.each { |prop| 
			hash[prop.to_s]=entity.send(prop)
		}
		setters = hash.keys.map { |prop| "#{prop}=?" }
		id = entity.send(@primary_key)
		@db.execute("UPDATE #{@tablename} SET #{setters.join(",")} WHERE #{@primary_key}=?;", hash.values.append(id))
	end

	def delete(id)
		@db.execute("DELETE FROM #{@tablename} WHERE #{@primary_key}=?;", id)
	end

	def load_property(entity, property)
		id = entity.send(@primary_key)
		value = @db.get_first_value("SELECT #{property} FROM #{@tablename} WHERE #{@primary_key}=?;", id)
		return value
	end

	def write_property(entity, property)
		id = entity.send(@primary_key)
		value = entity.send(property)
		@db.execute("UPDATE #{@tablename} SET #{property}=?;", value)
	end

	def prop_safe(name)
		throw "invalid characters in '#{name}'" if not name.match(/^[a-zA-Z\-_]+$/)
		return name
	end

	def parse_expr(expr, values)
		if expr.respond_to?('each')
			operator = expr.shift
			case operator
			when "lt"
				return "(#{parse_expr(expr[0], values)} < #{parse_expr(expr[1], values)})"
			when "gt"
				return "(#{parse_expr(expr[0], values)} > #{parse_expr(expr[1], values)})"
			when "eq"
				return "(#{parse_expr(expr[0], values)} = #{parse_expr(expr[1], values)})"
			when "like"
				return "(#{parse_expr(expr[0], values)} LIKE #{parse_expr(expr[1], values)})"
			when "prop"
				return "#{prop_safe(expr[0])}"
			when "and"
				return "(#{(expr.map { |ex| parse_expr(ex, values) }).join(" AND ")})"
				# return "(#{parse_expr(expr[0], values)} AND #{parse_expr(expr[1], values)})"
			when "or"
				return "(#{(expr.map { |ex| parse_expr(ex, values) }).join(" OR ")})"
				# return "(#{parse_expr(expr[0], values)} OR #{parse_expr(expr[1], values)})"
			end
			raise "unknown operator '#{operator}'!"
		end

		return expr.to_s if expr == true or expr == false
		# literal types
		values.append(expr)
		return "?"
	end
end

# values = []
# puts parse_expr(["and", 1, 2, 3, 4], values)
# puts values