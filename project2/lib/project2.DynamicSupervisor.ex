defmodule Project2.DynamicSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end
  #Implement worker generation correctly
  """
  def start_child() do
    #spec = %{id: Project2.Server, start: {Project2.Server, :start_link, []}}
    #spec = {Project2.Server.start_link, []}
    DynamicSupervisor.start_child(__MODULE__, Project2.Server)
  end
  """

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)

    #get num workers from argv
    create_workers([], 100)

    #get topology from argv
    #Preferably send calls to set state of node with neighbors while building graph
    Project2.Topology.build_topology("topology")
  end

  def create_workers(list, 0) do list end
  def create_workers(list, num) do
    agent = Project2.Server.start_link()
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
end
