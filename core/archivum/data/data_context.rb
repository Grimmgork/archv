require "sqlite3"

class Archivum::Data::Context
	def initialize(path)
		@db = SQLite3::Database.open path
		@db.execute("PRAGMA journal_mode = DELETE;")
		@savepoint_counter = 0
		@transaction_mode = nil
	end

	def execute(query, *args, &block)
		result = []
		@db.execute(query, args) do |row|
			result << block.call(row)
		end
		result
	end

	def first(query, *args, &block)
		block_given? ? yield(@db.get_first_row(query, args)) : @db.get_first_row(query, args)
	end

	def transaction(mode=nil)
		if mode == :none or mode == nil
			return yield
		end

		# if a transaction is running, use a savepoint
		if @db.transaction_active?
			throw "cannot switch transaction mode from #{@transaction_mode} to #{mode} inside an active transaction!" if not nestable_transation_mode(@transaction_mode, mode)
			return savepoint() do
				yield
			end
		end

		@transaction_mode = mode
		@savepoint_counter = 0

		@db.transaction(@transaction_mode)
		result = nil
		begin
			result = yield
		rescue
			@db.rollback
			raise
		end
		@db.commit
		return result
	end

	def last_insert_row_id
		@db.last_insert_row_id
	end

	def close()
		@db.close()
	end

	private

	def nestable_transation_mode(parent, child)
		return true if parent == child
		return true if parent == :exclusive and child == :deferred
		return true if parent == :exclusive and child == :immediate
		return true if parent == :immediate and child == :deferred
		return false
	end
	
	def savepoint()
		name = "sf_#{@savepoint_counter}"
		@savepoint_counter = @savepoint_counter + 1

		@db.execute("SAVEPOINT #{name};")
		result = nil
		begin
			result = yield
		rescue
			@db.execute("ROLLBACK TRANSACTION TO SAVEPOINT #{name};")
			raise
		end

		@db.execute("RELEASE SAVEPOINT #{name};")
		return result
	end
end
