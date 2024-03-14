Attachment = Data.define(:name, :doc_id, :page, :size, :mtime)
Document = Data.define(:id, :title, :timestamp, :location, :last_moved, :taken)

AttachmentQueryMatch = Data.define(:document_id, :document_title, :page, :name)


class Context
	def load(type, &block)

	end

	def where()

	end

	def include(type, name, &block)

	end

	def include_foreign(type, name, &block)

	end

	def exclude(names)

	end

	def find()

	end

	def foreign()

	end
end


class DocumentRepository
	def delete(id)

	end

	def write(document)

	end

	def create(document)

	end

	def get_by_id()

	end

	def get_by_location(query)

	end
end

class AttachmentRepository
	def delete(id)

	end

	def write()

	end

	def create(attachment)

	end

	def get_by_id(name)

	end

	def get_by_document(doc_id)

	end

	def write_data(name, length, data)

	end

	def read_data(name)

	end
end

class Logic
	def get_attachment_name(doc_id, name)

	end

	def reattach_attachment(from_document, attachment, to_document)

	end

	def rename_attachment(attachments, from, to)
		
	end

	def create_new_attachment(document, attachments, name, page, data)

	end

	def create_new_document(title)

	end

	def update_document(attachment, values)

	end

	def update_attachment(attachment, values)

	end

	def update_attachment_data(attachment, size)

	end
end

class Commands
	def rename_attachment(att_id, name)
		# attachment = attachments.get_by_id()
		# attachment.
	end
	
	def move_document(doc_id, location)
	
	end
	
	def set_document_title(doc_id, title)
	
	end
	
	def create_document()
	
	end
	
	def create_attachment(doc_id, name, data, page)
	
	end
	
	def reattach_attachment(doc_id, att_name, new_doc_id)
	
	end
	
	def write_attachment_data_to_file(doc_id, name, filename)
	
	end
	
	def create_attachment_from_file(doc_id, name, filename)
	
	end
	
	def get_attachment_data(doc_id, name)
	
	end
	
	def write_attachment_data(doc_id, name, data)
	
	end

	def delete_attachment(doc_id, name)

	end
end
