require_relative "domain.rb"

class GetAttachmentsWhereQuery
	attr_accessor query

	def run()
		@query
	end
end

class GetDocumentsWhereQuery
	attr_accessor query

	def run()
		@query
	end
end

class ReadAttachmentDataQuery
	attr_accessor id

	def run()
		
	end
end

class GetDocumentsFromLocationQuery
	attr_accessor location

	def run()

	end
end