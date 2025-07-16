module Archivum::Query::Document::Attachments
	module_function

	def call(context, doc_id, *filenames)
		statements = []
		args = []
		filenames.each do |like| 
			statements << "name LIKE '/' || ? || '/' || ?"
			args << doc_id
			args << like
		end

		if filenames.length == 0
			statements << "name LIKE '/' || ? || '/%'"
			args << doc_id
		end
		
		context.data.execute("SELECT name, page, sz, mtime, doc_id FROM sqlar WHERE #{statements.join(" OR ")} ORDER BY mtime;", *args) do |row|
			doc_id, name = row[0].split("/").reject { |s| s.nil? || s.empty? }
			Archivum::Model::Attachment.new(name, doc_id, row[1], row[2], row[3])
		end
	end
end