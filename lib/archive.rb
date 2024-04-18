require_relative "./data/context.rb"

require_relative "./business/commands.rb"
require_relative "./business/queries.rb"

class Archive

	def initialize(path)
		@context = Context.new(path)
	end

	def call(type, *args, &block)
		command = type.allocate()
		inject_requirements(command)
		command.send(:initialize, *args, &block)
		if type.transaction_mode == nil || type.transaction_mode == :none
			command.call()
		else
			@context.transaction(type.transaction_mode) do
				command.call()
			end
		end
	end

	def transaction(mode=nil)
		@context.transaction(mode) do
			yield
		end
	end

	def close()
		@context.close()
	end

	def inject_requirements(obj)
		type = obj.class
		type.requirements.each do |name|
			obj.instance_variable_set("@#{name}", get_requirement(name))
		end
	end

	def get_requirement(name)
		case name
		when :archive
			self
		when :context
			@context
		end
	end
end

