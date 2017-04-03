defmodule Rudy.Request do

    defstruct [
        request_line: nil,
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
        
        {index, len} = :binary.match(msg, "\r\n")
        size = byte_size(msg)

        status = :binary.part(msg, 0, index)
        rest = :binary.part(msg, index + len, size - index - len )

        request = %Rudy.Request{unparsed: rest}

        [verb, uri, version] = :binary.split(status, " ", [:global])

        request = Map.put(request, :request_line, %Rudy.Request.Line{verb: verb, uri: uri, version: version})

        request
    end

    def parse_headers(%Rudy.Request{} = request) do
        try do
            rest = Map.get(request, :unparsed)

            size = byte_size(rest)

            if size == 0 do
                throw {:done, request}
            end

            {index, len} = :binary.match(rest, "\r\n")
            
            if index == 0 do
                rest = :binary.part(rest, len, size - len)
                request = Map.put(request, :unparsed, rest)
                throw {:done, request}
            end

            header = :binary.part(rest, 0, index)
            rest = :binary.part(rest, index+len, size - index - len)

            {header_name, header_val} = parse_header(header)

            request = Map.update(request, :headers, %{header_name: header_val}, fn headers -> Map.put(headers, header_name, header_val) end)

            request = Map.put(request, :unparsed, rest)

            parse_headers(request)
        catch
            {:done, new_request} -> new_request
        end
    end

    def parse_header(line) do
        [name, val] = :binary.split(line, [":", ": "])
        {name, val}
    end

    def parse_body(%Rudy.Request{} = request) do
        rest = Map.get(request, :unparsed)

        Map.delete(request, :unparsed) 
            |> Map.put(:body, rest)
    end
end