require_relative "../lib/archive.rb"

class Worker
	def initialize(location, filenames, &block)
		@work = block
		@location = location
		@filenames = filenames
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

		attachments = archive.call(GetAttachmentsForDocument, document.id, *@filenames)

		begin
			next_location = @work.call(archive, document, attachments)
			archive.call(MoveDocument, document.id, next_location || @location)
		rescue => error
			puts "#{@location} ERROR: #{error}"
			archive.call(MoveDocument, document.id, "error")
		end
		
		archive.call(FreeDocument, document.id)
	end
end