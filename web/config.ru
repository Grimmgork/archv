require 'roda'
require 'json'
require 'dotenv/load'

require_relative "../lib/archive.rb"



class ContextProvider
	def initialize(app)
		@app = app
	end

	def call(env)
		archive = Archive.new(ENV["DBPATH"])
		env["CONTEXT"] = archive
		begin
			res = @app.call(env)
			archive.close()
			res
		rescue
			archive.close()
			raise
		end
	end
end

class App < Roda
	plugin :json, classes: [Array, Hash, Document, Attachment, Integer]
	plugin :halt
	plugin :request_headers
	plugin :json_parser
	plugin :all_verbs
	plugin :public, root: 'static'
	plugin :environments
	plugin :streaming
	plugin :custom_block_results
	plugin :render, escape: true

	def mime_from_filename(filename)
		mimes = {
			"txt"  => "text/plain",
			"json" => "application/json",
			"csv"  => "text/csv",
			"jpg"  => "image/jpeg",
			"jpeg" => "image/jpeg",
			"png"  => "image/png",
			"pdf"  => "application/pdf",
		}

		ext = filename.split(".").last
		mimes[ext]
	end

	route do |r|
		archive = r.env["CONTEXT"]

		r.on 'static' do
			r.public # serve static files
		end

		r.on "" do
			r.redirect "ui"
		end

		r.get "api", "document", Integer do |id|
			document = archive.call(GetDocumentById, id)
			r.halt(404) if not document
			document.to_h
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

		r.post "api", "document", Integer, "attach" do |doc_id|
			page = r.params["page"].to_i
			if page == nil or page < 0
				page = 0
			end

			file = r.params["file"]
			data = file[:tempfile].read
			filename = file[:filename].force_encoding(Encoding::UTF_8)
			
			archive.transaction :immediate do
				archive.call(CreateNewAttachment, doc_id, filename, page)
				archive.call(WriteAttachmentData, doc_id, filename, data)
			end
		end

		r.get "api", "document", Integer, "attachment", String do |doc_id, att_name|
			r.halt(400) if not att_name
			attachment = archive.call(GetAttachmentByName, doc_id, att_name)
			r.halt(404) if not attachment
			attachment.to_h
		end

		r.get "api", "document", Integer, "attachment", String, "data" do |doc_id, att_name|
			attachment = archive.call(GetAttachmentByName, doc_id, att_name)
			r.halt(404) if not attachment
			data = archive.call(ReadAttachmentData, doc_id, att_name)
			headers = {
			 	"Content-Type" => mime_from_filename(attachment.name),
				"Content-Disposition" => "inline; filename=\"#{attachment.name}\""
			}
			r.halt(200, headers, data)
		end

		r.get "ui" do
			documents = archive.call(GetNewestDocuments, 10)
			view "index", locals: { 
				documents: documents
			}
		end

		r.get "ui", "document", Integer do |id|
			document = archive.call(GetDocumentById, id)
			r.halt(404) if not document
			attachments = archive.call(GetAttachmentsForDocument, id)

			view "document", locals: {
				document: document,
				attachments: attachments
			}
		end
	end
end

use ContextProvider
run App.app