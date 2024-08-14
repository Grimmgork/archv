require_relative "./data/data_context.rb"
require_relative "./data/repository.rb"
require_relative "./domain/domain.rb"
require_relative "./business/commands.rb"
require_relative "./business/queries.rb"

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