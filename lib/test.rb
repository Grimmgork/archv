require "./archive.rb"

archive = Archive.new("data.db")
archive.call(CreateNewAttachment, 1, "attachment.pdf", 0)
archive.close()