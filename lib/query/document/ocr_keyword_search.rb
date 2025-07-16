module Archivum::Query::Document::OcrKeywordSearch
	module_function

	def call(context, attachment_name, *keywords)
		throw "not implemented!"

		statements = []
		args = []

		keywords.each do |word|
			statements << "data LIKE"
		end

		result = context.data.execute("SELECT name, page, sz, mtime, doc_id FROM sqlar WHERE name LIKE ? AND (#{statements.join(" OR ")}) ORDER BY mtime;", "ocr.txt", *args) do |row|

		end
	end
end