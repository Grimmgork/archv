require_relative "lib/orm.rb"

class Document
	include Entity
	table "documents"
	property :id
	property :title
	property :timestamp
	property :location
	property :last_moved
	property :taken

	def move(location)
		@location=location
	end
end

class Attachment
	include Entity
	table "attachments"
	property :id
	property :name
	property :sz
	property :data, true
	property :page
	property :doc_id
end

repo = Repository.new("data.db", Attachment)

attch = repo.byid(1)
attch.name = "filename.txt"
attch.data = "asadad"
attch.page = 6
repo.update(attch, :data)
repo.close()
exit