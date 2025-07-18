require 'roda'
require 'dotenv/load'

$LOAD_PATH.unshift(File.expand_path("../core", __dir__))
$LOAD_PATH.unshift(File.expand_path("../deamon", __dir__))

require 'archivum'
require 'deamon'

require_relative "middleware/context_provider"
require_relative "app"
require_relative "util/tesseract"

deamon = Archivum::Deamon.new(ENV["DBPATH"]) do 
	worker_file "worker/ocr.rb"
end

at_exit do
	deamon.cancel
	deamon.wait
end

use ContextProvider
run App.app
