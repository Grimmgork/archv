
module Archivum::Command::Attachment::WriteData
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id, name, data)
		repo = context.repository(Archivum::Model::Attachment)
		attachment = repo.read(Archivum::Model::Attachment.new(name, doc_id, nil, nil, nil))
		throw "attachment with name #{name} does not exist for document with id #{doc_id}!" if not attachment
		context.data.execute("UPDATE sqlar SET data=?, sz=? WHERE name=?;", data, data.length, "/#{doc_id}/#{name}")
		context.call(Archivum::Command::Attachment::UpdateIndex, doc_id, name)
	end
end