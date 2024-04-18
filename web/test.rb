require "../lib/archive.rb"

archive = Archive.new("data.db")
puts archive.call(GetAttachmentsForDocument, 1, "%.pdf")
archive.close()