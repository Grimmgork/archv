class Context
	def initialize(path)
		@db = SQLite3::Database.open path
	end

	def execute(query, *args, &block)
		@db.execute(query, args) do |row|
			block.call(row)
		end
	end

	def first(query, *args, &block)
		@db.get_first_value(query, args)
	end

	def transaction()
		@db.execute("BEGIN TRANSACTION;")
		result = nil
		begin
			result = yield()
		rescue
			@db.execute("ROLLBACK;")
			raise
		end

		@db.execute("COMMIT;")
		return result
	end

	def last_insert_row_id
		@db.last_insert_row_id
	end

	def close()
		@db.close()
	end

	def get_repo(type)
		if type == Attachment
			to_row = Proc.new do |obj|
				[ "/#{obj.doc_id}/#{obj.name}", obj.page, obj.size, obj.mtime ]
			end
			from_row = Proc.new do |row|
				name, doc_id = row[0].split("/").reject { |s| s.nil? || s.empty? }
				Attachment.new(name, doc_id, row[1], row[2], row[3])
			end
			return Repository.new(self, "sqlar", [ "name", "page", "size", "mtime" ], from_row, to_row)
		end

		if type == Document
			to_row = Proc.new do |obj|
				[ obj.id, obj.title, obj.timestamp, obj.location, obj.last_moved, obj.taken ]
			end
			from_row = Proc.new do |row|
				Document.new(row[0], row[1], row[2], row[3], row[4], row[5])
			end
			return Repository.new(self, "document", [ "id", "title", "timestamp", "location", "last_moved", "taken" ], from_row, to_row)
		end

		throw "no repository defined for type #{type}!"
	end
end

class Repository
	def initialize(context, table, primary, fields, from_row, to_row)
		@context = context
		@table = table
		@fields = fields
		@from_row = from_row
		@to_row = to_row
		@primary = fields[0]
	end

	def read(entity)
		res = @context.first("SELECT #{@fields.join(",")} FROM #{@table} WHERE #{@primary}=?;", primary_value(entity))
		return from_row(res)
	end

	def delete(entity)
		@context.execute("DELETE FROM #{@table} WHERE #{@primary}=?", primary_value(entity))
	end

	def update(entity)
		statements = @fields.select { |field| "#{field}=?" }
		@context.execute("UPDATE #{@table} SET #{statements.join(",")} WHERE #{@primary}=?;", *to_row(entity).append(primary_value(entity)))
	end

	def insert(entity)
		@context.execute("INSERT INTO #{@table} (#{@fields.join(",")}) VALUES(#{Array.new(@fields.length, "?").join(",")});", *to_row(entity))
		return @context.last_insert_row_id
	end

	def primary_value(entity)
		@to_row.call(entity)[0]
	end

	def to_row(entity)
		@to_row.call(entity)
	end

	def from_row(row)
		@from_row.call(row)
	end
end

class Archive

	def initialize(path)
		@context = Context.new(path)
	end

	def call(type, *args, &block)
		command = type.allocate()
		inject_requirements(command)
		command.initialize(@context, *args, &block)
		command.call()
	end

	def close()
		@context.close()
	end

	def inject_requirements(obj)
		type = obj.class
		type.requirements.each do |name|
			obj.instance_variable_set("@#{name}", get_requirement(name))
		end
	end

	def get_requirement(name)
		case name
		when :archive
			self
		when :context
			@context
		end
	end
end

module Injector
	def self.included(base)
		base.class_eval do
			@@requirements = []

			def self.inject(name)
				@@requirements.append(name)
			end

			def self.requirements
				@@requirements
			end
		end
	end
end

Attachment = Data.define(:name, :doc_id, :page, :size, :mtime)
Document = Data.define(:id, :title, :timestamp, :location, :last_moved, :taken)

DocumentAggregate = Data.define(:document, :attachments, :data)

AttachmentQueryMatch = Data.define(:document_id, :document_title, :page, :name)

module Logic

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
end

class Query
	include Injector
end

class Command
	include Injector
end

class ReadAttachmentData < Query
	inject(:context)

	def initialize(doc_id, name)

	end

	def call()

	end
end

class GetAttachmentById < Query
	inject(:context)

	def initialize(doc_id, name)

	end

	def call()

	end
end

class KeywordSearch < Query
	inject(:context)

	def initialize(keyword)

	end

	def call()

	end
end

class GetDocumentsByLocation < Query
	inject(:context)

	def initialize(location)

	end

	def call()

	end
end

class GetAttachmentsForDocument < Query
	inject(:context)

	def initialize(keyword)

	end

	def call()

	end
end

class ReadAttachmentData < Query
	inject(:context)

	def initialize(doc_id, name)

	end

	def call()

	end
end

class RenameAttachment < Command
	inject(:context)
	inject(:archive) 

	def initialize(doc_id, name)

	end

	def call()
		@archive.call()
		@archive.context()
	end
end

class MoveDocument < Command
	inject(:context)

	def initialize(doc_id, location)

	end

	def call()

	end
end

class SetDocumentTitle < Command
	inject(:content)

	def initialize(doc_id, title)

	end

	def call()

	end
end

class CreateNewDocument < Command
	inject(:content)

	def initialize(title)

	end

	def call()

	end
end

class CreateNewAttachment < Command
	inject(:content)

	def initialize(doc_id, name, page, data)

	end

	def call()

	end
end

class ReattachAttachment < Command
	inject(:content)

	def initialize(doc_id, att_name, new_doc_id)

	end

	def call()

	end
end

class WriteAttachmentDataToFile < Command
	inject(:content)

	def initialize(doc_id, name, filename)

	end

	def call()

	end
end

class CrateAttachmentFromFile < Command
	inject(:content)

	def initialize(doc_id, name, filename)

	end

	def call()

	end
end

class WriteAttachmentData < Command
	inject(:content)

	def initialize(doc_id, name, data)

	end

	def call()

	end
end

class DeleteAttachment < Command
	inject(:content)

	def initialize(doc_id, name)

	end

	def call()

	end
end
