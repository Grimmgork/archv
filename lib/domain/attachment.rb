require_relative "./record.rb"

Attachment = Record.define(:name, :doc_id, :page, :size, :mtime)