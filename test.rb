
module DomainLogic
	def domain_logic_to_modify_document
		puts "domain_logic_to_modify_document"
	end
end

module Command
	def transaction(mode)
		puts "init!"
		@transaction_mode = mode
	end

	def transaction_mode
		@transaction_mode
	end
end

module GetDocumentById
	extend Command
	extend DomainLogic
	transaction(:defered)
	module_function

	def run(context, args)
		# id = context.call(ASDFG, args)
		puts context.data
		domain_logic_to_modify_document
		kek
		context.call(Test)
	end

	def kek
		puts "asdad"
	end
end

module Test
	extend Command
	extend DomainLogic
	transaction(:immediate)
	module_function

	def run(context)
		puts "hello from Test command!"
	end
end

class Archive
	def initialize

	end

	def call(name, *args)
		kek = name.transaction_mode if name.respond_to?(:tr_ansactionmodea)
		puts kek
		name.run(self, *args)
	end

	def data()
		"data"
	end
end

Archive.new.call(GetDocumentById, "kek")
