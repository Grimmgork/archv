class Record < Data
	def clone(**setters)
		values = deconstruct()
		setters.each do |setter, value|
			index = members.index(setter)
			values[index] = value if not index == nil 
		end
		self.class[*values]
	end
end

Attachment = Record.define(
	:name, 
	:doc_id, 
	:page, 
	:size, 
	:mtime
)

print Attachment.new("asdf", 1, 2, 100, 10)