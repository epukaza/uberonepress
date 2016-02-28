local debug_message = debug_message
local http = http
local cjson = cjson
local print = print

module(...)

local http_code = nil
local request_id = nil
local status = nil
local error_code = nil

local base_url = "https://sandbox-api.uber.com/"

function request_ride(token, latitude, longitude)
  local url = base_url.."v1/requests"
  local headers = "Content-Type: application/json\r\n"..
                  "Authorization: Bearer "..token.."\r\n"
  local body = '{"start_latitude": '..latitude..',"start_longitude": '..longitude..'}'

  http.post(url, headers, body, function(code, data)
    if (code < 0) then
      print("https request failed")
    else
      print(code, data)
      http_code = code
      table = cjson.decode(data)
      status = table['status']
      request_id = table['request_id']
      if table['errors'] then
        error_code = table['errors']['code']
      end
    end
  end)

end

function get_status()
  return http_code, request_id, status, error_code
end

function check_request_status(token)
  if (request_id and token) then
    local url = base_url.."v1/requests/"..request_id
    local headers = "Authorization: Bearer "..token.."\r\n"
    http.get(url, headers, function(code, data)
      if (code < 0) then
        print("https request failed")
      else
        print(code, data)
        http_code = code
        table = cjson.decode(data)
        status = table['status']
        request_id = table['request_id']
        if table['errors'] then
          error_code = table['errors']['code']
        end
      end
    end)
  end
end