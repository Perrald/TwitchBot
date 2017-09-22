require 'socket'

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
	
end