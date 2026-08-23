local socket = require("socket")
local cjson = require("cjson")

local data = {
    type = "cache-update",
    data = {
        key = "products",
        value = {
            { name = "shoes", value = 123.45 }
        },
    },
}

local master = socket.tcp()
assert(master:connect("*", 3000))
master:send(cjson.encode(data) .. "\n")
