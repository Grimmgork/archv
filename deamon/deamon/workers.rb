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