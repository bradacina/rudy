defmodule Rudy.Server do
    def start() do
        proc = spawn_link(__MODULE__, :init, [])
        Process.register(proc, __MODULE__)
    end

    def init() do
        {:ok, server} = Socket.listen("tcp://*:8080")
        Rudy.Acceptor.start_link(server, &start_client/1)
        
        loop({server,%{}})
    end

    defp loop({server,clients} = state) do
        receive do
            :stop ->
                stop_internal(state)
                
            {:new_client, client, pid } ->
                clients = Map.put(clients, client, pid)
                :ok = Socket.active(client, :once)
                loop({server, clients})

            {:tcp_closed, port} ->
                pid = Map.get(clients, port)
                clients = Map.delete(clients,port)
                Process.exit(pid, :shutdown)
                
                loop({server, clients})

            :state ->
                IO.inspect(state)
                loop(state)
            x -> 
                IO.inspect(x) 
                loop(state)
        end
    end

    defp stop_internal({server,clients}) do
        Enum.each(clients, 
            fn ({port, pid}) -> 
                Process.exit(pid, :shutdown)
                Socket.close(port)
            end)
        
        Socket.close(server)
    end

    def new_client(client, pid) do
        send(__MODULE__, {:new_client, client, pid})
    end

    def start_client(client) do
        Rudy.Client.start(client, &new_client/2, &client_departed/1)
    end

    def client_departed(client) do
        send(__MODULE__, {:tcp_closed, client})
    end

    def stop() do
        send(__MODULE__, :stop)
        Process.unregister(__MODULE__)
    end

    def debug_state() do
        send(__MODULE__, :state)
    end
end