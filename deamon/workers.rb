require 'tempfile'
require './tesseract.rb'
require '../lib/archive.rb'

worker "ocr", ["%.jpg", "%.png"] do |archive, document, attachments|
	if attachments.length == 0
		raise "no suitable attachments for ocr on document #{doc.id}!"
	end

	# write attachments data to tempfiles
  	paths = attachments.map do |attch|
		path = Dir::Tmpname.create(['attch', ".#{attch.name}"]) {}
		fh = File.open(path, "wb")
		archive.call(WriteAttachmentDataToFileHandle, document.id, attch.name, fh)
		fh.close()
		path
	end

	# run tesseract on tempfiles
	tess = Tesseract.new(paths)
	out = tess.run(lang: 'deu')
    
    # create attachment from result pdf file
	handle = File.open("#{out}.pdf", "rb")
	archive.call(DeleteAttachment, document.id, "ocr.pdf")
	archive.call(CreateAttachmentFromFileHandle, document.id, "ocr.pdf", 0, handle, true)
	handle.close()

	# create attachments from result txt file
	handle = File.open("#{out}.txt", "rb")
	archive.call(DeleteAttachment, document.id, "ocr.txt")
	archive.call(CreateAttachmentFromFileHandle, document.id, "ocr.txt", 0, handle, true)
	handle.close()

	# clean up
	tess.close()
  	"archive"
end

# TODO?
# context.create_attachment_from_file(filename)
# context.create_attachment(name, data)
# context.write_attachment_data(name, data)
# context.delete_attachment(name)
# context.rename_attachment(name, name)
# context.update_document_title(title)