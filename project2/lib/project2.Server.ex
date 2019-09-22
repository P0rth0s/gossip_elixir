defmodule Project2.Server do
    use GenServer

    def start_link do
        GenServer.start_link(__MODULE__, %{times_heard_rumor: 0, neighbors: [], w: 1, s: 1, push_sum_history: []})
    end

    def do_push_sum(pid, s, w) do
        GenServer.cast(pid, {:push_sum, s, w})
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
            "Push Sum"->
                do_push_sum(pid, 0, 0)
            _ -> IO.puts 'Invalid algorithm'
        end
    end

    #Server
    def init(state) do
        {:ok, state}
    end

    def handle_call(:get_neighbors, _from, state) do
        neighbors = Map.fetch(state, :neighbors)
        {:reply, neighbors, state}
    end

    def handle_cast({:add_neighbors, list}, state) do
        neighbors = elem(Map.fetch(state, :neighbors), 1)
        neighbors = [list | neighbors]
        neighbors = List.flatten(neighbors)
        state = Map.put(state, :neighbors, neighbors)
        {:noreply, state}
    end

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

    @push_sum_difference :math.pow(10, -10)
    def handle_cast({:push_sum, s, w}, state) do
        my_s = elem(Map.fetch(state, :s), 1) + s
        my_w = elem(Map.fetch(state, :w), 1) + w
        sum_estimate = my_s / my_w
        push_sum_history = elem(Map.fetch(state, :push_sum_history), 1)
        push_sum_history = [sum_estimate | push_sum_history]
        state = Map.put(state, :push_sum_history, push_sum_history)
        case push_sum_history do
            [_hd, _snd, thrd | _] ->
                cond do
                    sum_estimate - thrd < @push_sum_difference ->
                        state = continue_push_sum(state, my_s, my_w)
                        {:noreply, state}
                    true ->
                        IO.puts 'terminate'
                        {:noreply, state}
                end
            _ ->
                state = continue_push_sum(state, my_s, my_w)
                {:noreply, state}
        end
    end

    def continue_push_sum(state, my_s, my_w) do
        my_s = my_s / 2
        my_w = my_w / 2
        state = Map.put(state, :s, my_s)
        state = Map.put(state, :w, my_w)
        pid = Enum.random(elem(Map.fetch(state, :neighbors), 1))
        do_push_sum(pid, my_s, my_w)
        state
    end
end
