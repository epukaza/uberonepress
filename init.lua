DEBUG = true

function debug_message(message)
	if DEBUG then
		print(message)
	end
end

ws2812.write(7, string.char(0,0,0))
ws2812.write(7, string.char(0,0,0))

tmr.alarm(0, 1000, tmr.ALARM_SINGLE, function()
	if(file.exists("main.lc")) then
		dofile("main.lc")
	else
		dofile("main.lua")
	end
end)