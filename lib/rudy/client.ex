defmodule Rudy.Client do
    def start(client, initialized, tcp_closed) do
        pid = spawn(__MODULE__, :init, [tcp_closed])
        Socket.process(client, pid)
        initialized.(client, pid)
    end

    def init(tcp_closed) do
        loop(tcp_closed)
    end

    defp loop(tcp_closed) do
        receive do
            {:tcp, port, msg } ->
                Rudy.Request.handle_request(port,msg)
                :ok = Socket.active(port, :once)
                loop(tcp_closed)
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