class Gui < Roda
	self.opts[:root] = "gui"

	plugin :public, root: 'static'
	plugin :render, escape: true

	route do |r|
		archive = r.env['context']

		r.on "static" do
			r.public
		end

		r.get "index" do
			documents = archive.call(Archivum::Query::Document::Newest, 10)
			view "index", locals: { 
				documents: documents
			}
		end

		r.get "document", Integer do |id|
			document = archive.call(Archivum::Query::Document::ById, id)
			r.halt(404) if not document
			attachments = archive.call(Archivum::Query::Document::Attachments, id)

			view "document", locals: {
				document: document,
				attachments: attachments
			}
		end
	end
end