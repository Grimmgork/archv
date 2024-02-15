require 'erb'

class Component

	def initialize
		@stack = []
	end

	def erb(template)
		res = ERB.new(template).run(get_binding)
		@stack.push(res)
		res
	end

	def comp(component, &block)
		@stack.push(component)
		block.call
		# evaluate
		component = @stack.pop
		res = component.render()
		@stack.push(*res)
		@stack
	end

	def slot(name, &block)
		component = @stack.last
		@stack.push(name)
		block.call
		erbs = pop_until @stack do |value|
			value.is_a? Symbol
		end
		name = @stack.pop
		# evaluate
		component.instance_variable_set("@#{name}", erbs)
	end

	def pop_until(stack, &block)
		result = []
		while not block.call(stack.last) do
			result.unshift(stack.pop)
		end
		result
	end

	def finalize
		res = ""
		@stack.each { |item|
			res << item.to_s
		}
		res
	end
end

class Snippet < Component
	def initialize(&block)
		super()
		instance_eval(&block)
	end
end

class NameComponent < Component
	def initialize(name)
		super()
		@name = name
	end

	def render
		erb <<-ERB 
			<h1>Hello, <%= @name %>!</h1> 
		ERB
	end
end


class LayoutComponent < Component
	def initialize()
		super()
	end

	def render()
		erb <<-ERB
			<div>
				<p>Layout Component</p>
				<div>
					<%= @content %>
				</div>
				
			</div>
		ERB
	end
end

class RootComponent < Component
	def initialize()
		super
	end

	def render()
		erb <<-ERB
			<div>
				<h1>Main Layout!</h1>
			</div>
			<div>
		ERB
		comp LayoutComponent.new() do
			slot :content do
				erb "<div>test</div>\n"
			end
		end
		erb <<-ERB
			</div>
		ERB
	end
end


RootComponent.new().render() do |chunk| 
	puts chunk
end

kek = "lel"
Snippet.new do 
	erb "asdfgg"
	erb kek
end