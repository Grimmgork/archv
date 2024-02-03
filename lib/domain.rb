require_relative 'orm.rb'

class Document
 	include Entity
 	table "documents"
 	property :id
 	property :title
 	property :timestamp
 	property :location
 	property :last_moved
 	property :taken
end

class Attachment
 	include Entity
 	table "attachments"
 	property :id
 	property :name
 	property :sz
 	property :data, true
 	property :page
	property :mtime
 	property :doc_id
end