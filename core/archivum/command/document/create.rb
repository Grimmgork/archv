
module Archivum::Command::Document::Create
	module_function

	def transaction
		:immediate
	end

	def call(context, title, location = "new")
		repo = context.repository(Archivum::Model::Document)
		document = Archivum::Logic.create_new_document(title, location, Time.now.to_i)
		repo.insert(document)
	end
end