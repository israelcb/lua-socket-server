function data_loop(linda, server_data)
    local _, fn = linda:receive(nil, "update_server_data")

    fn(server_data)
    linda:set("product_list", server_data.product_list)

    data_loop(linda, server_data)
end

local function server_init(socket)
    local server = socket.tcp()
    assert(server:bind('*', 3000))
    server:listen(5)

    local ip, port = server:getsockname()
    print("Servidor ativo e escutando em")
    print(ip .. ":" .. port)

    return server
end

function server_loop(linda, server)
    local socket = require("socket")
    local cjson = require("cjson")
    
    if server == nil then
        server = server_init(socket)
        return server_loop(linda, server)
    end
    
    local client = server:accept()
    local message = client:receive("*l") or "<empty>"
    local product = cjson.decode(message)
    
    linda:send("update_server_data", function(data)
        table.insert(data.product_list, product)
    end)
    
    socket.sleep(1)
    local product_list = linda:get("product_list") or {}
    
    print("\n[")
    for k, v in ipairs(product_list) do
        print("\t" .. cjson.encode(v))
    end
    print("]\n")

    -- print("Received: " .. message)
    -- client:send("response\n")

    server_loop(linda, server)
end

local lanes = require("lanes").configure()
local linda = lanes.linda()

local conf = { globals = _G }
local server_data = { product_list = {} }

lanes.gen("*", conf, data_loop)(linda, server_data)
lanes.gen("*", conf, server_loop)(linda):join()