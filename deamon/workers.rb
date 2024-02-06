require 'tempfile'
require './deamon/tesseract.rb'

"input" do |arch, doc|
	return "ocr"
end

"ocr" do |arch, doc|
  	attachments = arch.get_attachments_for_document(doc.id)

	# select suitable filetypes
	attachments = attachments.select { |attch|
		attch.name =~ /(?:\.jpg)|(?:\.png)|(?:\.jpeg)$/
	}

	# TODO Sort by Pages

	raise "no suitable attachments for document #{doc.id}" if attachments.length == 0

	# create temp files from data
  	paths = attachments.map { |attch|
		path = Dir::Tmpname.create(['attch', ".#{attch.name}"]) {}
		data = arch.read_attachment_data(attch.id)
		raise "attachments data is empty #{attch.id}!" if not data
		file = File.open(path, "wb")
		file.write(data)
		file.close()
		path
  	}

	puts paths

	# run tesseract on tempfiles
	tess = Tesseract.new(paths)
	out = tess.run(lang: 'deu')

	file = File.open("#{out}.pdf", "rb")
	arch.create_attachment("#{out}.pdf", data: file.read, doc_id: doc.id)
	file.close

	file = File.open("#{out}.txt", "rb")
	arch.create_attachment("#{out}.txt", data: file.read, doc_id: doc.id)
	file.close

	tess.close()
  	return "archive"
end
