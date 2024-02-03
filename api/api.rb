require 'roda'
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
							documents = archive.get_document_where("id=?",id)
							if documents.length <= 0
								r.halt(404)
							end
							documents[0]
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
							documents = archive.get_document_where("id=?", id)
							if documents.length <= 0
								r.halt(404)
							end
							document = documents[0]
							update_from_hash(document, r.params, :title)
							archive.update_document(document)
							r.halt(200)
						end
					end
				end

				r.is "where" do
					sql = nil
					begin
						sql = hash_query(r.params)
					rescue
						r.halt(400)
					end
					archive.get_document_where(sql, r.params.values)
				end
			end

			r.on "attachment" do
				r.on Integer do |id|
					r.get do
						r.is do
							attachments = archive.get_attachment_where("id=?", id)
							if attachments.length <= 0
								response.status = 404
								r.halt
							end
							attachments[0]
						end

						r.is "data" do
							attachments = archive.get_attachment_where("id=?", id)
							if attachments.length <= 0
								response.status = 404
								r.halt
							end
							attachment = attachments[0]
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
							attachments = archive.get_attachment_where("id=?", id)
							if attachments.length <= 0
								r.halt(404)
							end
							attachment = attachments[0]
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

				r.is "where" do
					sql = nil
					begin
						sql = hash_query(r.params)
					rescue
						r.halt(400)
					end
					archive.get_attachment_where(sql, r.params.values)
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

	def hash_query(hash)
		return "true" if hash.keys.length == 0
		expressions = []
		hash.keys.each { |key|
			str = key.to_s
			raise "invalid name!" if not str.match(/^[a-zA-Z\-_]+$/) 
			expressions.append("#{str}=?")
		}
		return expressions.join(" AND ")
	end

	def update_from_hash(entity, hash, *properties)
		properties.each { |prop|
			entity.send(prop, hash[prop.so_s]) if hash.contains?(prop.to_s)
		}
		entity
	end
end