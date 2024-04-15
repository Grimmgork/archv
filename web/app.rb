require 'roda'
require 'json'
require 'htmplt'
require '../lib/archive.rb'

# CONFIG
class App < Roda
	plugin :json, classes: [Array, Hash, Document, Attachment, Integer]
	plugin :halt
	plugin :request_headers
	plugin :json_parser
	plugin :all_verbs
	plugin :public, root: 'static'
	plugin :environments
	route do |r|
		archive = r.env["CONTEXT"]

		r.on 'static' do
			r.public # serve static files
		end

		r.get "api", "document", Integer do |id|
			document = archive.call(GetDocumentById, id)
			r.halt(404) if not document
			document.to_h
		end

		r.post "api", "document", Integer do |id|
			throw "not implemented!" # TODO
		end

		r.post "api", "document", Integer, "move" do |id|
			location = r.params["location"]
			if not location
				r.halt(400)
			end
			archive.call(MoveDocument, id, location)
			r.halt(200)
		end

		r.post "api", "document", "create" do
			title = r.params["title"]
			archive.call(CreateNewDocument, title)
		end

		r.post "api", "document", Integer, "attach" do |id|
			page = r.params["page"].to_i
			if page == nil or page < 0
				page = 0
			end

			file = r.params["file"]
			data = file[:tempfile].read
			name = file[:filename].force_encoding(Encoding::UTF_8)
			
			archive.call(CreateNewAttachment, id, name, page)
			# TODO write attachment data
		end

		r.get "api", "document", Integer, "attachment", String do |doc_id, att_name|
			r.halt(400) if not att_name
			attachment = archive.call(GetAttachmentByName, doc_id, att_name)
			r.halt(404) if not attachment
			attachment.to_h
		end

		r.get "api", "document", Integer, "attachment", String, "data" do |doc_id, att_name|
			attachment = archive.get_attachment_by_id(id)
			r.halt(404) if not attachment
			data = archive.read_attachment_data(id)
			headers = { 
				"Content-Type" => "application/octet-stream",
				"Content-Disposition" => "attachment; filename=\"#{attachment.name}\""
			}
			r.halt(200, headers, data)
		end

		r.post "api", "attachment", Integer do |id|
			attachment = archive.get_attachment_by_id(id)
			r.halt(404) if not attachment
			update_from_hash(attachment, r.params, [:name, :page])
			archive.update_attachment(attachment)
			r.halt(200)
		end

		r.get "ui" do
			Builder.run do
				html do
					head do
						link rel: "stylesheet", href: "/static/style.css"
					end
					body do
						script src: "https://unpkg.com/htmx.org@1.9.11"
						h1 do
							text "Hello world!"
						end
						div do
							form do
								text "name: "
								input type: "text", name: "name"
								text "email: "
								input type: "email", name: "email" 
							end
						end
					end
				end
			end
		end

		r.post "ui", "contacts" do
			Builder.run do
				div do
					b do
						text "thanks for clicking the button!"
					end
				end
			end
		end
	end

	def update_from_hash(entity, hash, properties)
		properties.each do |prop|
			if hash.key?(prop.to_s)
				entity[prop] = hash[prop.to_s]
			end
		end
		entity
	end
end