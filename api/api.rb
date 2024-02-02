require 'roda'
require_relative '../lib/business.rb'

# CONFIG
DATABASE = 'data.db'

class App < Roda
	plugin :json, classes: [Array, Hash, Document, Attachment]
	route do |r|
		new_archive() do |archive|
			r.on "document" do
				r.is Integer do |id|
					r.on "move" do 
						"KEKEKEKEEKE"
					end

					r.get do 
						documents = archive.get_document_where("id=?",id)
						if documents.length <= 0
							response.status = 404
							r.halt
						end
						documents[0]
					end
				end

				r.on "where" do
					archive.get_document_where("true")
				end
			end

			r.on "attachment" do
				r.on Integer do |id|
					attchments = archive.get_attachment_where("id=?", id)
					if attachments.length <= 0
						response.status = 404
						r.halt
					end
					attachments[0]
				end

				r.on "where" do
					archive.get_document_where("true")
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
end

Rack::Handler::WEBrick.run(App.freeze.app)