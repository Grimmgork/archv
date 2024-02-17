require_relative 'orm.rb'

class Document
 	include Entity
 	table "documents"
 	property :id, :primary
 	property :title
 	property :timestamp
 	property :location
 	property :last_moved
 	property :taken
end

class Attachment
 	include Entity
 	table "attachments"
 	property :id, :primary
 	property :name
 	property :sz
 	property :page
	property :mtime
 	property :doc_id
end