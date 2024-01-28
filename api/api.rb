require 'roda'
require_relative '../lib/business.rb'

# CONFIG
DATABASE = 'data.db'

class App < Roda
	plugin :json
	route do |r|
		r.on "doc" do
			r.is Integer do |id|
				arch = Archive.new(DATABASE)
				doc = arch.get_document(id)
				arch.close()
				doc.to_h
			end
		end
	end
end

Rack::Handler::WEBrick.run(App.freeze.app)