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
        Enum.map(worker_locations, fn worker ->
            for other_worker <- worker_locations do
                x_diff = elem(Map.fetch(worker, :x), 1) - elem(Map.fetch(other_worker, :x), 1)
                y_diff = elem(Map.fetch(worker, :y), 1) - elem(Map.fetch(other_worker, :y), 1)
                distance = :math.sqrt(:math.pow(x_diff, 2) + :math.pow(y_diff, 2))
                if (distance < 10) do #.1 = 10
                    Project2.Server.add_neighbors(elem(Map.fetch(worker, :pid), 1), [elem(Map.fetch(other_worker, :pid), 1)])
                end
            end
        end)
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
        grid = Enum.map(Enum.chunk_every(worker_list, p), fn x -> Enum.chunk_every(x, p) end)
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
        cond do
            length(h)!=length(t) -> IO.puts("oops1")
        end
        grid_connect(h)
        grid_connect(t)
        len = length(h)
        for i <- [0..len-1] do
            Project2.Server.add_neighbors(Enum.at(h, i),Enum.at(t, i))
        end
    end

    defp grid_connect(_list), do: :ok

    defp roots(p), do: (1.0+Math.sqrt(1.0+8.0*p))/4.0

    def honey_comb(worker_list) do
        len = Integer.floor_div(length(worker_list), 8)
        m = roots(len)
        n = 2*m-1
        chunks = Enum.chunk_every(worker_list, n) # m chunks of length n
        for chunk <- chunks do
            line(chunk)
        end
        for i <- [1..m-1] do #build one hexagon at a time, overlapping on one edge
            zip_hexagons(Enum.at(chunks, i), Enum.at(chunks, i-1))
        end
        # for i <- [0..Kernel.trunc(len)] do
        #     cond do
        #         rem(i, 2)!=0 -> Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i+5, len)))
        #     end
        #     cond do
        #         rem(i, 5)!=0 -> Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i+1, len)))
        #     end
        # end
    end

    def honey_comb_random(worker_list) do
        len = Integer.floor_div(length(worker_list), 8)
        m = roots(len)
        n = 2*m-1
        chunks = Enum.chunk_every(worker_list, n) # m chunks of length n
        for chunk <- chunks do
            line(chunk)
        end
        for i <- [1..m-1] do #build one hexagon at a time, overlapping on one edge
            zip_hexagons(Enum.at(chunks, i), Enum.at(chunks, i-1))
        end
        for worker <- worker_list do
            Project2.Server.add_neighbors(worker, Enum.random(worker_list))
        end
        # len = Integer.floor_div(length(worker_list), 8)
        # for i <- [0..Kernel.trunc(len)] do
        #     cond do
        #         rem(1, 2)!=0 -> Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i+5, len)))
        #         rem(I, 5)!=0 -> Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.at(worker_list, rem(i+1, len)))
        #         true -> Project2.Server.add_neighbors(Enum.at(worker_list, i), Enum.random(worker_list))
        #     end#
        # end
    end

    defp zip_hexagons(list1, list2) when length(list1)==length(list2) do # builds the honeycomb structure
        p = Integer.floor_div(length(list1), 2)
        for i <- [0..p-1] do
            Project2.Server.add_neighbors(Enum.at(list1, i*2), Enum.at(list2, i*2))
            Project2.Server.add_neighbors(Enum.at(list2, i*2), Enum.at(list1, i*2))
        end
    end

end
