DEBUG = true

function debug_message(message)
	if DEBUG then
		print(message)
	end
end

ws2812.write(4, string.char(0,0,0))
ws2812.write(4, string.char(0,0,0))

tmr.alarm(0, 1000, tmr.ALARM_SINGLE, function()
	wifi.sta.sethostname("UBERBUTTON") 
	dofile("main.lua")
	end)