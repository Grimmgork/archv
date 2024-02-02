require 'yaml'
require_relative '../lib/business.rb'
require_relative 'worker.rb'

# CONFIG
DATABASE = 'data.db'
WORK_DELAY = 1

def compile_workers(code)
	functions = []
	while m = code.match(/"([a-zA-Z_-]*)"\s+do\s+\|\s*([a-z_-]+)\s*,\s*([a-z_-]+)\s*\|(.+?)^end/m) do
		body = m[4]
		body.strip!
		code = m.pre_match + "######" + m.post_match
		functions.append("[\"#{m[1]}\", -> (#{m[2]}, #{m[3]}) {\n#{body}\n}]")
	end
	code += "\n[#{functions.join(",")}]"
	return code
end

def configure_workers(filename)
	code = compile_workers(File.read(filename))
	workers = []
	eval(code).each { |work|
 		workers.push(Worker.new(work[0], work[1]))
	}
	return workers
end

workers = configure_workers(File.dirname(__FILE__) + '/workers.rb')

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