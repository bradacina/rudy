defmodule TestClient do
    import Socket

    @oneline "GET / HTTP/1.1\r\nHost: localhost:8080\r\nConnection: keep-alive\r\nUpgrade-Insecure-Requests: 1\r\nUser-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.98 Safari/537.36\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\r\nDNT: 1\r\nAccept-Encoding: gzip, deflate, sdch, br\r\nAccept-Language: en-US,en;q=0.8,fr;q=0.6\r\nCookie: returnUrl=%2Fexport%2Finvoices\r\n\r\n"

    @twoline_1 "POST / HTTP/1.1\r\nHost: localhost:8080\r\nConnection: keep-alive\r\nContent-Length: 182\r\nCache-Control: no-cache\r\nOrigin: chrome-extension://aicmkgpgakddgnaphhhpliifpcfhicfo\r\nUser-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.98 Safari/537.36\r\nContent-Type: application/x-www-form-urlencoded\r\nAccept: */*\r\nAccept-Encoding: gzip, deflate, br\r\nAccept-Language: en-US,en;q=0.8,fr;q=0.6,pt;q=0.4,it;q=0.2,nl;q=0.2,sv;q=0.2,es;q=0.2,de;q=0.2,fi;q=0.2,da;q=0.2,th;q=0.2"
    @twoline_2 "\r\n\r\nclient_id=B992463F-7B80-47FC-BE05-E70D0DCAC2F6&client_secret=daniel2go&grant_type=password&scope=read+write+offline_access&username=bogdan.radacina%40invoice2go.com&password=password"

    @threeline_1 "POST / HTTP/1.1\r"
    @threeline_2 "\nHost: localhost:8080\r\nConnection: keep-alive\r\nContent-Length: 182\r\nCache-Control: no-cache\r\nOrigin: chrome-extension://aicmkgpgakddgnaphhhpliifpcfhicfo\r\nUser-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.98 Safari/537.36\r\nContent-Ty"
    @threeline_3 "pe: application/x-www-form-urlencoded\r\nAccept: */*\r\nAccept-Encoding: gzip, deflate, br\r\nAccept-Language: en-US,en;q=0.8,fr;q=0.6,pt;q=0.4,it;q=0.2,nl;q=0.2,sv;q=0.2,es;q=0.2,de;q=0.2,fi;q=0.2,da;q=0.2,th;q=0.2\r\n\r\nclient_id=B992463F-7B80-47FC-BE05-E70D0DCAC2F6&client_secret=daniel2go&grant_type=password&scope=read+write+offline_access&username=bogdan.radacina%40invoice2go.com&password=password"
    
    def send_3_lines do
        connect() |> send([@threeline_1, @threeline_2, @threeline_3], 100)
    end

    def send_two_lines do
        connect() |> send([@twoline_1, @twoline_2], 100)
    end

    def send_whole do
        connect() |> send([@oneline],0)
    end

    def connect do
        {:ok, client} = Socket.connect("tcp://localhost:8080")
        client
    end

    def send(client, [hd| []], timeout) do
        Process.sleep(timeout)
        :ok = Socket.Stream.send(client,hd)
    end

    def send(client, [hd|tail], timeout) do
        Process.sleep(timeout)
        :ok = Socket.Stream.send(client, hd)
        send(client, tail, timeout)
    end
end