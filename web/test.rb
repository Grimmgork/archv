require "../lib/archive.rb"

archive = Archive.new("data.db")
archive.transaction do 
	archive.transaction do
		archive.call(ReadAttachmentData, 1, "gopher.jpg")
	end
end
archive.close()