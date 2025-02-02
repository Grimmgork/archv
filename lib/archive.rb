require_relative "data/data_context.rb"
require_relative "data/repository.rb"
require_relative "domain/attachment.rb"
require_relative "domain/document.rb"

def require_relative_glob(glob)
	Dir.glob(File.expand_path(glob, File.dirname(__FILE__))).each do |file|
		require file
	end
end

require_relative_glob "commands/*"
require_relative_glob "queries/*"

class Archive

	def initialize(path)
		@data = DataContext.new(path)
	end

	def call(type, *args, &block)
		transaction = type.transaction if type.respond_to?(:transaction)
		@data.transaction(transaction) do
			type.call(self, *args, &block)
		end
	end

	def data
		@data
	end

	def transaction(mode=nil)
		@data.transaction(mode) do
			yield
		end
	end

	def close()
		@data.close()
	end
end