
module PerraldBot
	class LoadHashCommands
		
		def reload_hash(user)
			h = {'!hello'=>"Hello #{user} from PerraldBot!",'!hi'=>'hi :)'}
			return h
		end
	end
end