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

	# write attachments data to tempfiles
  	paths = attachments.map { |attch|
		path = Dir::Tmpname.create(['attch', ".#{attch.name}"]) {}
		arch.write_attachment_to_file(attch.id, fullpath: path)
		path
  	}

	# run tesseract on tempfiles
	tess = Tesseract.new(paths)
	out = tess.run(lang: 'deu')
        
    # load result files as attachments
	arch.create_attachment_from_file("#{out}.pdf", doc_id: doc.id, name: "ocr.pdf")
	arch.create_attachment_from_file("#{out}.txt", doc_id: doc.id, name: "ocr.txt")

	# clean up
	tess.close()
  	return "archive"
end
