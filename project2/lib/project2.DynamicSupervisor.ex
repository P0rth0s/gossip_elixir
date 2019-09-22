defmodule Project2.DynamicSupervisor do
  use DynamicSupervisor

  def start_link() do
    DynamicSupervisor.start_link(__MODULE__, name: __MODULE__)
  end

  def start_child(id_num) do
    spec = %{id: id_num, start: {Project2.Server, :start_link, []}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def init(_) do
    DynamicSupervisor.init(
      strategy: :one_for_one
    )
  end

  def create_workers(list, 0) do list end
  def create_workers(list, num) do
    agent = start_child(num)
    case agent do
      {:ok, pid} ->
        newlist = [pid | list]
        num = num - 1
        create_workers(newlist, num)
      _ ->
        IO.puts 'Error creating worker, Retrying'
        create_workers(list, num)
    end
  end

  def do_stuff do
    #Get vars from argv
    worker_list = create_workers([], 4)
    Project2.Topology.build_topology("line", worker_list)
    [hd, snd, thrd, tl | []] = worker_list
    Project2.Server.get_neighbors(thrd)
    #Project2.Server.begin_algorithm("Push Sum", worker_list)
  end
end
