require 'rtesseract'

"input" do |arch, doc|
	puts "work!"
	return "ocr"
end

"ocr" do |arch, doc|
  	attachments = arch.get_attachments_for_document(doc.id)
  	attachments.each { |attch|
  		attch.data = arch.read_attachment_data(attch.id)
  	}
  	return "archive"
end
