class Workers

	def self.configure(&block)
		workers = []
		instance = Workers.new(workers)
		instance.instance_eval(&block)
		workers
	end

	def worker_file(path)
		code = File.read(path)
		eval(code, binding)
	end

	def worker(location, *filenames, &block)
		raise "invalid location name '#{location}'." unless location.match(/^[a-zA-Z0-9_.-]+$/)
		raise "worker for location '#{location}' is already defined." if @locations.include? location
		@locations << location
		@workers << Worker.new(location, filenames, &block)
	end

	private

	def initialize(workers)
		@workers = workers
		@locations = []
	end
end

class Archivum::Deamon
	def initialize(database, delay_seconds: 1, &block)
		@cancel = false
		@threads = []
		@delay_seconds = delay_seconds
		workers = Workers.configure(&block)
		run(database, workers)
	end

	def cancel
		@cancel = true
	end
	
	def wait
		@threads.each do |thread|
			thread.join
		end
	end

	private
	
	def run(database, workers)
		for worker in workers
			thread = Thread.new(worker) do |worker|
				puts "starting worker ->"
				archive = Archivum::Archive.new(database)
				while not @cancel do
					worker.run(archive)
					sleep(@delay_seconds)
				end
				archive.close
			end
			@threads << thread
		end
	end
end
