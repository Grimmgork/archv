
module Archivum::Command::Attachment::UpdateIndex
	module_function

	def transaction
		:immediate
	end

	def call(context, doc_id, name = nil)
		att_repo = context.call(Archivum::Command::RepositoryFactory, Archivum::Model::Attachment)
		doc_repo = context.call(Archivum::Command::RepositoryFactory, Archivum::Model::Document)

		attachment = att_repo.read(Archivum::Model::Attachment.new(name, doc_id, nil, nil, nil))
		if attachment
			document = nil
			if attachment.doc_id != nil
				document = doc_repo.read(Archivum::Model::Document.new(attachment.doc_id, nil, nil, nil, nil, nil))
			end

			data = context.call(Archivum::Query::Attachment::ReadData, attachment.doc_id, attachment.name)
			hasindex = context.data.execute("SELECT * FROM sqlar_fts WHERE attachment_name=? LIMIT 1;", name).first
			if hasindex
				context.data.execute("UPDATE sqlar_fts SET document_title=?, attachment_name=?, attachment_data=?;", 
					document ? document.title : nil, 
					"/#{attachment.doc_id}/#{attachment.name}", 
					data)
			else
				context.data.execute("INSERT INTO sqlar_fts(document_title, attachment_name, attachment_data) VALUES (?, ?, ?);", 
					document ? document.title : nil, 
					"/#{attachment.doc_id}/#{attachment.name}", 
					data)
			end
		else
			context.data.execute("DELETE FROM sqlar_fts WHERE attachment_name=?;", name)
		end
	end
end