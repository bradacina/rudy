defmodule Rudy.Client do
    def start(client, initialized, tcp_closed) do
        pid = spawn(__MODULE__, :init, [tcp_closed])
        Socket.process(client, pid)
        initialized.(client, pid)
    end

    def init(tcp_closed) do
        loop(tcp_closed, nil)
    end

    defp concat(a,b) do
        if a == nil || a == "" do
            b
        else
            a<>b
        end
    end

    defp loop(tcp_closed,incomplete) do
        receive do
            {:tcp, port, msg } ->

                msg = concat(incomplete, msg)

                incomplete =
                try do
                    request = Rudy.Request.handle_request(msg)
                    Map.get(request, :unparsed)
                rescue
                    MatchError -> msg
                end

                Socket.Stream.send(port, "HTTP/1.1 200 OK\r\nContent-Length: 0\r\n\r\n")

                :ok = Socket.active(port, :once)
                loop(tcp_closed, incomplete)
            {:tcp_closed, port} ->
                tcp_closed.(port)
                :ok
            :stop ->
                :ok
        end
    end

    def stop(pid) do
        send(pid, :stop)
    end
end