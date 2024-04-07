
Attachment = Data.define(:name, :doc_id, :page, :size, :mtime)
Document = Data.define(:id, :title, :timestamp, :location, :last_moved, :taken)

DocumentAggregate = Data.define(:document, :attachments, :data)