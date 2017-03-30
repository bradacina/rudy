defmodule RudyPerfCollector do
    def start do
        pid = spawn_link(__MODULE__, :init, [])
        Process.register(pid, __MODULE__)
    end

    def init() do
        loop(%{})
    end

    defp loop(state) do
        receive do
            {:result, result} ->
                state = Map.update(state, result, 1, &(&1+1))
                loop(state)
            :dump ->
                IO.inspect(state)
                loop(state)
            :clear ->
                loop(%{})
            :stop -> :ok
        end
    end

    def stop() do
        send(__MODULE__, :stop)
    end

    def send_result(result) do
        send(__MODULE__, {:result, result})
    end

    def dump do
        send(__MODULE__, :dump)
    end

    def clear do
        send(__MODULE__, :clear)
    end
end