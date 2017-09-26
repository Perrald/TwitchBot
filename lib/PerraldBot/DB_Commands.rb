require 'sqlite3'

module PerraldBot
	
	###################
	#Setter DB commands
	###################
	
	def create_user(name)
		username = name.downcase
		begin
			@db.execute("INSERT INTO users ( username, points, created, last_active , admin) VALUES ( ?, ?, ?, ?, ? )", [username, 0, Time.now.uts.to_i, Time.now.uts.to_i, 0])
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
			@db.execute("UPDATE users SET admin = ? WHERE id = ?", [admin, user_id])
			return true
		rescue SQLite3::Exception => e
		end
	end
	
	###################
	#Getter DB commands
	###################

	def get_user(name)
		username = name.downcase
		begin
			user = @db.execute("SELECT * FROM users WHERE username LIKE ?", [username])
			if (user)
				return user
			else
				puts "#{username} not found in DB"
				return nil
			end
		rescue SQLite3::Exception => e
		end
	end
	
end
