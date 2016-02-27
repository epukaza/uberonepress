print("this is main.lua")


sk = net.createConnection(net.TCP, 1)
sk:on("receive", function(sck, c) print(c) end )
sk:connect(443,"www.reddit.com")
sk:on("connection", function(sck,c)
    -- Wait for connection before sending.
    sk:send("GET /index.html HTTP/1.1\r\nHost: www.reddit.com\r\nConnection: keep-alive\r\nAccept: */*\r\n\r\n")
end)