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
        Enum.map(worker_list, fn worker ->
            neighbor_list = worker_list -- [ worker ]
            Project2.Server.add_neighbors(worker, neighbor_list)
        end)
    end

    def line(worker_list) do
        [hd, li | tl] = worker_list
        Project2.Server.add_neighbors(hd, [li])
        line([li | tl], hd)
    end
    def line(worker_list, previous) do
        case worker_list do
            [hd, li | tl] ->
                Project2.Server.add_neighbors(hd, [previous, li | []])
                line([li | tl], hd)
            [hd | []] ->
                Project2.Server.add_neighbors(hd, [previous])
            _ ->
                #Should be unreachable
                :done
        end
    end

    def random_2d_grid(_worker_list) do
        _x = Enum.random(100)
        _y = Enum.random(100)
    end

    def torus_grid_3d(_worker_list) do
        #Cube but ends wrap?
    end

    def honey_comb(_worker_list) do
    end

    def honey_comb_random(_worker_list) do
    end
end
