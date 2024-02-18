require 'dotenv/load'
require './app.rb'

class ContextProvider
	def initialize(app)
		@app = app
	end

	def call(env)
		archive = Archive.new(ENV["DBPATH"])
		env["CONTEXT"] = archive
		begin
			res = @app.call(env)
		rescue
			archive.close()
			raise
		end
		archive.close()
		res
	end
end

use ContextProvider
run App.app