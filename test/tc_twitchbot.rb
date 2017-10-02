require 'test/unit'
require '../lib/PerraldBot/Twitch'
require '../lib/PerraldBot/DB_Commands'

class TestTwitchBot < Test::Unit::TestCase
	
	def setup
		@db = SQLite3::Database.new "../config/PerraldBot.db"
		
		#User TABLE
		@db.execute "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, username TEXT, points INT, created BIGINT, last_active BIGINT, admin INT, bio TEXT)"
		@db.execute "CREATE UNIQUE INDEX IF NOT EXISTS username ON users (username)"
		
		#Item Tables
		@db.execute "CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY, name TEXT, description TEXT, price INT, ownable INT, timestamp BIGINT)"
		@db.execute "CREATE TABLE IF NOT EXISTS inventory (id INTEGER PRIMARY KEY, user_id INT, item_id INT, timestamp BIGINT)"
		
		#Command Table For Admins to create custom commands
		@db.execute "CREATE TABLE IF NOT EXISTS commands (id INTEGER PRIMARY KEY, command_name TEXT, response TEXT, active INT)"
	end
	
	def teardown
		@db.close if db
	end
	

	
end