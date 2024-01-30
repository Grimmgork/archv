class Worker
	def initialize(archive, location, work)
		@archive = archive
		@work = work
		@location = location
	end

	def run()
		return if not @work
		return if not @location

		# TODO maybe inject a selection function, (sorting)
		documents = @archive.get_where("location=?", @location)
		return if documents.length == 0
		document = documents[0]

		next_location = @work.call(@archive, document)
		@archive.move(document.id, next_location) if next_location
	end
end