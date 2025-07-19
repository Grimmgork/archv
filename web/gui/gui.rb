module Archivum::Web end

class Archivum::Web::Gui < Roda
	self.opts[:root] = "gui"

	plugin :all_verbs
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

		r.post "document", Integer, "attachment" do |id|
			file = r.params["data"]
			r.halt(400) unless file

			name = r.params["name"]
			name = file[:filename] if name.empty?
			page = r.params["page"] || 0

			archive.call(Archivum::Command::Attachment::CreateFromFileHandle, id, name, page, file[:tempfile])
			r.halt(200, { "HX-Location" => "/gui/document/#{id}" }, "")
		end

		r.delete "document", Integer, "attachment", String do |id, name|
			archive.call(Archivum::Command::Attachment::Delete, id, name)
			r.halt(200, { "HX-Location" => "/gui/document/#{id}" }, "")
		end

		r.delete "document", Integer do |id|
			archive.call(Archivum::Command::Document::Delete, id)
			r.halt(200, { "HX-Location" => "/gui/index" }, "")
		end
	end
end