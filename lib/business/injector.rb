module Injector

	def self.included(base)
		base.class_eval do
			@requirements = []
			@transaction_mode = :none

			def self.inject(name)
				@requirements << name 
			end

			def self.transaction(mode)
				@transaction_mode = mode
			end

			def self.transaction_mode
				return @transaction_mode
			end

			def self.requirements
				return @requirements
			end
		end
	end
end