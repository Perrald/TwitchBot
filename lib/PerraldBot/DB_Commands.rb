
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

######Command DB######

def create_command(call, response)
	command_name = call.downcase
	begin
		@db.execute("INSERT INTO command ( command_name, response, active) VALUES ( ?, ?, ? )", [command_name, response, 1])
		return true
	rescue SQLite3::Exception => e
	end
end

def set_command_active(call, active)
	command_name = call.downcase
	begin
		@db.execute("UPDATE command SET active = ? WHERE command_name = ?", [active, command_name])
		return true
	rescue SQLite3::Exception => e
	end
end

def update_command(call, response)
	command_name = call.downcase
	begin
		@db.execute("UPDATE command SET response = ? WHERE command_name = ?", [response, command_name])
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
# result from command DB is an array: user[0] = id, user[1] = command_name, 
# user[2] = response, user[3] = active
# 
def get_command(call)
	command_name = call.downcase
	command = @db.execute( "SELECT * FROM command WHERE command_name LIKE ?", [command_name]).first
	if (command) 
		if (command[3]) #check if active
			return command[2] #return response
		else
			puts "#{command_name} not active"
			return nil
		end
	else
		puts "#{command_name} not found in db"
		return nil
	end
end