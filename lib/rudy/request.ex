defmodule Rudy.Request do

    defstruct [
        request_line: %Rudy.Request.Line{},
        headers: %{},
        body: nil,
        unparsed: nil ]

    def handle_request(port, msg) do
        
        request = msg
            |> parse_request_line
            |> parse_headers
            |> parse_body

        IO.inspect(request)
        x = Socket.Stream.send(port, "HTTP/1.1 200 OK\r\nContent-Length: 0\r\n\r\n")
    end

    def parse_request_line(msg) do
        %Rudy.Request{}
    end

    def parse_headers(%Rudy.Request{} = request) do
        request
    end

    def parse_body(%Rudy.Request{} = request) do
        request
    end
end