class Worker
	def initialize(location, work)
		@work = work
		@location = location
	end

	def run(archive)
		return if not @work
		return if not @location

		documents = archive.get_documents_where({
			"where" => ["and", ["eq", ["prop", "location"], @location], ["eq", ["prop", "taken"], 0]],
			"sort"  => { "last_moved" => true },
			"take"  => 1
		})
		
		return if documents.length <= 0
		document = documents[0]

		if not archive.try_take_document(document.id)
			return
		end

		begin
			next_location = @work.call(archive, document)
			archive.move_document(document.id, next_location) if next_location
		rescue => error
			puts error
			puts Thread.current.backtrace()
			archive.move_document(document.id, "error")
		end
		
		archive.free_document(document.id)
	end
end