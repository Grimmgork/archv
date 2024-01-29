require_relative 'data.db'

class DeleteAttachmentCommand
	attr_accessor id

	def run()

	end
end

class CreateAttachmentCommand
	attr_accessor name

	def run()

	end
end

class EditAttachmentCommand
	attr_accessor id
	attr_accessor name
	attr_accessor page

	def run()

	end
end

class WriteAttachmentDataCommand
	attr_accessor id
	attr_accessor blob

	def run()

	end
end

class EditDocumentCommand
	attr_accessor id
	attr_accessor title

	def run()

	end
end

class MoveDocumentCommand
	attr_accessor location

	def run()

	end
end

cmd = DeleteAttachmentCommand.new()
cmd.id = 1
cmd.run()