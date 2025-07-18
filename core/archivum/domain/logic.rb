module Archivum::Logic
	module_function

	def reattach_attachment(attachment, to_document, attachments)
		raise "document already has an attachment with the same name." if attachments.any? { |a| a.name == attachment.name }
		attachment.with(doc_id: to_document.id.to_i)
	end
	
	def rename_attachment(attachments, from, to)
		from = from.to_s
		to = to.to_s
		raise "document already has an attachment with the name #{to}." if attachments.any? { |a| a.name == to }
		attachment = attachments.find { |a| a.name == from }
		raise "document does not have an attachment with name #{from}." if not attachment
		attachment.with(name: to)
	end
	
	def create_new_attachment(document, attachments, name, page, timestamp)
		name = name.to_s
		page = page.to_i
		timestamp = timestamp.to_i
		raise "invalid name" unless name.match(/^[a-zA-Z0-9_.-]+$/)
		raise "document already has an attachment with the name #{name}." if attachments.any? { |a| a.name == name }
		raise "page must not be negative." if page < 0 
		Archivum::Model::Attachment.new(
			name,
			document.id.to_i,
			page,
			0,
			timestamp
		)
	end
	
	def create_new_document(title, location, timestamp)
		timestamp = timestamp.to_i
		title = title.to_s
		title = timestamp.to_s if title.empty?
		location = location.to_s
		raise "invalid title." unless title.match(/[^\s]/)
		raise "invalid location name." unless location.match(/^[a-zA-Z0-9_.-]+$/)
		Archivum::Model::Document.new(
			0,
			title,
			timestamp,
			location,
			timestamp,
			0
		)
	end

	def update_document_title(document, title)
		title = title.to_s
		raise "invalid title" unless title.match(/[^\s]/)
		document.with(title: title)
	end
	
	def try_take_document(document)
		return nil if document.taken == 1
		document.with(taken: 1)
	end
	
	def free_document(document)
		document.with(taken: 0)
	end
	
	def move_document(document, location, timestamp)
		location = location.to_s
		timestamp = timestamp.to_i
		raise "invalid location name." unless location.match(/^[a-zA-Z0-9_.-]+$/)
		raise "document is already in location '#{location}'." if location == document.location
		document.with(location: location, last_moved: timestamp)
	end

	def update_attachment_data(attachment, size, timestamp)
		size = size.to_i
		timestamp = timestamp.to_i
		raise "size must not be negative." if size < 0
		attachment.with(size: size, mtime: timestamp)
	end
end
