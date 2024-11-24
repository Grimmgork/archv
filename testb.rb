module ModuleA
	module_function
	
	def greet
		puts "Hello there"
	end
end

module ModuleB
	module_function

	def greet
		ModuleA.greet
	end
end

ModuleB.greet