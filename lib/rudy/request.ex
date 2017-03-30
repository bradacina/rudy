defmodule Rudy.Request do
    def handle_request(port, msg) do
        #IO.puts "received:"
        #IO.inspect msg
        x = Socket.Stream.send(port, "HTTP/1.1 200 OK\r\nContent-Length: 0\r\n\r\n")
        #IO.puts("sent reply")
    end
end