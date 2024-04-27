require "../lib/archive.rb"

archive = Archive.new("data.db")
archive.call()
archive.call()
archive.close()