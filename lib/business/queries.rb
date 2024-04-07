class Query
	include Injector
end

class ReadAttachmentData < Query
	inject(:context)

	def initialize(doc_id, name)

	end

	def call()

	end
end

class GetAttachmentById < Query
	inject(:context)

	def initialize(doc_id, name)

	end

	def call()

	end
end

class KeywordSearch < Query
	inject(:context)

	def initialize(keyword)

	end

	def call()

	end
end

class GetDocumentsByLocation < Query
	inject(:context)

	def initialize(location)

	end

	def call()

	end
end

class GetAttachmentsForDocument < Query
	inject(:context)

	def initialize(keyword)

	end

	def call()

	end
end

class ReadAttachmentData < Query
	inject(:context)

	def initialize(doc_id, name)

	end

	def call()

	end
end