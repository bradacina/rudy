defmodule RudyPerfCollector2 do
    def start_link do
        Agent.start(fn -> %{} end, name: __MODULE__)
    end

    def add_result(result) do
        Agent.update(__MODULE__, 
            fn(state) -> 
                Map.update(state, result, 1, &(&1+1)) 
            end
        )
    end

    def get_results do
        Agent.get(__MODULE__, fn(state)-> state end)
    end

    def clear_results do
        Agent.update(__MODULE__, fn(_) -> %{} end)
    end

    def stop do
        Agent.stop(__MODULE__)
    end
end