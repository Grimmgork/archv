require_relative 'data.db'

class DeleteAttachmentCommand
	def initialize(id)
		@id = id
	end

	def validate()
		throw "id must not be null!" if not @id
	end

	def run()

	end
end

class CreateAttachmentCommand
	def initialize(name)
		@name = name
	end

	def validate()
		throw "name must not be null or empty!" if not @name or @name == ""
	end

	def run()

	end
end

class UpdateAttachmentCommand
	def initialize(attachment)

	end

	def validate()

	end

	def run()

	end
end

class GetAttachmentsWhereQuery
	def initialize(query)
		@query = query
	end

	def validate()
		true
	end

	def run()
		@query
	end
end