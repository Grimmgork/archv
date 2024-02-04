require 'roda'
require 'json'
require_relative '../lib/business.rb'

# CONFIG
DATABASE = 'data.db'

class App < Roda
	plugin :json, classes: [Array, Hash, Document, Attachment]
	plugin :halt
	plugin :request_headers
	plugin :json_parser
	route do |r|
		new_archive() do |archive|
			r.on "document" do 
				r.on Integer do |id|
					r.get do
						r.is do
							document = archive.get_document_by_id(id)
							r.halt(404) if not document
							document
						end
					end

					r.post do
						r.is "move" do
							location = r.params["location"]
							if not location
								r.halt(400)
							end
							archive.move_document(id, location)
							r.halt(200)
						end

						r.is "attach" do 
							page = r.params["page"].to_i
							if page == nil or page < 0
								page = 0
							end

							file = r.params["file"]
							name = file[:filename].force_encoding(Encoding::UTF_8)

							att_id = archive.create_attachment(name, page: page, doc_id: id, data: file[:tempfile].read)
							att_id.to_s
						end

						r.is do
							document = archive.get_document_by_id(id)
							r.halt(404) if not document
							update_from_hash(document, r.params, :title)
							archive.update_document(document)
							r.halt(200)
						end
					end
				end

				r.is "query" do
					query = parse_simple_query(r.params)
					archive.get_documents_where(query)
				end
			end

			r.on "attachment" do
				r.on Integer do |id|
					r.get do
						r.is do
							attachment = archive.get_attachment_by_id(id)
							r.halt(404) if not attachment
							attachment
						end

						r.is "data" do
							attachment = archive.get_attachment_by_id(id)
							r.halt(404) if not attachment
							data = archive.read_attachment_data(id)
							headers = { 
								"Content-Type" => "application/octet-stream",
								"Content-Disposition" => "attachment; filename=\"#{attachment.name}\""
							}
							r.halt(200, headers, data)
						end
					end

					r.post do
						r.is do
							attachment = archive.get_attachment_by_id(id)
							r.halt(404) if not attachment
							update_from_hash(attachment, r.params, :name, :page)
							archive.update_attachment(attachment)
							r.halt(200)
						end
					end

					r.delete do 
						r.is do
							archive.delete_attachment(id)
							r.halt(200)
						end
					end
				end

				r.is "query" do
					query = parse_simple_query(r.params)
					archive.get_attachments_where(query)
				end
			end
		end
	end

	def new_archive()
		archive = Archive.new(DATABASE)
		begin 
			result = yield(archive)
		rescue
			archive.close()
			raise
		end
		archive.close()
		return result
	end

	def parse_simple_query(params)
		if params["where"].class == String
			params["where"] = JSON.parse(params["where"])
		end
		if params["sort"].class == String
			params["sort"] = JSON.parse(params["sort"])
		end
		if params["skip"].class == String
			params["skip"] = JSON.parse(params["skip"])
		end
		if params["take"].class == String
			params["take"] = JSON.parse(params["take"])
		end
		params
	end

	def update_from_hash(entity, hash, *properties)
		properties.each { |prop|
			entity.send(prop, hash[prop.so_s]) if hash.contains?(prop.to_s)
		}
		entity
	end
end