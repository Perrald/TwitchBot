require 'socket'

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
			write_to_system "pass #{@password}"	
			write_to_system	"NICK #{@nickname}"
			write_to_system "USER #{@nickname} 0 * #{@nickname}"
			write_to_system "JOIN ##{@channel}"
		end

		def write_to_system(message)
			@socket.puts message
		end
		
		def write_to_chat(message)
			write_to_system "PRIVMSG ##{@channel} :#{message}"
		end
		
		def reload_hash(user)
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
				puts message
					
				if message.match(/^PING :(.*)$/)
					write_to_system "PONG #{$~[1]}"
					next
				end
				
				if message.match(/^:(.+)!(.+) PRIVMSG ##{@channel} :(.*)$/)
					user = $~[1]
					command = $~[3]
					if command_hash.fetch(command_hash.keys.find{|key|command[key]}, "no key")!="no key"
						command_hash = reload_hash(user)
						write_to_chat(command_hash.fetch(command_hash.keys.find{|key|command[key]}))
					end
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
		
	end
end