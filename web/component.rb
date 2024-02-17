require 'erb'

class Builder
	def div(&block)
		@stack.append "<div>"
		instance_exec(&block)
		@stack.append "</div>"
	end

	def raw(text)
		@stack.append(text)
	end

	def esc(text)
		@stack.append(CGI::escapeHTML(text))
	end

	def stack=(stack)
		@stack = stack
	end

	def comp(type, &block)
		comp = type.new()
		comp.stack = @stack
		comp.instance_exec(&block)
		comp.render
	end

	def self.run(&block)
		builder = Builder.new()
		builder.stack = []
		builder.instance_exec(&block)
	end
end

class Component < Builder
	def initialize()
		@slots = {}
		super
	end

	def slot(name, &block)
		@slots[name] = block
	end

	def render_slot(name)
		instance_exec(&@slots[name])
	end
end

class RootComponent < Component
	def initialize()
		super
	end

	def render
		raw "start"
		render_slot :content
		raw "end"
	end
end


res = Builder.run do 
 	a = "kek"
 	esc a
 	div do
		raw "hello world!"
 		div do
 			comp RootComponent do
				slot :content do
					raw "content"
				end
 			end
 		end
	end
end

puts res