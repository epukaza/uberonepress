print("starting main.lua")

uber = require('uber')

local button_pin = 6
local led_pin = 7
local pwm_timer = 1
local pwm_delay = 16
local request_check_timer = 4
local manual_update_timer = 3
--location is fort mason center
lat = "37.806010"
long = "-122.431846"
ride_status = nil

colors = {
  OFF = 1,
  WHITE = 2,
  YELLOW = 3,
  RED = 4,
  GREEN = 5,
}

color_grb_values = {
  {0,0,0},
  {255,220,255},
  {200,180,0},
  {0,255,0},
  {255,0,0},
}

function do_manual_update()
  --after 10 seconds, change the ride status to 'accepted'
  --then 'arriving'
  --then 'in_progress'
  --then 'completed'
  local count = 1
  local status = {'accepted','arriving','in_progress','completed'}
  tmr.alarm(manual_update_timer, 13*1000, tmr.ALARM_AUTO, 
    function()
      collectgarbage()
      uber.set_ride_status(status[count])
      count = count+1
      if (count == 5) then
        tmr.unregister(manual_update_timer)
      end
    end)
end

function request_callback()
  ride_status = uber.get_status()
  collectgarbage()
  tmr.alarm(request_check_timer, 1000, tmr.ALARM_SINGLE, 
    function()
      collectgarbage()
      uber.check_request_status(check_callback)
      do_manual_update()
    end)
end

function check_again()
  tmr.alarm(request_check_timer, 8000, tmr.ALARM_SINGLE, 
    function()
      collectgarbage()
      uber.check_request_status(check_callback)
    end)
end

function check_callback()
  ride_status = uber.get_status()
  debug_message("current ride status is: "..ride_status)
  if(ride_status == "processing")then
    --check again in 5 seconds
    check_again()
  elseif(ride_status == "accepted") then
    if not doneaccepted then
      led_fade_to(colors.YELLOW, colors.GREEN)
      doneaccepted = 1
    end
    check_again()
  elseif (ride_status == "arriving") then
    if not doneifttt then
      doneifttt = 1
      debug_message("ifttt")
      http.get(
              'https://maker.ifttt.com/trigger/uberonepress/with/key/b5PXJwPI4IPGPVMkZ3QxgT',
              nil,
              function(code, data)
                debug_message('ifttt status code: ' .. (code or 'nil'))
                debug_message('ifttt resp data: ' .. (data or 'nil'))
              end
            )
    end
    check_again()
  elseif (ride_status == "in_progress")
    or (ride_status == "completed")then
    --pulse led green then turn off after 1 minute (20 seconds in dev/demo)
    calling = nil
    tmr.alarm(request_check_timer, 20*1000, tmr.ALARM_SINGLE, function()
      led_fade_to(colors.GREEN, colors.WHITE)
      end)
  elseif(ride_status == "driver_canceled")
    or (ride_status == "no_drivers_available")
    or (ride_status == "rider_canceled")then
    --pulse led red then turn off after 1 minute (20 seconds in dev/demo)
    calling = nil
    led_fade_to(colors.YELLOW, colors.RED)
    tmr.alarm(request_check_timer, 20*1000, tmr.ALARM_SINGLE, function()
      led_fade_to(colors.RED, colors.WHITE)
      end)
    tmr.unregister(request_check_timer)
  end
end

function call_uber()
  if not calling then
    calling = 1
    debug_message("call_uber")
    doneaccepted = nil
    doneifttt = nil
    led_fade_to(colors.WHITE, colors.YELLOW)
    uber.request_ride(lat, long, request_callback)
  end
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

function on_start()
  uber.read_token()
  led_fade_in(colors.WHITE)
  wifi.setmode(wifi.STATION)
  wifi.sta.config("volcano", 'abhinav sinha')
end

function led_fade_in(color, callback, color2)
  --fade in color from black
  grb_limits = color_grb_values[color]
  g_lim = grb_limits[1]
  r_lim = grb_limits[2]
  b_lim = grb_limits[3]
  g_cur, r_cur, b_cur = 0,0,0

  tmr.alarm(pwm_timer, pwm_delay, tmr.ALARM_AUTO,
    function()
      local done = 0
      g_cur = g_cur + 1
      r_cur = r_cur + 1
      b_cur = b_cur + 1
      if g_cur > g_lim then
        g_cur = g_lim
        done = done + 1
      end
      if r_cur > r_lim then
        r_cur = r_lim
        done = done + 1
      end
      if b_cur > b_lim then
        b_cur = b_lim
        done = done + 1
      end
      ws2812.write(led_pin, string.char(g_cur, r_cur, b_cur))
      if done == 3 then
        tmr.unregister(pwm_timer)
        pwm_delay = 4
        if callback then
          callback(color2)
        end
      end
    end)
end

function led_fade_out(color, callback, color2)
  --fade out color to black
  grb_limits = color_grb_values[color]
  g_lim, r_lim, b_lim = 0,0,0
  g_cur, r_cur, b_cur = grb_limits[1],grb_limits[2],grb_limits[3]

  tmr.alarm(pwm_timer, pwm_delay, tmr.ALARM_AUTO,
    function()
      local done = 0
      g_cur = g_cur - 1
      r_cur = r_cur - 1
      b_cur = b_cur - 1
      if g_cur < g_lim then
        g_cur = g_lim
        done = done + 1
      end
      if r_cur < r_lim then
        r_cur = r_lim
        done = done + 1
      end
      if b_cur < b_lim then
        b_cur = b_lim
        done = done + 1
      end
      ws2812.write(led_pin, string.char(g_cur, r_cur, b_cur))
      if done == 3 then
        tmr.unregister(pwm_timer)
        if callback then
          callback(color2)
        end
      end
    end)
end

function led_fade_to(begin_color, end_color)
  led_fade_out(begin_color, led_fade_in, end_color)
end

on_start()
gpio.mode(button_pin, gpio.INT, gpio.FLOAT)
gpio.trig(button_pin, 'up', debounce(call_uber))