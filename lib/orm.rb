require 'set'
require 'sqlite3'

module Entity
	def self.included(base)
		def [](symbol)
			send(symbol.to_s)
		end

		def []=(symbol, value)
			send("#{symbol}=", value)
		end

		base.class_eval do
			@properties = []
			@lazy_properties = Set.new()
			@primary_key = :id
			
			def self.property(symbol, *options)
				attr_accessor symbol
				@properties.append(symbol)
				@lazy_properties.add(symbol) if options.include?(:lazy)
				@primary_key = symbol if options.include?(:primary)
			end

			def self.is_property_lazy(symbol)
				@lazy_properties.include?(symbol)
			end

			def self.get_properties(*lazy)
				if not block_given?
					return @properties.select { |prop|
						not is_property_lazy(prop) or lazy.include?(prop)
					}
				end

				@properties.each { |prop|
					next if is_property_lazy(prop) and not lazy.include?(prop)
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

			def to_h(*lazy)
				res = {}
				self.class.get_properties(*lazy) do |prop|
					res[prop.to_s] = send(prop)
				end
				return res
			end

			def to_a(*lazy)
				self.class.get_properties(*lazy) do |prop|
					res[prop.to_s] = send(prop)
				end
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

			def self.from_a(values, *lazy)
				entity = self.new()
				props = get_properties(*lazy)
				raise "invalid number of values!" if values.length != props.length
				for i in 0..(props.length-1)
					entity.send("#{props[i]}=", values[i])
				end
				entity
			end
		end
	end
end

class SQLiteContext
	def initialize(path)
		@db = SQLite3::Database.open path
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

	def query_type(type, lazy, query, *args)
		res = @db.execute(query, args)
		if block_given?
			res.each do |row|
				yield type.from_a(row, *lazy)
			end
			return
		end

		entities = []
		res.each do |row|
			entities.append type.from_a(row, *lazy)
		end
		entities
	end

	def last_insert_row_id
		@db.last_insert_row_id
	end

	def get_repo(type)
		return SQLiteRepository.new(self, type)
	end

	def close()
		@db.close() if @db
		@db = nil
	end
end

class SQLiteRepository
	def initialize(context, entity_type)
		@context = context
		@entity_type = entity_type
		@primary_key = @entity_type.get_primary_key()
		@tablename = @entity_type.get_table()
	end

	def create()
		entity = @entity_type.new()
		@context.execute("INSERT INTO #{@tablename} (#{@entity_type.get_properties().join(",")}) VALUES(#{Array.new(hash.keys.length){"?"}.join(",")});", hash.values)
		return @context.last_insert_row_id
	end

	def get_by_id(id, *lazy)
		query = "SELECT #{@entity_type.get_properties(*lazy).join(",")} FROM #{@tablename} WHERE #{@primary_key}=?;"
		entities = @context.query_type(@entity_type, lazy, query, id)
		return nil if not entities or entities.length < 1
		return entities[0]
	end

	def where(query, *lazy)
		where = query["where"]
		sort = query["sort"]
		skip = query["skip"] || 0
		take = query["take"]

		args = []
		sql = "SELECT #{@entity_type.get_properties().join(",")} FROM #{@tablename} WHERE (#{parse_expr(where, args)}) #{sql_sort(sort, args)} #{sql_pagination(skip, take, args)};"
		entities = @context.query_type(@entity_type, lazy, sql, args)
		return entities
	end

	def read_property(id, prop)
		res = @context.execute("SELECT #{prop} FROM #{@entity_type.get_table} WHERE id=?;", id)
		return res[0][0]
	end

	def write_property(id, prop, value)
		@context.execute("UPDATE #{@entity_type.get_table} SET #{prop}=? WHERE id=?;", value, id)
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

	def update(entity, *lazy)
		hash = entity.to_h(*lazy)
		setters = hash.keys.map { |prop| "#{prop}=?" }
		id = entity.send(@primary_key)
		@context.execute("UPDATE #{@tablename} SET #{setters.join(",")} WHERE #{@primary_key}=?;", hash.values.append(id))
	end

	def delete(id)
		@context.execute("DELETE FROM #{@tablename} WHERE #{@primary_key}=?;", id)
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
			when "or"
				return "(#{(expr.map { |ex| parse_expr(ex, values) }).join(" OR ")})"
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

