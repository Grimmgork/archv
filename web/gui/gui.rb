class Gui < Roda
	self.opts[:root] = "gui"

	plugin :public, root: 'static'
	plugin :render, escape: true
	plugin :halt
	plugin :error_handler

	error do |e|
		e.to_s
	end

	route do |r|
		archive = r.env['context']

		r.on "static" do
			r.public
		end

		r.get "index" do
			documents = archive.call(Archivum::Query::Document::Newest, 500)
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

		r.get "document", "create" do
			view "create_document"
		end

		r.post "document", "create" do
			title = r.params["title"]
			id = archive.call(Archivum::Command::Document::Create, title)
			r.halt(200, { 'HX-Location' => "/gui/document/#{id}" }, "")
		end

		r.post "document", Integer, "move" do |id|
			location = r.params["location"]
			archive.call(Archivum::Command::Document::Move, id, location)
			r.halt(200, { "HX-Location" => "/gui/document/#{id}" }, "")
		end

		r.post "document", Integer, "updateTitle" do |id|
			title = r.params["title"]
			archive.call(Archivum::Command::Document::UpdateTitle, id, title)
			r.halt(200, { "HX-Location" => "/gui/document/#{id}" }, "")
		end
	end
end