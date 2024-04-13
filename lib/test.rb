require "./archive.rb"
require "./business/commands.rb"

archive = Archive.new("data.db")
archive.call(CreateNewDocument, "First document!")
archive.close()