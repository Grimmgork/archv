require 'roda'

require_relative "../lib/archive.rb"
require_relative "middleware/context_provider.rb"
require_relative "app.rb"

use ContextProvider
run App.app