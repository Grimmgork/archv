require 'tempfile'
require './tesseract.rb'
require '../lib/archive.rb'

worker "ocr", ["%.jpg", "%.png"] do |context|
	if context.attachments.length == 0
		raise "no suitable attachments for ocr on document #{doc.id}!"
	end

	# write attachments data to tempfiles
  	paths = context.attachments.map do |attch|
		path = Dir::Tmpname.create(['attch', ".#{attch.name}"]) {}
		fh = File.open(path, "wb")
		context.archive.call(ReadAttachmentData, context.document.id, attch.name, fh)
		fh.close()
		path
	end

	# run tesseract on tempfiles
	tess = Tesseract.new(paths)
	out = tess.run(lang: 'deu')
    
    # create attachment from result pdf file
	handle = File.open("#{out}.pdf", "rb")
	context.archive.call(DeleteAttachment, context.document.id, "ocr.pdf")
	context.archive.call(CreateAttachmentFromFileHandle, context.document.id, "ocr.pdf", 0, handle)
	handle.close()

	# create attachments from result txt file
	handle = File.open("#{out}.txt", "rb")
	context.archive.call(DeleteAttachment, context.document.id, "ocr.txt")
	context.archive.call(CreateAttachmentFromFileHandle, context.document.id, "ocr.txt", 0, handle)
	handle.close()

	# clean up
	tess.close()

	# move to archive
  	"archive"
end
