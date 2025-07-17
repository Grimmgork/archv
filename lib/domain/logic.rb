module Archivum::Logic
	module_function
	
	def reattach_attachment(attachment, to_document, attachments)
		raise "document already has an attachment with the same name!" if attachments.any? { |a| a.name == attachment.name }
		attachment.with(doc_id: to_document.id)
	end
	
	def rename_attachment(attachments, from, to)
		raise "document already has an attachment with the name #{to}!" if attachments.any? { |a| a.name == to }
		attachment = attachments.find { |a| a.name == from }
		raise "document does not have an attachment with name #{from}!" if not attachment
		attachment.with(name: to)
	end
	
	def create_new_attachment(document, attachments, name, page, timestamp)
		raise "document already has an attachment with the name #{name}!" if attachments.any? { |a| a.name == name }
		Archivum::Model::Attachment.new(
			name,
			document.id,
			page,
			0,
			timestamp
		)
	end
	
	def create_new_document(title, location, timestamp)
		trimmed_title = title.strip
		trimmed_title = timestamp.to_s if trimmed_title.length <= 0
		trimmed_location = location.strip
		raise "invalid location name" unless trimmed_location.match(/^[a-zA-Z0-9_.-]+$/)
		raise "invalid timestamp" unless timestamp
		Archivum::Model::Document.new(
			0,
			trimmed_title,
			timestamp,
			trimmed_location,
			timestamp,
			0
		)
	end
	
	def try_take_document(document)
		return nil if document.taken == 1
		document.with(taken: 1)
	end
	
	def free_document(document)
		document.with(taken: 0)
	end
	
	def move_document(document, location, timestamp)
		trimmed_location = location.strip
		raise "invalid location name" unless trimmed_location.match(/^[a-zA-Z0-9_.-]+$/)
		raise "invalid timestamp" unless timestamp
		raise "document is already in location '#{trimmed_location}'" if trimmed_location == document.location
		document.with(location: trimmed_location, last_moved: timestamp)
	end

	def update_document_title(document, title)
		trimmed_title = title.strip
		raise "invalid title" if trimmed_title.length <= 0
		document.with(title: trimmed_title)
	end
	
	def update_attachment_data(attachment, size, timestamp)
		raise "invalid timestamp" if timestamp == nil 
		raise "size must not be negative!" if size < 0
		attachment.with(size: size, mtime: timestamp)
	end
end
