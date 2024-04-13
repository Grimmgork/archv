require "./archive.rb"
require "./business/commands.rb"

archive = Archive.new("data.db")
archive.call(CreateNewAttachment, 1, "attachment.pdf", 0)
archive.close()