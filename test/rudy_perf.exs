defmodule RudyPerf do

    require RudyPerfCollector2

    def start(how_many, sleep\\0) when x > 0 do
        RudyPerfCollector2.start_link

        1..how_many
        |> Enum.map(fn(num) ->
                {spawn(&start_one/0), num}
            end)
        |> Enum.each(fn({pid,num}) ->
                Process.send_after(pid, :go, num * sleep) 
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