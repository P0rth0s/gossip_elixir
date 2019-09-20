defmodule Project2.Server do
    use GenServer

    def start_link do
        #Get rid of name and call by pid as scale up
        GenServer.start_link(__MODULE__, %{times_heard_rumor: 0})
    end

    def do_push_sum(pid) do
        GenServer.call(pid, :push_sum)
    end

    def do_gossip(pid) do
        GenServer.call(pid, :gossip)
    end

    def add_neighbors(pid, list) do
        GenServer.cast(pid, {:add_neighbors, list})
    end

    #Project2.Topology.build_topology/1 must be called first
    def begin_algorithm(algorithm, worker_list) do
        pid = Enum.random(worker_list)
        case algorithm do
            "Gossip" ->
                do_gossip(pid)
            "Push-Sum"->
                do_push_sum(pid)
            _ -> IO.puts 'Invalid algorithm'
        end
    end

    #Server
    def init(state) do
        {:ok, state}
    end

    def handle_call(:push_sum, _from, state) do
        IO.puts 'push sum'
        {:reply, state, state}
    end

    #Not tested
    def handle_call(:gossip, _from, state) do
        count = Map.fetch(state, :times_heard_rumor)
        #cnt = count + 1 #This throws err for some reason
        Map.put(state, :times_heard_rumor, count) #Change to cnt
        cond do
            count < 10 -> #Change to cnt
                IO.puts 'continue'
                pid = Enum.random(Map.fetch(state, :neighbors))
                do_gossip(pid)
            true ->
                IO.puts 'done'
                # remove from neighbor list of others?
        end
        {:reply, count, state}
    end

    def handle_cast({:add_neighbors, list}, state) do
        neighbors = Map.fetch(state, :neighbors)
        Map.delete(state, :neighbors)
        neighbors = [list | neighbors]
        #List.flatten(neighbors) this throws err but should happen i think?
        Map.put(state, :neighbors, neighbors)
        {:noreply, state}
    end

end
