local debug_message = debug_message
local http = http
local cjson = cjson
local debug_message = debug_message
module(...)

local http_code = nil
local request_id = nil
local status = nil
local error_code = nil

local base_url = "https://sandbox-api.uber.com/"

local http_busy = 0

function request_ride(token, latitude, longitude, callback)
  debug_message("uber.request_ride")
  local url = base_url.."v1/requests"
  local headers = "Content-Type: application/json\r\n"..
                  "Authorization: Bearer "..token.."\r\n"
  local body = '{"start_latitude": '..latitude..',"start_longitude": '..longitude..'}'
  while http_busy==1 do
  end
  http_busy = 1
  http.post(url, headers, body, function(code, data)
    http_busy = 0
    if (code < 0) then
      debug_message("https request failed")
    else
      debug_message(code)--..data)
      http_code = code
      table = cjson.decode(data)
      status = table['status']
      request_id = table['request_id']
      if table['errors'] then
        error_code = table['errors']['code']
      end
      if(callback) then
        callback()
      end
    end
  end)
end

function get_status()
  debug_message("uber.get_status")
  return http_code, request_id, status, error_code
end

function check_request_status(token, callback)
  debug_message("uber.check_request_status")
  if (request_id and token) then
    -- debug_message("token and request not nil")
    local url = base_url.."v1/requests/"..request_id
    local headers = "Authorization: Bearer "..token.."\r\n"
    -- debug_message("url: "..url)
    -- debug_message("headers: "..headers)
    while http_busy==1 do
    end
    http_busy = 1
    http.get(url, headers, function(code, data)
      http_busy = 0
      if (code < 0) then
        debug_message("https request failed")
      else
        debug_message(code)--..data)
        http_code = code
        table = cjson.decode(data)
        status = table['status']
        request_id = table['request_id']
        if table['errors'] then
          error_code = table['errors']['code']
        end
        if(callback) then
          callback()
        end
      end
    end)
  end
end

function set_ride_status(token, req_id, status)
  debug_message("uber.set_ride_status")
  if (token and req_id and status) then
    local url = base_url.."v1/sandbox/requests/"..req_id
    local headers = "Authorization: Bearer "..token.."\r\n"
                    .."Content-Type: application/json\r\n"
    local body = '{"status":"'..status..'"}'
    -- debug_message("setting request with id: "..req_id.."\n".."to status: "..status.."\n")
    -- debug_message("packet body:" ..body)
    while http_busy==1 do
    end
    http_busy = 1
    http.put(url, headers, body, 
      function(code, data)
        http_busy = 0
        if (code < 0) then
        debug_message("https request failed")
        else
          debug_message(code..data)
        end
      end
    )
  end
end