defmodule Project2.Topology do
    def build_topology(top, worker_list) do
        case top do
            "full network" -> full_network(worker_list)
            "line" -> line(worker_list)
            "random 2d grid" -> random_2d_grid(worker_list)
            "torud grid 3d" -> torus_grid_3d(worker_list)
            "honeycomb" -> honey_comb(worker_list)
            "honeycomb random" -> honey_comb_random(worker_list)
            _ -> IO.puts 'Error not a valid topology.'
        end
    end

    def full_network(worker_list) do
        IO.puts 'hi'
        [hd | tl] = worker_list
        Project2.Server.add_neighbors(hd, worker_list)
    end

    def line(_worker_list) do
    end

    def random_2d_grid(_worker_list) do

    end

    def torus_grid_3d(_worker_list) do
    end

    def honey_comb(_worker_list) do
    end

    def honey_comb_random(_worker_list) do
    end
end
