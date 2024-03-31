


class Context
	def initialize()

	end

	def print_stuff()
		puts "Hello from context!"
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

class Query
	include Injector
end

class HelloWorld < Query
	def initialize(name)
		@name = name
	end

	def call()
		puts "Hello #{@name}!"
	end
end

class Command < Query
	inject(:context)
	inject(:archive)

	def initialize(arg1, arg2)
		@arg1 = arg1
		@arg2 = arg2
	end

	def call()
		@context.print_stuff()
		puts "CMD: #{@arg1} #{@arg2}"
		@archive.call(HelloWorld, "world")
	end
end

class Archive
	def initialize()
		@context = Context.new
	end

	def call(type, *args, &block)
		command = type.new(*args, &block)
		inject_requirements(command)
		command.call()
	end

	def inject_requirements(obj)
		type = obj.class
		type.requirements.each do |name|
			obj.instance_variable_set("@#{name}", get_requirement(name))
		end
	end

	def get_requirement(name)
		case name
		when :context
			@context
		when :archive
			self
		end
	end
end

archive = Archive.new()
archive.call(Command, "Hello", "World")
