require 'test/unit'
require '../lib/PerraldBot/Twitch'
require '../lib/PerraldBot/DB_Commands'

class TestTwitchBot < Test::Unit::TestCase
	
	def setup
		@db = SQLite3::Database.new "../config/PerraldBot.db"
	end
	
	def teardown
	
	end
	
	
end