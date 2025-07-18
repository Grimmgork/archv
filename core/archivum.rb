require_relative "archivum/require"

class Archivum::Archive
	def initialize(path)
		@data = Archivum::Data::Context.new(path)
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

	def repository(type)
		call(Archivum::Command::RepositoryFactory, type)
	end

	def close()
		@data.close()
	end
end
