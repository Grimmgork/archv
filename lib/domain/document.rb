require_relative "./record.rb"

Document = Record.define(:id, :title, :timestamp, :location, :last_moved, :taken)