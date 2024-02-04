require './lib/business.rb'
require 'rtesseract'

"input" do |arch, doc|
	return "ocr"
end

"ocr" do |arch, doc|
	attachments = arch.get_attachments_for_document(doc.id)
	return "archive"
end
