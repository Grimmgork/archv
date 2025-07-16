
module Archivum::Command::Attachment::Rename
	module_function

	def transaction 
		:immediate
	end

	def call(context, doc_id, from, to)
		attachments = context.call(AttachmentsForDocument, doc_id)
		repo = context.call(RepositoryFactory, Archivum::Model::Attachment)
		attachment = Archivum::Logic.rename_attachment(attachments, from, to)
		repo.update(attachment)
	end
end