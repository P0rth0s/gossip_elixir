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
        end
    end

    def random_2d_grid(worker_list) do
        worker_locations = Enum.map(worker_list, fn worker ->
            %{pid: worker, x: :rand.uniform(1000), y: :rand.uniform(1000)} #.1 = 10
        end)
        worker_locations = Enum.sort_by worker_locations, &Map.fetch(&1, :x)
        #Enum.map(worker_locations, fn worker ->
        #end)
        x_diff = 0
        y_diff = 0
        distance = :math.sqrt(:math.pow(x_diff, 2) + :math.pow(y_diff, 2))
        #Search in bands across graph?
        #Get neighbor list
        #Send neighbor list
    end

    defp nth_root(n, x, precision \\ 1.0e-5) do # https://rosettacode.org/wiki/Nth_root#Elixir
        f = fn(prev) -> ((n - 1) * prev + x / :math.pow(prev, (n-1))) / n end
        fixed_point(f, x, precision, f.(x))
    end
    defp fixed_point(_, guess, tolerance, next) when abs(guess - next) < tolerance, do: next
    defp fixed_point(f, _, tolerance, next), do: fixed_point(f, next, tolerance, f.(next))

    def torus_grid_3d(worker_list) do
        #Cube but ends wrap
        len = Integer.floor_div(length(worker_list), 8)
        p = Kernel.trunc(nth_root(3,len))
        grid = Enum.map(Enum.chunk_every(worker_list, p), fn x -> Enum.chunk_every(x, p))
        grid_connect(grid)
        # for i <- [0..Kernel.trunc(len)] do
        #     Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i+5, len)))
        #     Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i-5, len)))
        #     Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i+3, len)))
        #     Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i-3, len)))
        #     Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i+1, len)))
        #     Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i-1, len)))
        # end
    end

    defp grid_connect([h|t]) do
        grid_connect(h)
        grid_connect(t)
        for x,y <- List.flatten(h), List.flatten(t) do
            Project2.Server.add_neighbors(x,y)
        end
    end

    defp grid_connect(list) do
        :ok
    end

    def honey_comb(worker_list) do
        len = Integer.floor_div(length(worker_list), 8)
        for i <- [0..Kernel.trunc(len)] do
            cond do
                rem(i, 2)!=0 -> Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i+5, len)))
            end
            cond do
                rem(i, 5)!=0 -> Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i+1, len)))
            end
        end
    end

    def honey_comb_random(worker_list) do
        len = Integer.floor_div(length(worker_list), 8)
        for i <- [0..Kernel.trunc(len)] do
            cond do
                rem(1, 2)!=0 -> Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i+5, len)))
                rem(I, 5)!=0 -> Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i+1, len)))
                true -> Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.random(worker_list))
            end#
        end
    end
end
