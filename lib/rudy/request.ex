defmodule Rudy.Request do
    
    defstruct [
        request_line: nil,
        headers: %{},
        body: nil,
        unparsed: nil ]
        
    def handle_request(msg) do
        
        request = %Rudy.Request{unparsed: msg}
        |> parse_request_line
        |> parse_headers
        |> parse_body
        
        IO.inspect(request)
    end
        
    def slice(to_slice, index, len) do
        size = byte_size(to_slice)
        
        first = :binary.part(to_slice, 0, index)
        rest = :binary.part(to_slice, index + len, size - index - len )

        {first, rest}
    end
    
    def parse_request_line(%Rudy.Request{} = request) do
        
        rest = Map.get(request, :unparsed)
        {index, len} = :binary.match(rest, "\r\n")
        {status, rest} = slice(rest, index, len)
        
        [verb, uri, version] = :binary.split(status, " ", [:global])
        
        request = 
            Map.put(request, :request_line,
                %Rudy.Request.Line{verb: verb, uri: uri, version: version})
            |> Map.put(:unparsed, rest)
        
        request
    end
    
    def parse_headers(%Rudy.Request{unparsed: x} = request) when byte_size(x) == 0 do
        request
    end

    def parse_headers(%Rudy.Request{} = request) do
        
        rest = Map.get(request, :unparsed)
        size = byte_size(rest)
        
        {index, len} = :binary.match(rest, "\r\n")
        
        request = 
        case index do
            0 ->
                rest = :binary.part(rest, len, size - len)
                Map.put(request, :unparsed, rest)
            _ ->
                {header, rest} = slice(rest, index, len)
        
                {header_name, header_val} = parse_header(header)
        
                request = Map.update(request, :headers, 
                    %{header_name: header_val},
                    fn headers -> Map.put(headers, header_name, header_val) end
                )
        
                request = Map.put(request, :unparsed, rest)
                
                parse_headers(request)
        end

        request
    end
    
    def parse_header(line) do
        [name, val] = :binary.split(line, [":", ": "])
        {name, val}
    end
    
    def parse_body(%Rudy.Request{} = request) do
        rest = Map.get(request, :unparsed)

        headers = Map.get(request, :headers)

        length = (Map.get(headers, "Content-Length") || "0")
            |> String.to_integer

        <<body::binary-size(length), tail::binary>> = rest
        
        Map.put(request, :unparsed, tail) 
            |> Map.put(:body, rest)
    end
end