require_relative '../lib/archive.rb'
require_relative './worker.rb'

class Workers

	def initialize()
		@workers = []
	end

	def worker(location, filenames, &block)
		@workers << Worker.new(location, filenames, &block)
	end

	def workers
		@workers
	end

	def self.configure(code)
		instance = Workers.new()
		instance.get_binding.eval(code)
		instance.workers
	end

	def get_binding
		binding
	end
end

# CONFIG
DATABASE = 'data.db'
WORK_DELAY = 1

code = File.read((File.dirname(__FILE__) + '/workers.rb'))
workers = Workers.configure(code)

# run each worker in new thread
threads = []
cancel = false
for worker in workers
	th = Thread.new(worker) do |worker|
		puts "starting worker ->"
		archive = Archive.new(DATABASE)
		while not cancel do
			worker.run(archive)
			sleep(WORK_DELAY)
		end
		archive.close()
	end
	threads.append(th)
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