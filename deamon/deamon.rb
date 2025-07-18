require_relative '../lib/archive.rb'
require_relative './worker.rb'

class Workers

	def initialize(workers)
		@workers = workers
		@locations = []
	end

	def worker(location, *filenames, &block)
		raise "invalid location name '#{location}'." unless location.match(/^[a-zA-Z0-9_.-]+$/)
		raise "worker for location '#{location}' is already defined." if @locations.include? location
		@locations << location
		@workers << Worker.new(location, filenames, &block)
	end

	def self.configure(code)
		workers = []
		instance = Workers.new(workers)
		instance.get_binding.eval(code)
		workers
	end

	def get_binding
		binding
	end
end

# CONFIG
DATABASE = '../web/data.db'
WORK_DELAY = 1

# configure workers from a file
code = File.read((File.dirname(__FILE__) + '/workers.rb'))
workers = Workers.configure(code)

# run each worker in new thread
threads = []
cancel = false
for worker in workers
	thread = Thread.new(worker) do |worker|
		puts "starting worker ->"
		archive = Archivum::Archive.new(DATABASE)
		while not cancel do
			worker.run(archive)
			sleep(WORK_DELAY)
		end
		archive.close()
	end
	threads.append(thread)
end

# Trap ^C 
Signal.trap("INT") do
	cancel=true
	puts "shutting down ..."
end

# Trap Kill
Signal.trap("TERM") do
	cancel=true
	puts "shutting down ..."
end

threads.each(&:join)
puts "bye!"