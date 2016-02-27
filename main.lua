print("this is main.lua")


function test_uber()
  local url = "https://sandbox-api.uber.com/v1/requests"
  local headers = "Content-Type: application/json\r\n"..
                  "Authorization: Bearer eyJhbGciOiJSUzI1N"..
                  "iIsInR5cCI6IkpXVCJ9.eyJzY29wZXMiOlsicmVx"..
                  "dWVzdCJdLCJzdWIiOiI0NjFjN2U3Yy1kYjc2LTQ3Y"..
                  "jktOTVlYy0xZTMzZDNmOTQ0MWEiLCJpc3MiOiJ1Ym"..
                  "VyLXVzMSIsImp0aSI6ImEzNzY2Mzc0LTNiNzgtNDl"..
                  "jZC04Y2ZiLWFiZjM1NDFhOTc1MSIsImV4cCI6MTQ1"..
                  "OTE1Mzc2NiwiaWF0IjoxNDU2NTYxNzY2LCJ1YWN0I"..
                  "joiMUVUVmVvVzlBU0h5UmwwTVFvRXdWQmtDWnl2a1"..
                  "N6IiwibmJmIjoxNDU2NTYxNjc2LCJhdWQiOiJtX0J"..
                  "0U2czbjJLem45MzlPa3VkRXcxQXlYOHV6X1ZaQyJ9"..
                  ".SM-D6KovxJtwPgxNxXSAUNUfPLDEGQAmRvZTvNDg"..
                  "_REXxmDbuH_B31-wl_9yMz1rU7Ya-9ukw9yWv7PHM"..
                  "GvwJkWvtRKMPF9MEwU1_be2DrJrs77DwyuOXh0ZBm"..
                  "hu1wCoZQqU3wZ0anchiZFspvcoaoHUWdVAj1sbyrH"..
                  "E-vy8lIJWY_N1L_znXU53PeGQkZ5q5Mo6Bgjy0qHN"..
                  "VXCy-lacfKrRbQVkWUc7SH8-bDKsKAKfgq7LI-uSK"..
                  "3KWK1jvsJbCN4H7UmzRUbQ9mypoih2aF4uAYQHvjG"..
                  "9CdQkT6RwEbVfa75ik569QczyviyMYE2X-col7IPL"..
                  "1lkLoRta0UAHWpA\r\n"
  local body = '{"start_latitude": 37.775393,"start_longitude": -122.417546}'

  http.post(url, headers, body, function(code, data)
    if (code < 0) then
      print("https request failed")
    else
      print(code, data)
    end
  end)
end