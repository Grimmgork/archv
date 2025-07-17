module Archivum::Logic
	module_function
	
	def reattach_attachment(attachment, to_document, attachments)
		raise "document already has an attachment with the same name!" if attachments.any? { |a| a.name == attachment.name }
		Archivum::Model::Attachment.new(
			attachment.name, 
			to_document.id, 
			attachment.page,
			attachment.size,
			attachment.mtime
		)
	end
	
	def rename_attachment(attachments, from, to)
		raise "document already has an attachment with the name #{to}!" if attachments.any? { |a| a.name == to }
		attachment = attachments.find { |a| a.name == from }
		raise "document does not have an attachment with name #{from.name}!" if not attachment
		Archivum::Model::Attachment.new(
			to,
			attachment.doc_id,
			attachment.page,
			attachment.size,
			attachment.mtime
		)
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
		raise "document must have a readable title" if trimmed_title.length <= 0
		Archivum::Model::Document.new(
			0,
			trimmed_title,
			timestamp,
			location,
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
		document.with(location: trimmed_location, last_moved: timestamp)
	end

	def update_document_title(document, title)
		trimmed_title = title.strip
		raise "invalid title" if trimmed_title.length <= 0
		document.with(title: trimmed_title)
	end
	
	def update_attachment_data(attachment, size)
		raise "size must not be negative!" if size < 0
		Archivum::Model::Attachment.new(
			attachment.name,
			attachment.doc_id,
			attachment.page,
			size,
			Time.now.to_i
		)
	end
end
