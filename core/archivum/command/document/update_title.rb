
module Archivum::Command::Document::UpdateTitle
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id, title)
		repo = context.repository(Archivum::Model::Document)
		document = repo.read(Archivum::Model::Document.new(doc_id, nil, nil, nil, nil, nil))
		document = Archivum::Logic.update_document_title(document, title)
		repo.update(document)
	end
end