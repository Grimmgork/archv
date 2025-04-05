class Api < Roda

	plugin :json, classes: [Array, Hash, Document, Attachment, Integer]
	plugin :request_headers
	plugin :json_parser

	plugin :streaming
	plugin :custom_block_results
	plugin :all_verbs
	plugin :halt
	
	plugin :environments

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
		archive = r.env['context']

	r.post "document", Integer, "move" do |id|
		location = r.params["location"]
		if not location
			r.halt(400)
		end
		archive.call(MoveDocument, id, location)
		r.halt(200)
	end

	r.post "document", "create" do
		title = r.params["title"]
		archive.call(CreateNewDocument, title)
	end

	r.post "document", Integer, "attach" do |doc_id|
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

	r.get "document", Integer, "attachment", String do |doc_id, att_name|
		r.halt(400) if not att_name
		attachment = archive.call(GetAttachmentByName, doc_id, att_name)
		r.halt(404) if not attachment
		attachment.to_h
	end

	r.get "document", Integer, "attachment", String, "data" do |doc_id, att_name|
		attachment = archive.call(GetAttachmentByName, doc_id, att_name)
		r.halt(404) if not attachment
		data = archive.call(ReadAttachmentData, doc_id, att_name)
		headers = {
			"Content-Type" => mime_from_filename(attachment.name),
			"Content-Disposition" => "inline; filename=\"#{attachment.name}\""
		}
		r.halt(200, headers, data)
	end
	end
	
end