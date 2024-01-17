class Worker
	def initialize(archive, location, work)
		@archive = archive
		@work = work
		@location = location
	end

	def print()
		puts @location
	end

	def run()
		return if not @work
		return if not @location

		# TODO maybe inject a selection function, (sorting)
		documents = @archive.get_documents_from_location(@location)
		return if documents.length == 0
		document = documents[0]

		next_location = @work.call(@archive, document)
		@archive.move_document(document.id, next_location)
	end
end