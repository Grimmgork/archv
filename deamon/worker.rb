class Worker
	def initialize(location, work)
		@work = work
		@location = location
	end

	def run(archive)
		return if not @work
		return if not @location

		documents = archive.call(GetUntakenDocumentsByLocation, @location)
		documents = documents.sort_by { |doc| doc.last_moved } # least recently moved document first
		
		return if documents.length <= 0
		document = documents[0]

		if not archive.call(TryTakeDocument, document.id)
			return
		end

		begin
			next_location = @work.call(archive, document)
			archive.move_document(document.id, next_location || @location)
		rescue => error
			puts "#{@location} ERROR: #{error}"
			archive.move_document(document.id, "error")
		end
		
		archive.free_document(document.id)
	end
end