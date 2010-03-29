puts "using sqlite3"

ActiveRecord::Base.establish_connection \
  :adapter => "sqlite3",
  :database => "tmp/acts_as_soft_deletable_plugin.sqlite3.db"
