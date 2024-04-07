require_relative "../domain/models.rb"
require_relative "../domain/logic.rb"

class Command
	include Injector
end

class RenameAttachment < Command
	inject(:context)
	inject(:archive) 

	def initialize(doc_id, name)

	end

	def call()
		@archive.call()
		@archive.context()
	end
end

class MoveDocument < Command
	inject(:context)

	def initialize(doc_id, location)

	end

	def call()

	end
end

class SetDocumentTitle < Command
	inject(:content)

	def initialize(doc_id, title)

	end

	def call()

	end
end

class CreateNewDocument < Command
	inject(:content)

	def initialize(title)

	end

	def call()

	end
end

class CreateNewAttachment < Command
	inject(:content)

	def initialize(doc_id, name, page, data)

	end

	def call()

	end
end

class ReattachAttachment < Command
	inject(:content)

	def initialize(doc_id, att_name, new_doc_id)

	end

	def call()

	end
end

class WriteAttachmentDataToFile < Command
	inject(:content)

	def initialize(doc_id, name, filename)

	end

	def call()

	end
end

class CrateAttachmentFromFile < Command
	inject(:content)

	def initialize(doc_id, name, filename)

	end

	def call()

	end
end

class WriteAttachmentData < Command
	inject(:content)

	def initialize(doc_id, name, data)

	end

	def call()

	end
end

class DeleteAttachment < Command
	inject(:content)

	def initialize(doc_id, name)

	end

	def call()

	end
end
