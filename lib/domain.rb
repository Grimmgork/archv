require_relative 'orm.rb'

class Document
 	include Entity
 	table "document"
 	property :id, :primary
 	property :title
 	property :timestamp
 	property :location
 	property :last_moved
 	property :taken
end

class Attachment
 	include Entity
 	table "sqlar"
 	property :filename, :primary
 	property :sz
	property :mtime
	property :page

	def doc_id
		name.split("/").reject { |s| s.to_s.empty? } .first
	end

	def doc_id=(id)
		segments = name.split("/").reject { |s| s.to_s.empty? }
		segments[0] = id.to_s
		name = segments.join("/")
	end

	def to_tr()
		return TableRow
	end

	def self.from_tr()
		return Attachment.new()
	end

	def get_tr_map()
		return {

		}
	end
end

class TableRow
	def initialize(table, values)
		
	end
end

def data_persist(tablemap)

end

def data_query(type, query)

end


def persist(Entity)

end