require './tesseract.rb'

worker "ocr", "%.jpg", "%.png" do |context|
	unless context.attachments.any?
		raise "no suitable attachments for ocr on document #{context.document.id}!"
	end

	# write attachments data to tempfiles
  paths = context.attachments.map do |attachment|
		context.create_tempfile(extension: attachment.name, binmode: true) do |fh|
			context.read_attachment_data(attachment.name, fh)
	  end
	end

	# run tesseract on tempfiles
	tess = Tesseract.new(paths)
	tess_out = tess.run(lang: 'deu')
    
  # create attachment from result pdf file
	context.delete_attachment("ocr.pdf")
	context.create_attachment("ocr.pdf", 0, "#{tess_out}.pdf")

	# create attachments from result txt file
	context.delete_attachment("ocr.txt")
	context.create_attachment("ocr.txt", 0, "#{tess_out}.txt")

	# clean up
	context.ensure do
		tess.close
	end

	# move to archive
  "archive"
end
