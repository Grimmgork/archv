require_relative "deamon/worker"

context = WorkerContext.new(nil, nil, nil)

filepath =  context.create_tempfile;
puts filepath

context.delete_file(filepath)

context.delete_tempfiles
