defmodule RudyPerf do

    require RudyPerfCollector2

    def start(x, sleep\\0) when x > 0 do
        RudyPerfCollector2.start_link

        1..x
        |> Enum.map(fn(z) ->
                {spawn(&start_one/0), z}
            end)
        |> Enum.each(fn({y,z}) ->
                Process.send_after(y, :go, z*sleep) 
            end)
    end

    defp start_one() do
        try do
            receive do
                :go ->
                    {:ok, client} = Socket.connect("tcp://localhost:8080")
                    :ok = Socket.Stream.send(client,"test")
                    {:ok, _} = Socket.Stream.recv(client)
                    :ok = Socket.close(client)

                    RudyPerfCollector2.add_result(:ok)
            end
        rescue
            x ->
            RudyPerfCollector2.add_result(x)
        end
    end
end