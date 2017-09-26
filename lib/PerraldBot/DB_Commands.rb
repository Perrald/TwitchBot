require 'sqlite3'

module PerraldBot
	
	def write_user(name)
		username = name.downcase
		begin
			@db.execute("INSERT INTO users ( username, points, created, last_active ) VALUES ( ?, ?, ?, ? )", [username, 0, Time.now.uts.to_i, Time.now.uts.to_i])
			return true
		rescue SQLite3::Exception => e
		end
	end


end
