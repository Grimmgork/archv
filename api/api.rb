require 'roda'
require_relative '../lib/business.rb'

# CONFIG
DATABASE = 'data.db'

class App < Roda
	plugin :json, classes: [Array, Hash, Document, Attachment]
	plugin :halt
	plugin :request_headers
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
							name = nil
							if /filename=([0-9a-zA-Z_\-.]+)/ =~ r.headers['HTTP_CONTENT_DISPOSITION']
								name = $1
							else
								name = "#{Time.now.to_i.to_s}.bin"
							end
							
							att_id = archive.create_attachment(name, page: page, doc_id: id, data: r.body.read)
							att_id.to_s
						end

						r.is do
							hash = JSON.parse request.body.read
							documents = archive.get_document_where("id=?", id)
							if documents.length <= 0
								r.halt(404)
							end
							document = documents[0]
							update_from_hash(document, hash, :title)
							archive.update_document(document)
							r.halt(200)
						end
					end
				end

				r.is "where" do
					archive.get_document_where(hash_query(r.params), r.params.values)
				end
			end

			r.on "attachment" do
				r.on Integer do |id|
					r.get do
						r.is do
							attchments = archive.get_attachment_where("id=?", id)
							if attachments.length <= 0
								response.status = 404
								r.halt
							end
							attachments[0]
						end
					end

					r.post do
						r.is do
							hash = JSON.parse request.body.read
							attachments = archive.get_attachment_where("id=?", id)
							if attachments.length <= 0
								r.halt(404)
							end
							attachment = attachments[0]
							update_from_hash(attachment, hash, :name, :page)
							archive.update_attachment(attachment)
							r.halt(200)
						end
					end
				end

				r.is "where" do
					archive.get_attachment_where(hash_query(r.params), r.params.values)
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
		expressions = []
		hash.keys.each { |key|
			expressions.append("#{key.to_s}=?")
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

Rack::Handler::WEBrick.run(App.freeze.app)