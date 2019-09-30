defmodule Project2 do

  #For running in iex
  def start(_type, args) do
    case args do
      [num_nodes, topology, algorithm | []] ->
        Project2.DynamicSupervisor.start_link(args)
        worker_list = Project2.DynamicSupervisor.create_workers([], num_nodes)
        Project2.Topology.build_topology(topology, worker_list)
        Project2.Server.begin_algorithm(algorithm, worker_list)
        loop(num_nodes)
      _ ->
        IO.puts 'Please put args num_nodes, topology, algorithm'
    end
  end

  #For running as executable
  def main(args \\ []) do
    case args do
      [num_nodes, topology, algorithm | []] ->
        Project2.DynamicSupervisor.start_link(args)
        worker_list = Project2.DynamicSupervisor.create_workers([], String.to_integer(num_nodes))
        Project2.Topology.build_topology(topology, worker_list)
        Project2.Server.begin_algorithm(algorithm, worker_list)
        loop(num_nodes)
      _ ->
        IO.puts 'Please put args num_nodes, topology, algorithm'
    end
  end

  #Busy wait not ideal
  def loop(num_nodes) do
    map = Project2.DynamicSupervisor.count_children
    num_active = elem(Map.fetch(map, :active), 1)
    if (num_active == String.to_integer(num_nodes)) do
      loop(num_nodes)
    end
  end
end
