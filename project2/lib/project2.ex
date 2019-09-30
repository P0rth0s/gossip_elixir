defmodule Project2 do

  def start(_type, args) do
    case args do
      [num_nodes, topology, algorithm | []] ->
        Project2.DynamicSupervisor.start_link(args)
        worker_list = Project2.DynamicSupervisor.create_workers([], num_nodes)
        Project2.Topology.build_topology(topology, worker_list)
        Project2.Server.begin_algorithm(algorithm, worker_list)
      _ ->
        IO.puts 'Please put args num_nodes, topology, algorithm'
    end
  end


  def main(args \\ []) do
    case args do
      [num_nodes, topology, algorithm | []] ->
        Project2.DynamicSupervisor.start_link(args)
        worker_list = Project2.DynamicSupervisor.create_workers([], String.to_integer(num_nodes))
        Project2.Topology.build_topology(topology, worker_list)
        Project2.Server.begin_algorithm(algorithm, worker_list)
      _ ->
        IO.puts 'Please put args num_nodes, topology, algorithm'
    end
  end

end
