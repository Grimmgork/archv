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

class SQLiteRepository
	def initialize(db, entity_type)
		@entity_type = entity_type
		@db = db
	end

	def create()
		entity = @entity_type.new()
		hash = entity.to_h(true)
		@db.execute("INSERT INTO #{@entity_type.get_table} (#{hash.keys.join(",")}) VALUES(#{Array.new(hash.keys.length){"?"}.join(",")});", hash.values)
		return @db.last_insert_row_id
	end

	def get_by_id(id)
		props = @entity_type.get_properties(true)
		res = @db.get_first_row("SELECT #{props.join(",")} FROM #{@entity_type.get_table} WHERE #{@entity_type.get_primary_key}=?", id)
		return nil if not res
		return @entity_type.from_h(res)
	end

	def where(expr)
		args = []
		query = parse_expr(expr, args)
		props = @entity_type.get_properties(true)
		res = @db.execute("SELECT #{props.join(",")} FROM #{@entity_type.get_table} WHERE (#{query});", args)
		entities = []
		res.each do |row|
			entities.append @entity_type.from_h(row)
		end
		return entities
	end

	def update(entity, *lazy_properties)
		hash = entity.to_h(true)
		lazy_properties.each { |prop| 
			hash[prop.to_s]=entity.send(prop)
		}
		setters = hash.keys.map { |prop| "#{prop}=?" }
		id = entity.send(@entity_type.get_primary_key)
		@db.execute("UPDATE #{@entity_type.get_table} SET #{setters.join(",")} WHERE #{@entity_type.get_primary_key}=?;", hash.values.append(id))
	end

	def delete(id)
		@db.execute("DELETE FROM #{@entity_type.get_table} WHERE #{@entity_type.get_primary_key}=?;", id)
	end

	def load_property(entity, property)
		id = entity.send(@entity_type.get_primary_key)
		return @db.get_first_value("SELECT #{property} FROM #{@entity_type.get_table} WHERE #{@entity_type.get_primary_key}=?;", id)
	end

	def write_property(entity, property)
		id = entity.send(@entity_type.get_primary_key)
		value = entity.send(property)
		@db.execute("UPDATE #{@entity_type.get_table} SET #{property}=?;", value)
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
			when "prop"
				# TODO check for funny characters
				return "#{expr[0]}"
			when "and"
				return "(#{parse_expr(expr[0], values)} AND #{parse_expr(expr[1], values)})"
			when "or"
				return "(#{parse_expr(expr[0], values)} OR #{parse_expr(expr[1], values)})"
			end
			raise "unknown operator '#{operator}'"
		end

		puts 
		return expr.to_s if expr == true or expr == false
		# literal types
		values.append(expr)
		return "?"
	end
end