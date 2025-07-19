
module Archivum::Command::RepositoryFactory
	module_function

	def call(context, type)
		if type == Archivum::Model::Attachment
			to_row = Proc.new do |obj|
				[ "/#{obj.doc_id}/#{obj.name}", obj.page, obj.size, obj.mtime ]
			end
			from_row = Proc.new do |row|
				doc_id, name = row[0].split("/").reject { |s| s.nil? || s.empty? }
				Archivum::Model::Attachment.new(name, doc_id, row[1], row[2], row[3])
			end
			return Archivum::Data::Repository.new(context.data, "sqlar", [ "name", "page", "sz", "mtime" ], false, from_row, to_row)
		end

		if type == Archivum::Model::Document
			to_row = Proc.new do |obj|
				[ obj.id, obj.title, obj.timestamp, obj.location, obj.last_moved, obj.taken ]
			end
			from_row = Proc.new do |row|
				Archivum::Model::Document.new(row[0], row[1], row[2], row[3], row[4], row[5])
			end
			return Archivum::Data::Repository.new(context.data, "document", [ "id", "title", "timestamp", "location", "last_moved", "taken" ], true, from_row, to_row)
		end

		throw "No repository defined for type #{type}!"
	end
end