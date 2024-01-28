require_relative "lib/orm.rb"

class Document
	include Entity
	set_table "documents"
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

repo = Repository.new("data.db", Document)

doc = repo.byid(1)
doc.title = "Hello world!"
repo.close()