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
 	property :name, :primary
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
end