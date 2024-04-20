require 'tempfile'
require './worker.rb'
require './tesseract.rb'

define("ocr", ["%.jpg", "%.png"]) do |archive, document, attachments|
	if attachments.length == 0
		raise "no suitable attachments for ocr on document #{doc.id}!"
	end

	# write attachments data to tempfiles
  	paths = attachments.map do |attch|
		path = Dir::Tmpname.create(['attch', ".#{attch.name}"]) {}
		archive.call(WriteAttachmentToFile, attch.id, path)
		path
	end

	# run tesseract on tempfiles
	tess = Tesseract.new(paths)
	out = tess.run(lang: 'deu')
        
    # create attachments from result files
	archive.call(CreateAttachmentFromFile, "#{out}.pdf", document.id, "ocr.pdf")
	archive.call(CreateAttachmentFromFile, "#{out}.txt", document.id, "ocr.txt")

	# clean up
	tess.close()
  	return "archive"
end