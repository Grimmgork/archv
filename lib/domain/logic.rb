require_relative "./attachment.rb"
require_relative "./document.rb"

module Logic
	def reattach_attachment(attachment, to_document, attachments)
		throw "document already has an attachment with the same name!" if attachments.any? { |a| a.name == attachment.name }
		return Attachment.new(
			attachment.name, 
			to_document.id, 
			attachment.page,
			attachment.size,
			attachment.mtime
		)
	end
	
	def rename_attachment(attachments, from, to)
		throw "document already has an attachment with the name #{to}!" if attachments.any? { |a| a.name == to }
		attachment = attachments.find { |a| a.name == from }
		throw "document does not have an attachment with name #{from.name}!" if not attachment
		return Attachment.new(
			to,
			attachment.doc_id,
			attachment.page,
			attachment.size,
			attachment.mtime
		)
	end
	
	def create_new_attachment(document, attachments, name, page)
		throw "document already has an attachment with the name #{name}!" if attachments.any? { |a| a.name == name }
		return Attachment.new(
			name,
			document.id,
			page,
			0,
			Time.now.to_i
		)
	end
	
	def create_new_document(title, location)
		return Document.new(
			0,
			title,
			Time.now.to_i,
			location,
			Time.now.to_i,
			0
		)
	end
	
	def try_take_document(document)
		return nil if document.taken != 0
		return document.with(taken: 1)
	end
	
	def free_document(document)
		return document.with(taken: 0)
	end
	
	def move_document(document, location)
		return document.with(location: location)
	end
	
	def update_attachment_data(attachment, size)
		throw "size must not be negative!" if size < 0
		return Attachment.new(
			attachment.name,
			attachment.doc_id,
			attachment.page,
			size,
			Time.now.to_i
		)
	end
end
