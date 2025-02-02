module GetUntakenDocumentsByLocation
	module_function

	def call(context, location)
		context.data.execute("SELECT id, title, timestamp, location, last_moved, taken FROM document WHERE location=? AND taken=0", location) do |row|
			Document.new(*row)
		end
	end
end