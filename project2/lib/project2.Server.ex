defmodule Project2.Server do
    use GenServer

    def start_link do
        GenServer.start_link(__MODULE__, %{times_heard_rumor: 0, neighbors: []})
    end

    def do_push_sum(pid) do
        GenServer.call(pid, :push_sum)
    end

    def do_gossip(pid) do
        GenServer.cast(pid, {:gossip, "My Message"})
    end

    def add_neighbors(pid, list) do
        GenServer.cast(pid, {:add_neighbors, list})
    end

    def get_neighbors(pid) do
        GenServer.call(pid, :get_neighbors)
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

    def handle_call(:get_neighbors, _from, state) do
        neighbors = Map.fetch(state, :neighbors)
        {:reply, neighbors, state}
    end

    #Make msg not call so can recursively call with do_gossip and avoid timeout
    def handle_cast({:gossip, _msg}, state) do
        count = elem(Map.fetch(state, :times_heard_rumor), 1)
        count = count + 1
        state = Map.put(state, :times_heard_rumor, count)
        cond do
            count < 10 ->
                IO.puts 'continue'
                pid = Enum.random(elem(Map.fetch(state, :neighbors), 1))
                do_gossip(pid)
            true ->
                IO.puts 'done'
                # remove from neighbor list of others?
        end
        {:noreply, state}
    end

    def handle_cast({:add_neighbors, list}, state) do
        neighbors = elem(Map.fetch(state, :neighbors), 1)
        neighbors = [list | neighbors]
        neighbors = List.flatten(neighbors)
        state = Map.put(state, :neighbors, neighbors)
        {:noreply, state}
    end

end
