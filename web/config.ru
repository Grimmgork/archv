require 'roda'
require 'json'

require_relative "../lib/archive.rb"

require_relative "middleware/context_provider.rb"
require_relative "api/api.rb"
require_relative "ui/ui.rb"

class App < Roda

	plugin :public, root: 'static'

	route do |r|

		r.on "" do
			r.redirect "ui"
		end

		r.on "static" do
			r.public
		end

		r.on "api" do
			r.run Api
		end

		r.on "ui" do
			r.run Ui
		end
	end
end

use ContextProvider
run App.app