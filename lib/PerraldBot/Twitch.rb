require 'socket'

module PerraldBot
	TWITCH_HOST = "irc.twitch.tv"
	TWITCH_PORT = 6667

	class TwitchBot

		def initialize
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
		
		def run 
			until @socket.eof? do
				message = @socket.gets
				puts message
				
				if message.match(/^PING :(.*)$/)
					write_to_system "PONG #{$~[1]}"
					next
				end
				
				if message.match(/PRIVMSG ##{@channel} :(.*)$/)
					content = $~[1]
					
					if content.include? "coffee"
						write_to_chat("COFFEE!!!")
					end
				end
				
			end
		end
		
		def quit
			write_to_chat "#{@nickname} is Leaving"
			write_to_system "PART ##{@channel}"
			write_to_system "QUIT"
		end
		
	end

	bot = TwitchBot.new
	trap("INT") { bot.quit }
	bot.run
end