require 'yaml'
require_relative '../lib/business.rb'
require_relative '../lib/worker.rb'

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

def configure_workers(archive, filename)
	code = compile_workers(File.read(filename))
	workers = []
	eval(code).each { |work|
 		workers.push(Worker.new(archive, work[0], work[1]))
	}
	return workers
end

archive = Archive.new(DATABASE)
manager = DocumentManager.new(archive)
workers = configure_workers(manager, File.dirname(__FILE__) + '/workers.rb')

# run each worker in new thread
threads = []
cancel = false
for worker in workers
	th = Thread.new(worker) do |worker|
		while not cancel do
			worker.run()
			sleep(WORK_DELAY)
		end
	end
	threads.append(th)
end

# Trap ^C 
Signal.trap("INT") do
	cancel=true
end

# Trap Kill
Signal.trap("TERM") do
	cancel=true
end

threads.each(&:join)