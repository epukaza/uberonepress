local debug_message = debug_message
local http = http
local cjson = cjson
local file = file
local tmr = tmr
module(...)

local token = nil
local request_id = nil
local status = nil

local base_url = "https://sandbox-api.uber.com/"
local http_busy = 0

function read_token()
  file.open('access_token_request.txt')
  token = file.read()
  file.close()
end

function request_ride(latitude, longitude, callback)
  debug_message("uber.request_ride")
  tmr.wdclr()
  if http_busy==1 then
    tmr.alarm(5, 500, tmr.ALARM_SINGLE, function()
      request_ride(latitude, longitude, callback)
      end)
    return
  end
  local url = base_url.."v1/requests"
  local headers = "Content-Type: application/json\r\n"..
                  "Authorization: Bearer "..token.."\r\n"
  local body = '{"start_latitude": '..latitude..',"start_longitude": '..longitude..'}'
  http_busy = 1
  http.post(url, headers, body, function(code, data)
    http_busy = 0
    if (code < 0) then
      debug_message("https request failed")
    else
      debug_message(code)--..data)
      table = cjson.decode(data)
      status = table['status']
      request_id = table['request_id']
      if(callback) then
        callback()
      end
    end
  end)
end

function get_status()
  return status
end

function check_request_status(callback)
  debug_message("uber.check_request_status")
  tmr.wdclr()
  if (http_busy==1) then
    tmr.alarm(6, 500, tmr.ALARM_SINGLE, function()
      check_request_status(callback)
      end)
    return
  end
  -- debug_message("token and request not nil")
  local url = base_url.."v1/requests/"..request_id
  local headers = "Authorization: Bearer "..token.."\r\n"
  -- debug_message("url: "..url)
  -- debug_message("headers: "..headers)
  http_busy = 1
  http.get(url, headers, function(code, data)
    http_busy = 0
    if (code < 0) then
      debug_message("https request failed")
    else
      debug_message(code)--..data)
      table = cjson.decode(data)
      status = table['status']
      request_id = table['request_id']
      if(callback) then
        callback()
      end
    end
  end)
end

function set_ride_status(status, callback)
  debug_message("uber.set_ride_status:"..status)
  tmr.wdclr()
  if (http_busy==1) then
    tmr.alarm(1, 500, tmr.ALARM_SINGLE, function()
      set_ride_status(status)
      end)
    return
  end
  if status then
    local url = base_url.."v1/sandbox/requests/"..request_id
    local headers = "Authorization: Bearer "..token.."\r\n"
                    .."Content-Type: application/json\r\n"
    local body = '{"status":"'..status..'"}'
    -- debug_message("setting request with id: "..req_id.."\n".."to status: "..status.."\n")
    -- debug_message("packet body:" ..body)
    http_busy = 1
    http.put(url, headers, body, 
      function(code, data)
        http_busy = 0
        if (code < 0) then
          debug_message("https request failed")
        else
          debug_message(code..data)
        end
        if(callback) then
          callback()
        end
      end
    )
  end
end