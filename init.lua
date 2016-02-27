DEBUG = true

function debug_message(message)
	if DEBUG then
		print(message)
	end
end


tmr.alarm(0, 1000, tmr.ALARM_SINGLE, function() 
	dofile("main.lua")
	end)