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