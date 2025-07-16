module Archivum
  module Command
    module Attachment 
		end
		module Document 
		end
  end
  module Query
		module Attachment 
		end
		module Document 
		end
  end
  module Domain 
  end
  module Model 
  end
  module Data 
  end
end

def require_relative_glob(glob)
	Dir.glob(File.expand_path(glob, File.dirname(__FILE__))).each do |file|
		require file unless File.directory?(file)
	end
end

require_relative "model/record.rb"
require_relative_glob "model/*"
require_relative_glob "data/*"
require_relative_glob "domain/*"
require_relative_glob "command/*"
require_relative_glob "command/attachment/*"
require_relative_glob "command/document/*"
require_relative_glob "query/*"
require_relative_glob "query/attachment/*"
require_relative_glob "query/document/*"
