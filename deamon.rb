require './lib/business.rb'
require './lib/worker.rb'

def compile_workers(code)
	# TODO check if contains placeholder "<-##o##->"
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

def load_workers(archive, filename)
	code = compile_workers(File.read(filename))
	workers = []
	eval(code).each { |work|
 		workers.push(Worker.new(archive, work[0], work[1]))
	}
	return workers
end


archive = Archive.new('data.db')
workers = load_workers(archive, 'workers.rb')

# run each worker in new thread
threads = []
cancel = false
for worker in workers
	th = Thread.new(worker) do |worker|
		while not cancel do
			worker.run()
			sleep(1)
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
archive.close()