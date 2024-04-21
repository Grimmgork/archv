require "../lib/archive.rb"

archive = Archive.new("data.db")

handle = File.open("gopher.jpg", "rb")
archive.call(CreateAttachmentFromFile, 1, "gopher2.jpg", 1, handle)
handle.close()

archive.close()