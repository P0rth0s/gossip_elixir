defmodule Project2.Server do
    use GenServer

    def start_link do
        #Get rid of name and call by pid as scale up
        GenServer.start_link(__MODULE__, [])
    end

    def do_gossip(pid) do
        GenServer.call(pid, :gossip)
    end

    def do_push_sum(pid) do
        GenServer.call(pid, :push_sum)
    end

    def init(state) do
        {:ok, state}
    end

    def handle_call(:gossip, _from, state) do
        IO.puts 'gossip'
        {:reply, state, state}
    end

    def handle_call(:push_sum, _from, state) do
        IO.puts 'push sum'
        {:reply, state, state}
    end
end
