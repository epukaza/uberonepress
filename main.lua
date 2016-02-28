print("starting main.lua")

uber = require('uber')

local ssid = "volcano"
local pwd = "abhinav sinha"
local srv = nil
local button_pin = 6
local pwm_pin = 4
local pwm_timer = 1
local pwm_max_bright = 255
local config = nil -- sensitive data loaded at runtime
token = nil
lat = "37.775393"
long = "-122.417546"
request_id = nil
-- request_id = "58b26005-43bd-4784-a3d4-7abaad9003d3"
ride_status = nil


local colors = {
  OFF = 1,
  WHITE = 2,
  YELLOW = 3,
  RED = 4,
  GREEN = 5,
}
function call_uber()
  uber.request_ride(token, lat, long)
  _, request_id, ride_status = uber.get_status()
end

function debounce (func, ...)
    local last = 0
    local delay = 200000

    return function (...)
        local now = tmr.now()
        if now - last < delay then return end

        last = now
        return func(...)
    end
end

function start_server()
  debug_message('server start')
  debug_message(srv)

  if srv then
    srv = nil
  end
  srv = net.createServer(net.TCP, 30)
  srv:listen(80, connect)
  debug_message(srv)
end

function stop_server()
  debug_message('server stop')
  debug_message(srv)
  if srv then
    srv:close()
    srv = nil
  end
  debug_message(srv)
end

function connect(sock)
  sock:on('receive', function(sck, payload)
    conn:send('HTTP/1.1 200 OK\r\n\r\n' .. 'Hello world')
  end)

  sock:on('send', function(sck)
    sck:close()
  end)
end

function on_start()
  debug_message('on_start')

  debug_message('on_start: reading request token')
  file.open('access_token_request.txt')
  token = file.read()
  file.close()

  debug_message('on_start: enable led')
  ws2812.write(4, string.char(0,0,0))
  ws2812.write(4, string.char(0,0,0))

  debug_message('on_start: connecting to AP')
  wifi.sta.config(ssid, pwd)
end

function led_fade_in(color)
end

function led_fade_out(color)
end

function led_fade_to(begin_color, end_color)
end

on_start()
start_server()
gpio.mode(button_pin, gpio.INT, gpio.FLOAT)
gpio.trig(button_pin, 'down', debounce(call_uber))