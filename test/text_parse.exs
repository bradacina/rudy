defmodule TextParse do
    
    @request "POST / HTTP/1.1\r\nHost: localhost:8080\r\nConnection: keep-alive\r\nContent-Length: 182\r\nCache-Control: no-cache\r\nOrigin: chrome-extension://aicmkgpgakddgnaphhhpliifpcfhicfo\r\nUser-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.98 Safari/537.36\r\nContent-Type: application/x-www-form-urlencoded\r\nAccept: */*\r\nAccept-Encoding: gzip, deflate, br\r\nAccept-Language: en-US,en;q=0.8,fr;q=0.6,pt;q=0.4,it;q=0.2,nl;q=0.2,sv;q=0.2,es;q=0.2,de;q=0.2,fi;q=0.2,da;q=0.2,th;q=0.2\r\n\r\nclient_id=B992463F-7B80-47FC-BE05-E70D0DCAC2F6&client_secret=daniel2go&grant_type=password&scope=read+write+offline_access&username=bogdan.radacina%40invoice2go.com&password=password"

    ##### Using Regex module

    def test_regex_perf(x) do
        # using Regex to parse 100K requests in 3.8 seconds
        {time, :ok} = :timer.tc(fn ->
            Enum.each(1..x, fn _ -> parse_regex(@request) end)
        end)
        
        IO.puts(time/1000)
    end

    def parse_regex(msg) do
        Regex.run(~r/(get|put|post|delete|head) (.+) (http\/1.[0,1])\r\n(?:(.+):\s?(.+)\r\n)*\r\n/mi, msg)
        Regex.scan(~r/(.+?):\s*(.+)\r\n/i, msg)
    end

    def parse_regex do
        parse_regex(@request)
    end

    ##### End using Regex module

    ##### Using String module

    def test_string_perf(x) do
        # using String to parse 100K requests in 3.1 seconds
        {time, :ok} = :timer.tc(
            fn ->
                Enum.each(1..x, 
                    fn _ -> parse_string(@request) end)
            end)
        IO.puts(time/1000)
    end

    def parse_string(msg) do
        [hd| rest] = String.split(msg, "\r\n", trim: true)
        status_line = hd |> String.trim("\r\n") |> String.split()
        
        headers = rest |> Enum.map(
            fn x ->
                x |> String.trim("\r\n") |> String.split( ": ", parts: 2)
            end)
    end

    def parse_string do
        parse_string(@request)
    end

    ###### End using String Module
    
    ###### Using :binary module

    def test_binary_perf(x) do
        # using :binary to parse 100K requests in 1.7 seconds
        {time, :ok} = :timer.tc(
            fn ->
                Enum.each(1..x, 
                    fn _ -> parse_binary(@request) end)
            end)
        IO.puts(time/1000)
    end

    def parse_binary do
        parse_binary(@request)
    end

    def parse_binary(msg) do
        result = msg
            |> parse_status(%{})
            |> parse_headers
    end

    def parse_status(msg, state) do
        {index, len} = :binary.match(msg, "\r\n")
        size = byte_size(msg)

        status = :binary.part(msg, 0, index)
        rest = :binary.part(msg, index + len, size - index - len )

        state = Map.put(state, :status, status)
            |> Map.put(state, :rest, rest)
    end

    def parse_headers(state) do
        try do
            rest = Map.get(state, :rest)

            size = byte_size(rest)

            if size == 0 do
                throw {:done, state}
            end

            {index, len} = :binary.match(rest, "\r\n")
            
            if index == 0 do
                rest = :binary.part(rest, len, size - len)
                state = Map.put(state, :rest, rest)
                throw {:done, state}
            end

            header = :binary.part(rest, 0, index)
            rest = :binary.part(rest, index+len, size - index - len)

            parsed_header = parse_header(header, byte_size(header))

            state = Map.update(state, :headers, [parsed_header], fn v -> [parsed_header|v] end)

            state = Map.put(state, :rest, rest)

            parse_headers(state)
        catch
            {:done, new_state} -> new_state
        end
    end

    def parse_header(line, length) do
        [name, val] = :binary.split(line, [":", ": "])
        {name, val}
    end

    ##### End using :binary module
end