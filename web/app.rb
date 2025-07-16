require 'roda'

require_relative "api/api.rb"
require_relative "gui/gui.rb"

class App < Roda

	route do |r|
		r.on "api" do
			r.run Api
		end

		r.on "gui" do
			r.run Gui
		end

		r.on "" do
			r.redirect "gui/index"
		end
	end
end