require 'erb'

class Component

	def initialize
		@stack = []
	end

	def erb(template)
		res = ERB.new(template).run(get_binding)
		@stack.push(res)
	end

	def comp(component=nil)
		if not component
			# evaluate
			component = @stack.pop
			@stack.push(*component.render())
			return @stack
		end
		@stack.push(component)
	end

	def slot(name=nil)
		if not name
			erbs = pop_until @stack do |value|
				value.is_a? Symbol
			end
			name = @stack.pop
			# evaluate
			component = @stack.last
			component.instance_variable_set("@#{name}", erbs)
			return
		end
		@stack.push(name)
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

	def get_binding
		binding
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
				<p>layout</p>
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
		comp LayoutComponent.new()
			slot :content
				comp NameComponent.new("World")
			slot
		comp
		erb <<-ERB
			</div>
		ERB
	end
end


puts RootComponent.new().render()