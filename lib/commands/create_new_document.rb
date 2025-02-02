require_relative "../domain/logic.rb"

module CreateNewDocument
	module_function

	def transaction
		:immediate
	end

	def call(context, title, location)
		repo = context.call(RepositoryFactory, Document)
		attachment = Logic.create_new_document(title, location || "new")
		repo.insert(attachment)
	end
end