require 'roda'

module Archivum::Web end

require_relative "api/api.rb"
require_relative "gui/gui.rb"

class Archivum::Web::App < Roda

	route do |r|
		r.on "api" do
			r.run Archivum::Web::Api
		end

		r.on "gui" do
			r.run Archivum::Web::Gui
		end

		r.on "" do
			r.redirect "gui/index"
		end
	end
end