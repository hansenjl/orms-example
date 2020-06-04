require 'sqlite3'
require 'pry'
require 'faker'

DB = SQLite3::Database.new('db/twitter.db')
# DB = {
#   conn: SQLite3::Database.new('db/twitter.db')
# }
#globally accessible


DB.results_as_hash = true

require_relative '../lib/tweet.rb'

Tweet.make_table
#require_relative '../db/seed.rb'

Tweet.all
