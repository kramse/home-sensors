
-- retrieve the content of a URL
local http = require("socket.http")
local body, code = http.request("http://10.0.42.21/lua/test.lua")
if not body then error(code) end

-- save the content to a file
local f = assert(io.open('test.lua', 'wb')) -- open in "binary" mode
f:write(body)
f:close()
