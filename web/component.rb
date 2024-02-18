require 'erb'

class Builder

	def tag(symbol, attributes={}, &block)
		if block_given?
			raw "<#{symbol} #{hash_to_attributes(attributes)}>"
			instance_exec(&block)
			raw "</#{symbol}>"
		else
			raw "<#{symbol} #{hash_to_attributes(attributes)}>"
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

	def raw(text)
		@stack.append(text)
	end

	def esc(text)
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

	def comp(type, &block)
		comp = type.new()
		comp.stack = @stack
		comp.instance_exec(&block) if block_given?
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
					a href: "/test.html" do
						esc "klick me ..."
					end
					div_lel lel: "asdf <>", class: ["asdf lel"]
				end
			end
 		end
	end
end

puts res