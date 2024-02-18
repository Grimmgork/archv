require 'erb'

class Builder

	def tag(symbol, *args, &block)
		if block_given?
			raw "<#{symbol}>"
			instance_exec(&block)
			raw "</#{symbol}>"
		else
			raw "<#{symbol}>"
		end
	end

	def a(href, &block)

	end

	def div(&block)
		tag("div", &block)
	end

	def raw(text)
		@stack.append(text)
	end

	def esc(text)
		@stack.append(CGI::escapeHTML(text))
	end

	def p(&block)
		tag("p", &block)
	end

	def stack=(stack)
		@stack = stack
	end

	def indent=(indent)
		@indent = indent
	end

	def comp(type, &block)
		comp = type.new()
		comp.stack = @stack
		comp.indent = @indent
		comp.instance_exec(&block) if block_given?
		comp.render
	end

	def self.run(&block)
		builder = Builder.new()
		builder.stack = []
		builder.indent = 0
		builder.instance_exec(&block)
	end
end

class Component < Builder
	def initialize()
		@slots = {}
	end

	def slot(name, &block)
		@slots[name] = block
	end

	def render_slot(name)
		instance_exec(&@slots[name]) if @slots.key?(name)
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
					a "/test.html" do
						"klick me ..."
					end
				end
			end
 		end
	end
end

puts res