require 'tempfile'

class Tesseract
	def initialize(*filenames)
		file = Tempfile.new('ocr')
		file.write(filenames.join("\n"))
		file.close()
		@scanlist = file.path
	end

	def run(oem: 1, psm: 4, lang: 'eng')
		if not lang =~ /^[a-zA-Z0-9\-._]+$/
			throw "cannot use '#{lang}' as parameter!"
		end
		# run tesseract on scanlist
		res = system("tesseract #{@scanlist} #{@scanlist} --oem #{oem} --psm #{psm} -l #{lang} pdf txt")
		if res==nil or not res
			throw "an error occured while running tesseract!"
		end
		return @scanlist
	end

	def close()
		Dir.glob("#{@scanlist}*").each { |path|
			File.delete(path)
		}
	end
end

# USAGE:
# tess = Tesseract.new('scan_1.jpg', "scan_2.jpg")
# puts tess.run(lang: 'deu')
# tess.close()

# Tesseract.run() returns a output basepath:
# [basepath].txt
# [basepath].pdf