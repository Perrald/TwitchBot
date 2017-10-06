
###################
#Setter DB commands
###################

######User DB######

def create_user(name)
	username = name.downcase
	begin
		@db.execute("INSERT INTO users ( username, points, created, last_active , admin) VALUES ( ?, ?, ?, ?, ? )", [username, 0, Time.now.utc.to_i, Time.now.utc.to_i, 0])
		return true
	rescue SQLite3::Exception => e
	end
end

def remove_user(user_id)
	begin
		@db.execute("DELETE FROM users WHERE id = ?", [user_id])
		return true
	rescue SQLite3::Exception => e
	end
end

def set_last_active(user_id)
	begin
		@db.execute("UPDATE users SET last_active = ? WHERE id = ?", [Time.now.utc.to_i, user_id])
		return true
	rescue SQLite3::Exception => e
	end
end
	
def set_points(user_id, points)
	begin
		@db.execute("UPDATE users SET points = ? WHERE id = ?", [points, user_id])
		return true
	rescue SQLite3::Exception => e
	end
end

def set_admin(user_id, admin_bool)
	begin
		@db.execute("UPDATE users SET admin = ? WHERE id = ?", [admin_bool, user_id])
		return true
	rescue SQLite3::Exception => e
	end
end

######Item DB######
def create_item(name, command, price)
	item_name = name.downcase
	begin
		@db.execute("INSERT INTO items ( name, command, price, ownable , timestamp) VALUES ( ?, ?, ?, ?, ? )", [item_name, command, price, 1, Time.now.utc.to_i])
		return true
	rescue SQLite3::Exception => e
	end
end

def remove_item(item_id)
	begin
		@db.execute("DELETE FROM items WHERE id = ?", [item_id])
		return true
	rescue SQLite3::Exception => e
	end
end

def set_price(item_id, price)
	begin
		@db.execute("UPDATE items SET price = ? WHERE id = ?", [price, item_id])
		return true
	rescue SQLite3::Exception => e
	end
end

def set_ownable(item_id, ownable_bool)
	begin
		@db.execute("UPDATE items SET ownable = ? WHERE id = ?", [ownable_bool,  item_id])
		return true
	rescue SQLite3::Exception => e
	end
end

def set_item_effect(item_id, command)
	begin
		@db.execute("UPDATE items SET command = ? WHERE id = ?", [command, item_id])
		return true
	rescue SQLite3::Exception => e
	end
end

######Command DB######

def create_command(call, response)
	command_name = call.downcase
	begin
		@db.execute("INSERT INTO commands ( command_name, response, active) VALUES ( ?, ?, ? )", [command_name, response, 1])
		return true
	rescue SQLite3::Exception => e
	end
end

def set_command_active(call, active)
	command_name = call.downcase
	begin
		@db.execute("UPDATE commands SET active = ? WHERE command_name = ?", [active, command_name])
		return true
	rescue SQLite3::Exception => e
	end
end

def update_command(call, response)
	command_name = call.downcase
	begin
		@db.execute("UPDATE commands SET response = ? WHERE command_name = ?", [response, command_name])
		return true
	rescue SQLite3::Exception => e
	end
end

def remove_inactive_commands
	begin
		@db.execute("DELETE FROM commands WHERE active = 0")
		return true
	rescue SQLite3::Exception => e
	end
end
###################
#Getter DB commands
###################
#
# result from user DB is an array: user[0] = id, user[1] = username, user[2] = points, 
# user[3] = created, user[4] = last_seen, user[5] = admin, user[6] = profile
# 

def get_user(name)
	username = name.downcase
	user = @db.execute( "SELECT * FROM users WHERE username LIKE ?", [username] ).first
	if (user)
		return user
	else
		puts "#{username} not found in db"
		return nil
	end
end
#
# result from command DB is an array: command[0] = id, command[1] = command_name, 
# command[2] = response, command[3] = active
# 
def get_command(call)
	command_name = call.downcase
	command = @db.execute( "SELECT * FROM commands WHERE command_name LIKE ?", [command_name]).first
	if (command) 
		return command #let user check for active 
	else
		puts "#{command_name} not found in db"
		return nil
	end
end
#
# result from item DB is an array: item[0] = id, item[1] = name, 
# item[2] = command, item[3] = price, item[4] = ownable, item[5] = timestamp
# 
def get_item(name)
	item_name = name.downcase
	item = @db.execute( "SELECT * FROM items WHERE name LIKE ?", [item_name]).first
	if (item) 
		return item 
	else
		puts "#{item_name} not found in db"
		return nil
	end
end