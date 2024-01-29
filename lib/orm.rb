require 'set'
require 'sqlite3'

module Entity
	def self.included(base)
		base.class_eval do
			@@properties = []
			@@primary_key = :id
			@@lazy = Set[]

			def self.property(symbol, lazy=false)
				attr_accessor symbol
				@@properties.append(symbol)
				@@lazy.add(symbol) if lazy
			end

			def self.properties
				return @@properties
			end

			def self.get_table
				return @@table
			end

			def self.table(name)
				@@table = name
			end

			def self.get_primary_key
				return @@primary_key
			end

			def self.primary_key(symbol)
				@@primary_key = symbol
			end

			def to_hash(lazy=false)
				res = {}
				@@properties.each { |prop|
					next if lazy and @@lazy.include?(prop)
					res[prop.to_s] = send(prop)
				}
				return res
			end

			def self.from_hash(hash)
				entity = self.new()
				@@properties.each { |prop|
					entity.send("#{prop}=", hash[prop.to_s])
				}
				return entity
			end
		end
	end
end

class Repository
	def initialize(path, entity_type)
		@entity_type = entity_type
		@db = SQLite3::Database.open path
		@db.results_as_hash = true
	end

	def close()
		@db.close() if @db
		@db = nil
	end

	def create()
		entity = @entity_type.new()
		hash = entity.to_hash(true)
		@db.execute("INSERT INTO #{@entity_type.get_table} (#{hash.keys.join(",")}) VALUES(#{Array.new(hash.keys.length){"?"}.join(",")});", hash.values)
		return @db.last_insert_row_id
	end

	def byid(id)
		props = @entity_type.properties
		res = @db.get_first_row("SELECT #{props.join(",")} FROM #{@entity_type.get_table} WHERE #{@entity_type.get_primary_key}=?", id)
		return @entity_type.from_hash(res)
	end

	def where(query, *args)
		props = @entity_type.properties
		res = @db.execute("SELECT #{props.join(",")} FROM #{@entity_type.get_table} WHERE (#{query});", args)
		entities = []
		res.each do |row|
			entities.append @entity_type.from_hash(row)
		end
		return entities
	end

	def update(entity, *lazy_properties)
		hash = entity.to_hash(true)
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
end