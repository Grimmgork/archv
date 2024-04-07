Attachment = Data.define(:name, :doc_id, :page, :size, :mtime)
Document = Data.define(:id, :title, :timestamp, :location, :last_moved, :taken)

DocumentAggregate = Data.define(:document, :attachments, :data)

AttachmentQueryMatch = Data.define(:document_id, :document_title, :page, :name)

def reattach_attachment(from_document, attachment, to_document)

end

def rename_attachment(attachments, from, to)
		
end

def create_new_attachment(document, attachments, name, page, data)

end

def create_new_document(title)

end

def update_document(attachment, title)

end

def move_document(document, location)

end

def update_attachment(attachment, page)

end

def update_attachment_data(attachment, size)

end