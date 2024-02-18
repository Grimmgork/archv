require 'erb'

class Builder

	def tag(symbol, attributes={}, &block)
		if block_given?
			unsafe "<#{symbol} #{hash_to_attributes(attributes)}>"
			instance_exec(&block)
			unsafe "</#{symbol}>"
		else
			unsafe "<#{symbol} #{hash_to_attributes(attributes)}>"
		end
	end

	def hash_to_attributes(hash)
		result = ""
		attributes = hash.keys.map do |name|
			value = hash[name]
			next if value == nil or value == ""
			"#{name}=\"#{CGI::escapeHTML(value)}\""
		end
		attributes.compact.join(" ")
	end

	def unsafe(text)
		@stack.append(text)
	end

	def text(text)
		@stack.append(CGI::escapeHTML(text))
	end

	def p(**attributes, &block)
		method_missing("p", **attributes, &block)
	end

	def method_missing(m, **attributes, &block)
		classes = m.to_s.split("_")
		name = classes[0]
		classes.shift

		classes += attributes[:class] if attributes[:class] != nil
		attributes[:class] = "#{classes.join(" ")}"

		tag(name, attributes, &block)
	end

	def stack=(stack)
		@stack = stack
	end

	def comp(type, *args, &block)
		comp = type.new(*args)
		comp.stack = @stack
		comp.instance_exec(&block) if block_given?
		comp.render
	end

	def self.run(&block)
		builder = Builder.new()
		builder.stack = []
		res = builder.instance_exec(&block)
		res.join("\n")
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

res = Builder.run do 
	comp RootComponent, "Hello there!" do
		slot :body do
			a href: "link.html" do
				text "klick me ..."
			end
			div_lel lel: "asdf <>", class: ["asdf lel"]
		end
	end
end

puts res