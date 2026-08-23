function server_init(socket)
    local server = socket.tcp()
    assert(server:bind('*', 3000))
    server:listen(5)

    local ip, port = server:getsockname()
    print("Servidor ativo e escutando em")
    print(ip .. ":" .. port)

    return server
end

local socket = require("socket")
local server = server_init(socket)
local clients = {}

while true do
    local client = server:accept()
    local message = client:receive("*l") or "<vazio>"

    print("Received: " .. message)
    client:send("response\n")
end
