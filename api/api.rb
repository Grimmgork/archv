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
					docs = archive.get_document_where("id=?",id)
					if docs.length <= 0
						response.status = 404
						r.halt
					end
					docs[0]
				end

				archive.get_document_where("true")
			end

			r.on "attachment" do 
				r.id Integer do |id|
					attchments = archive.get_attachment_where("id=?", id)
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