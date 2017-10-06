require 'test/unit'
require '../lib/PerraldBot/Twitch'
require '../lib/PerraldBot/DB_Commands'

class TestTwitchBot < Test::Unit::TestCase
	
	def setup
		@db = SQLite3::Database.new "PerraldBot.db"
		
		#User TABLE
		@db.execute "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, username TEXT, points INT, created BIGINT, last_active BIGINT, admin INT, bio TEXT)"
		@db.execute "CREATE UNIQUE INDEX IF NOT EXISTS username ON users (username)"
		
		#Item Tables
		@db.execute "CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY, name TEXT, command TEXT, price INT, ownable INT, timestamp BIGINT)"
		@db.execute "CREATE UNIQUE INDEX IF NOT EXISTS name ON items (name)"
		@db.execute "CREATE TABLE IF NOT EXISTS inventory (id INTEGER PRIMARY KEY, user_id INT, item_id INT, timestamp BIGINT)"
		
		#Command Table For Admins to create custom commands
		@db.execute "CREATE TABLE IF NOT EXISTS commands (id INTEGER PRIMARY KEY, command_name TEXT, response TEXT, active INT)"
		@db.execute "CREATE UNIQUE INDEX IF NOT EXISTS command_name ON commands (command_name)"
	end
	
	def teardown
		@db.close if @db
	end
	
	def test_commands
		assert_equal(true, create_command("!unittest", "this is a test"))
		
		unit_command = get_command("!unittest")
		assert_equal("this is a test", unit_command[2])
		
		update_command("!unittest", "this is a different test")
		unit_command = get_command("!unittest")
		assert_equal("this is a different test", unit_command[2])
		
		assert_equal(1, unit_command[3])
		set_command_active("!unittest", 0)
		unit_command = get_command("!unittest")
		assert_equal(0, unit_command[3])
		
		assert_equal(true, remove_inactive_commands)
		unit_command = get_command("!unittest")
		assert_equal(nil, unit_command)
	end

	def test_users
		assert_equal(true,create_user("unittest"))
		
		unit_user = get_user("unittest")
		assert_equal("unittest", unit_user[1])
		
		time = unit_user[4]
		set_last_active(unit_user[0])
		unit_user = get_user("unittest")
		assert_not_same(time, unit_user[4])
		
		set_points(unit_user[0], 2)
		unit_user = get_user("unittest")
		assert_equal(2, unit_user[2])
		set_points(unit_user[0], 4)
		unit_user = get_user("unittest")
		assert_equal(4, unit_user[2])
		
		assert_equal(0, unit_user[5])
		set_admin(unit_user[0], 1)
		unit_user = get_user("unittest")
		assert_equal(1, unit_user[5])
		
		remove_user(unit_user[0])
		unit_user = get_user("unittest")
		assert_equal(nil, unit_user)
	end
	
	def test_items
		assert_equal(true,create_item("unititem", "swing", 500))
		
		unit_item = get_item("unititem")
		assert_equal("unititem", unit_item[1])
		
		assert_equal("swing", unit_item[2])
		set_item_effect(unit_item[0], "Swung")
		unit_item = get_item("unititem")
		assert_equal("Swung", unit_item[2])
				
		set_price(unit_item[0], 1000)
		unit_item = get_item("unititem")
		assert_equal(1000, unit_item[3])
		set_price(unit_item[0], 2000)
		unit_item = get_item("unititem")
		assert_equal(2000, unit_item[3])
		
		assert_equal(1, unit_item[4])
		set_ownable(unit_item[0], 0)
		unit_item = get_item("unititem")
		assert_equal(0, unit_item[4])
		
		remove_item(unit_item[0])
		unit_item = get_item("unititem")
		assert_equal(nil, unit_item)
		
	end
	
end

