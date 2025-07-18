
module Archivum::Command::Document::Delete
	module_function

	def transaction
		:immediate
	end

	def call(context, id)
		repo = context.repository(Archivum::Model::Document)
		repo.delete(Archivum::Model::Document.new(id, nil, nil, nil, nil, nil))
	end
end