defmodule Project2.Topology do
    def build_topology(top, worker_list) do
        case top do
            "full_network" -> full_network(worker_list)
            "line" -> line(worker_list)
            "random_2d_grid" -> random_2d_grid(worker_list)
            "torus_grid_3d" -> torus_grid_3d(worker_list)
            "honeycomb" -> honey_comb(worker_list)
            "honeycomb_random" -> honey_comb_random(worker_list)
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
        end
    end

    def random_2d_grid(worker_list) do
        worker_locations = Enum.map(worker_list, fn worker ->
            %{pid: worker, x: :rand.uniform(1000), y: :rand.uniform(1000)} #.1 = 10
        end)
        worker_locations = Enum.sort_by worker_locations, &Map.fetch(&1, :x)
        Enum.map(worker_locations, fn worker ->
            for other_worker <- worker_locations -- [worker] do
                x_diff = elem(Map.fetch(worker, :x), 1) - elem(Map.fetch(other_worker, :x), 1)
                y_diff = elem(Map.fetch(worker, :y), 1) - elem(Map.fetch(other_worker, :y), 1)
                distance = :math.sqrt(:math.pow(x_diff, 2) + :math.pow(y_diff, 2))
                if (distance < 10) do #.1 = 10
                    Project2.Server.add_neighbors(elem(Map.fetch(worker, :pid), 1), [elem(Map.fetch(other_worker, :pid), 1)])
                end
            end
        end)
    end

    def torus_grid_3d(worker_list) do
        #Cube but ends wrap
        len = Integer.floor_div(length(worker_list), 8)
        for i <- 0..Kernel.trunc(len) do
            Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, 1))
            Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i-5, len)))
            Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i+3, len)))
            Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i-3, len)))
            Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i+1, len)))
            Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i-1, len)))
        end
    end

    def honey_comb(worker_list) do
        len = Integer.floor_div(length(worker_list), 8)
        for i <- 0..Kernel.trunc(len) do
            cond do
                rem(i, 2)!=0 -> Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i+5, len)))
                rem(i, 5)!=0 -> Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i+1, len)))
                true -> []
            end
        end
    end

    def honey_comb_random(worker_list) do
        len = Integer.floor_div(length(worker_list), 8)
        for i <- 0..Kernel.trunc(len) do
            cond do
                rem(i, 2)!=0 -> Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i+5, len)))
                rem(i, 5)!=0 -> Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i+1, len)))
                true -> Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.random(worker_list))
            end#
        end
    end

end
