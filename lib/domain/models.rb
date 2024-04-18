
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

Attachment = Record.define(:name, :doc_id, :page, :size, :mtime)
Document = Record.define(:id, :title, :timestamp, :location, :last_moved, :taken)

DocumentAggregate = Record.define(:document, :attachments, :data)