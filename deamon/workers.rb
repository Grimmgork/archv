require 'tempfile'

"input" do |arch, doc|
	return "ocr"
end

"ocr" do |arch, doc|
  	attachments = arch.get_attachments_for_document(doc.id)
  	attachments.each { |attch|
  		attch.data = arch.read_attachment_data(attch.id)
  	}

	# create temp files from data

	# run tesseract on tempfiles

	# create attachment
	# write resulting pdf temp file into database
  	return "archive"
end
