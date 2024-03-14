require 'erb'

class Builder

	def tag(symbol, attributes={}, &block)
		unsafe "<#{symbol}#{hash_to_attributes(attributes)}>"
		instance_exec(&block) if block_given?
		unsafe "</#{symbol}>"
	end

	def inline(symbol, attributes={}, &block)
		unsafe "<#{symbol}#{hash_to_attributes(attributes)}></#{symbol}>"
	end

	def hash_to_attributes(hash)
		result = ""
		attributes = hash.keys.map do |name|
			value = hash[name]
			next if value == nil or value == ""
			result << " #{name.to_s.gsub('_', '-')}=\"#{CGI::escapeHTML(value)}\""
		end
		result
	end

	def unsafe(text)
		@stack.append(text)
	end

	def script(content)
		tag("script") do 
			@stack.append(CGI::escapeHTML(content))
		end
	end

	def text(text)
		@stack.append(CGI::escapeHTML(text || ""))
	end

	def span(text=nil, **attributes, &block)
		if block_given? or not text
			inline("span", attributes, &block)
		else
			inline("span", attributes) do
				text(text)
			end
		end
	end

	def a(**attributes, &block)
		inline("a", attributes, &block)
	end

	def p(**attributes, &block)
		tag("p", attributes, &block)
	end

	def method_missing(m, **attributes, &block)
		tag(m, attributes, &block)
	end

	def stack=(stack)
		@stack = stack
	end

	def stack
		@stack
	end

	def comp(type, *args, &block)
		comp = type.new(*args)
		comp.stack = @stack
		comp.instance_exec(&block) if block_given?
		comp.render
	end

	def self.run(type=nil, *args, &block)
		builder = Builder.new()
		builder.stack = []
		if type
			builder.comp(type, *args, &block)
		else
			builder.instance_exec(&block)
		end
		builder.stack
	end
end

class Component < Builder
	def initialize()
		@slots = {}
		@parameters = {}
	end

	def slot(name, &block)
		@slots[name] = block
	end

	def param(name, value)
		@parameters[name] = value
	end

	def render_slot(name)
		instance_exec(&@slots[name]) if @slots.key?(name)
	end
end

class RootComponent < Component
	def initialize(message)
		super()
		@message = message
	end

	def render
		html do
			head do
				text @message
			end
			body do
				render_slot :page
			end
		end
	end
end

puts(Builder.run do
	span "text", class: "kek"
	comp RootComponent, "Hello!" do
		slot :page do
			div class: "test asdf", hx_name: "kek" do
				text "kek!"
			end
		end
	end
end)