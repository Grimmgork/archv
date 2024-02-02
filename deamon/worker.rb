class Worker
	def initialize(location, work)
		@work = work
		@location = location
	end

	def run(archive)
		return if not @work
		return if not @location

		# TODO maybe inject a selection function, (sorting)
		documents = archive.get_document_where("location=?", @location)
		return if documents.length == 0
		document = documents[0]

		next_location = @work.call(archive, document)
		archive.move_document(document.id, next_location) if next_location
	end
end