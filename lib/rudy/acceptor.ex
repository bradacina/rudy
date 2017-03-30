defmodule Rudy.Acceptor do
    def start_link(server, accept_callback) do
        spawn_link(__MODULE__, :init, [server, accept_callback])
    end

    def init(server,accept_callback) do
        loop({server, accept_callback})
    end

    defp loop({server, accept_callback} = state) do
        case Socket.accept(server) do
            {:ok, client} -> 
                accept_callback.(client)
                loop(state)
            {:error, _} -> :ok
        end
        
    end
end