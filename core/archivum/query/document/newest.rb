module Archivum::Query::Document::Newest
	module_function

	def call(context, top)
		context.data.execute("SELECT id, title, timestamp, location, last_moved, taken FROM document ORDER BY timestamp DESC LIMIT ?", top) do |row|
			Archivum::Model::Document.new(*row)
		end
	end
end