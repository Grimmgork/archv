module Archivum end
module Archivum::Command end
module Archivum::Command::Attachment end
module Archivum::Command::Document end
module Archivum::Query end
module Archivum::Query::Attachment end
module Archivum::Query::Document end
module Archivum::Data end
module Archivum::Model end
module Archivum::Domain end

def require_relative_glob(glob)
	expanded_glob = File.expand_path(glob, File.dirname(__FILE__))
	files = Dir.glob(expanded_glob)
	if files.length == 0
		require expanded_glob
	else
		files.each do |file|
			require file unless File.directory?(file)
		end
	end
end

require_relative_glob "archivum/model/record"
require_relative_glob "archivum/model/*"
require_relative_glob "archivum/data/*"
require_relative_glob "archivum/domain/*"
require_relative_glob "archivum/command/*"
require_relative_glob "archivum/command/attachment/*"
require_relative_glob "archivum/command/document/*"
require_relative_glob "archivum/query/*"
require_relative_glob "archivum/query/attachment/*"
require_relative_glob "archivum/query/document/*"

class Archivum::Archive
	def initialize(path)
		@data = Archivum::Data::Context.new(path)
	end

	def call(type, *args, &block)
		transaction = type.transaction if type.respond_to?(:transaction)
		@data.transaction(transaction) do
			type.call(self, *args, &block)
		end
	end

	def data
		@data
	end

	def transaction(mode=nil)
		@data.transaction(mode) do
			yield
		end
	end

	def repository(type)
		call(Archivum::Command::RepositoryFactory, type)
	end

	def close()
		@data.close()
	end
end
