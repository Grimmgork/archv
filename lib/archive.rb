class Archive

	def initialize(path)
		@context = Context.new(path)
	end

	def call(type, *args, &block)
		command = type.allocate()
		inject_requirements(command)
		command.initialize(@context, *args, &block)
		command.call()
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

module Injector
	def self.included(base)
		base.class_eval do
			@@requirements = []

			def self.inject(name)
				@@requirements.append(name)
			end

			def self.requirements
				@@requirements
			end
		end
	end
end