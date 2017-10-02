require 'socket'
require 'sqlite3'
require 'json'
require '../lib/PerraldBot/DB_Commands'
require 'net/http'

module PerraldBot
	TWITCH_HOST = "irc.twitch.tv"
	TWITCH_PORT = 6667
	
	class TwitchBot
		attr_reader :nickname, :password, :channel, :socket, :command_hash, :running
		
		def initialize
		
			@running = false
			@nickname = "PerraldBot"
			@password = ENV['TWITCH_OATH']
			@channel = "squalami"
			@socket =  TCPSocket.open(TWITCH_HOST, TWITCH_PORT)
			
			#Connect to the TWITCH channel
			write_to_system "pass #{@password}"	
			write_to_system	"NICK #{@nickname}"
			write_to_system "USER #{@nickname} 0 * #{@nickname}"
			write_to_system "JOIN ##{@channel}"
			
			#Create the DBs if they don't exist
			@db = SQLite3::Database.new "../config/PerraldBot.db"
			
			#Init Tables
			
			#User TABLE
			@db.execute "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, username TEXT, points INT, created BIGINT, last_active BIGINT, admin INT, bio TEXT)"
			@db.execute "CREATE UNIQUE INDEX IF NOT EXISTS username ON users (username)"
			
			#Item Tables
			@db.execute "CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY, name TEXT, description TEXT, price INT, ownable INT, timestamp BIGINT)"
			@db.execute "CREATE TABLE IF NOT EXISTS inventory (id INTEGER PRIMARY KEY, user_id INT, item_id INT, timestamp BIGINT)"
			
			#Command Table For Admins to create custom commands
			@db.execute "CREATE TABLE IF NOT EXISTS commands (id INTEGER PRIMARY KEY, command_name TEXT, response TEXT, active INT)"
			
		end

		def write_to_system(message)
			@socket.puts message
		end
		
		def write_to_chat(message)
			write_to_system "PRIVMSG ##{@channel} :#{message}"
		end
		
		def reload_hash(user) #Change this to the DB
			coins = 0 #change this to grab coins
			command_hash = {'!hello'		=>"Hello #{user} from PerraldBot!",
							'!hi'			=>'hi :)',
							'!coins'		=>"#{user} has #{coins} coins",
							''				=>''}
							
			return command_hash
		end
		
		def parse_message
			command_hash = reload_hash('test')
			until @socket.eof? do
				message = @socket.gets
				puts message #debug message
					
				if message.match(/^PING :(.*)$/)
					write_to_system "PONG #{$~[1]}"
					next
				end
				
				if message.match(/^:(.+)!(.+) PRIVMSG ##{@channel} :(.*) (.*) (.*)$/)
					user = $~[1]
					command = $~[3]
					target = $~[4]
					arg = $~[5]
					if command.include? "!grant"
						if(user_is_an_admin(user))
							tempname = get_user(target)
							if (tempname)
								points = arg.to_i + tempname[2].to_i
								set_points(tempname[0], points)
								write_to_chat("Giving #{tempname[1]} #{args.to_i} points, their total is now #{points}")
							end
						end
					else if command.include? "!command"
						if(user_is_an_admin(user))
							if get_command(target)
								if(update_command(target, arg.strip))
									write_to_chat("#{target} command updated")
								else
									write_to_chat("Unable to update command #{target}")
								end 
							else
								if(create_command(target, arg.strip))
									write_to_chat("#{target} command created")
								else
									write_to_chat("Unable to create command #{target}")
								end
							end
						end
					end
					
					
				else if message.match(/^:(.+)!(.+) PRIVMSG ##{@channel} :(.*) (.*)$/)
					user = $~[1]
					command = $~[3]
					args = $~[4]
					if command.include? "!activate"
						if(user_is_an_admin(user))
							if get_command(args.strip)
								if(set_command_active(args.strip, 1))
									write_to_chat("#{args.strip} command updated")
								else
									write_to_chat("Unable to update command #{args.strip}")
								end 
							else
								write_to_chat("Unable to activate command #{args.strip} because it doesnt exist")
							end
						end
					end
					if command.include? "!grant"
						tempname = get_user(user)
						if (tempname)
							points = args.to_i + tempname[2].to_i
							set_points(tempname[0], points)
							write_to_chat("Giving #{tempname[1]} #{args.to_i} points, their total is now #{points}")
						end
					end
					if command.include? "!makeadmin"
						#Check if User trying to grant admin status is an admin
						if(user_is_an_admin(user))
							user_to_make_admin = get_user(args.strip)
							if (user_to_make_admin)
								set_admin(user_to_make_admin[0], 1)
								write_to_chat("#{user_to_make_admin[1]} is now an Admin")
							end
						else
							write_to_chat("#{user} can't grant Admin status")
						end
					end
				
# result is an array: user[0] = id, user[1] = username, user[2] = points, 
# user[3] = created, user[4] = last_seen, user[5] = admin, user[6] = profile
# 
				
				else if message.match(/^:(.+)!(.+) PRIVMSG ##{@channel} :(.*)$/)
					user = $~[1]
					command = $~[3]
					if command.include? "!add"
						tempname = get_user(user)
						if (tempname)
							write_to_chat("#{tempname[1]} exists, has #{tempname[2].to_i} points")
						else
							create_user(user)
							write_to_chat("#{user} added to the DB")
						end
					end
					if command.include? "!here"
						all_users_in_channel = get_all_users_in_channel
						write_to_chat("Users here:" + all_users_in_channel.to_s)
					end
					# if command_hash.fetch(command_hash.keys.find{|key|command[key]}, "no key")!="no key"
						# command_hash = reload_hash(user)
						# write_to_chat(command_hash.fetch(command_hash.keys.find{|key|command[key]}))
					# end
				end
				
			end
		end
		
		def run 
			@running = true
			message_parsing_thread = Thread.new{parse_message()}
			message_parsing_thread.join
			
		end
		
		def quit
			write_to_chat "#{@nickname} is Leaving"
			write_to_system "PART ##{@channel}"
			write_to_system "QUIT"
		end
		
		def user_is_an_admin(user)
			puts "checking admin for: #{user}" #debug message
			check_this_user = get_user(user)
			if (check_this_user)
				if (check_this_user[5] == 1) || user == @channel
					return true
				else
					return false
				end
			end
		end
		
		def get_all_users_in_channel
			url_string = "https://tmi.twitch.tv/group/user/"+ @channel + "/chatters"
			result = Net::HTTP.get(URI.parse(url_string))
			parsed = JSON.parse(result)

			all_users_in_channel = []
			
			parsed["chatters"]["moderators"].each do |p|
				all_users_in_channel << p
			end
			
			parsed["chatters"]["viewers"].each do |p|
				all_users_in_channel << p
			end
			
			puts "Users here:" + all_users_in_channel.to_s #debug message
			return all_users_in_channel
		end
		
	end
end