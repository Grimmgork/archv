class ContextProvider
	def initialize(app)
		@app = app
	end

	def call(env)
		archive = Archivum::Archive.new(ENV["DBPATH"])
		env['context'] = archive
		begin
			res = @app.call(env)
			archive.close()
			res
		rescue
			archive.close()
			raise
		end
	end
end