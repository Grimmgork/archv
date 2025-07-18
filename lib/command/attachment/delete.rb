
module Archivum::Command::Attachment::Delete
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id, name)
		repo = context.repository(Archivum::Model::Attachment)
		repo.delete(Archivum::Model::Attachment.new(name, doc_id, nil, nil, nil))
	end
end