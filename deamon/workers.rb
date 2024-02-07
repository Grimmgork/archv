require 'tempfile'
require './deamon/tesseract.rb'

"input" do |arch, doc|
	return "ocr"
end

"ocr" do |arch, doc|
	attachments = arch.get_attachments_where({ 
		"where" => ["and", 
			["eq", ["prop", "doc_id"], doc.id],
			["or", 
				["like", ["prop", "name"], "%.jpg"], 
				["like", ["prop", "name"], "%.jpeg"], 
				["like", ["prop", "name"], "%.png"]
			]
		],
		"sort" => { "page" => true }
	})

	if attachments.length == 0
		raise "no suitable attachments for ocr on document #{doc.id}!"
	end

	# create temp files from data
  	paths = attachments.map { |attch|
		path = Dir::Tmpname.create(['attch', ".#{attch.name}"]) {}
		data = arch.read_attachment_data(attch.id)
		if not data
			raise "attachments data is empty #{attch.id}!"
		end
		file = File.open(path, "wb")
		file.write(data)
		file.close()
		path
  	}

	# run tesseract on tempfiles
	tess = Tesseract.new(paths)
	out = tess.run(lang: 'deu')
        
    # load result files into database
	file = File.open("#{out}.pdf", "rb")
	arch.create_attachment("#{out}.pdf", data: file.read, doc_id: doc.id)
	file.close

	file = File.open("#{out}.txt", "rb")
	arch.create_attachment("#{out}.txt", data: file.read, doc_id: doc.id)
	file.close

	# clean up
	tess.close()
  	return "archive"
end
