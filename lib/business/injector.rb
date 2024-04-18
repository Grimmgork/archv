module Injector
	
	def self.included(base)
		base.class_eval do
			@@requirements = []
			@@transaction_mode = :deferred

			def self.inject(name)
				@@requirements.append(name)
			end

			def self.transaction(mode)
				@@transaction_mode = mode
			end

			def self.transaction_mode
				@@transaction_mode
			end

			def self.requirements
				@@requirements
			end
		end
	end
end