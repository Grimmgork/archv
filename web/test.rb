require "../lib/archive.rb"

archive = Archive.new("data.db")
result = archive.transaction do
	archive.call(DeleteAttachment, 1, "ocr.pdf")
	archive.call(CreateNewAttachment, 1, "ocr.pdf", 0, "")
	1
end
archive.close()

puts result