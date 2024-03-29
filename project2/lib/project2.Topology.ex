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

    defp nth_root(n, x, precision \\ 1.0e-5) do # https://rosettacode.org/wiki/Nth_root#Elixir
        f = fn(prev) -> ((n - 1) * prev + x / :math.pow(prev, (n-1))) / n end
        fixed_point(f, x, precision, f.(x))
    end
    defp fixed_point(_, guess, tolerance, next) when abs(guess - next) < tolerance, do: next
    defp fixed_point(f, _, tolerance, next), do: fixed_point(f, next, tolerance, f.(next))

    def torus_grid_3d(old_worker_list) do
        worker_list = grid_list_pad(old_worker_list)
        len = Integer.floor_div(length(worker_list), 8)
        p = Kernel.trunc(nth_root(3,len))
        grid = Enum.map(Enum.chunk_every(worker_list, p), fn x -> Enum.chunk_every(x, p) end)
        grid_connect(grid)
    end

    defp grid_list_pad(old_worker_list) do
        len = length(old_worker_list)
        new_worker_list = []
        new_worker_list = if len < 8 do
            new_worker_list ++ Project2.DynamicSupervisor.create_workers([], 8-len)
        else
            []
        end
        new_worker_list = if rem(len, 4) != 0 do
            new_worker_list ++ Project2.DynamicSupervisor.create_workers([], 4-rem(len, 4))
        else
            new_worker_list
        end
        old_worker_list ++ new_worker_list

    end

    defp grid_connect(list) when length(list)>1 do
        [h|t] = Enum.chunk(List.flatten(list), Integer.floor_div(length(list), 2))
        len = length(h)
        # if len != length(t), do: IO.puts("Error. Attempting to connect asymmetric grid.")
        grid_connect(h)
        grid_connect(t)
        for i <- h, j <- t do
            Project2.Server.add_neighbors(i,[j])
            #Project2.Server.add_neighbors(j,[i])
            Enum.map(j, fn k -> Project2.Server.add_neighbors(k, [i]) end)
        end
    end

    defp grid_connect(_list), do: :ok

    defp roots(p), do: (1.0+:math.sqrt(1.0+8.0*p))/4.0

    def honey_comb(old_worker_list) do
        worker_list = honey_list_pad(old_worker_list)
        len = length(worker_list)
        m = Kernel.trunc(2*roots(len)-1)
        n = Integer.floor_div(len, m)
        chunks = Enum.chunk_every(worker_list, n, m, :discard) # m chunks of length n
        for chunk <- chunks do
            line(chunk)
        end
        other = Enum.drop(chunks, 1)
        for i <- chunks, j <- other do #build one hexagon at a time, overlapping on one edge
            zip_hexagons(i,j)
        end
    end

    def honey_comb_random(old_worker_list) do
        # Adjust list length to make is all hexagons
        worker_list = honey_list_pad(old_worker_list)
       len = length(worker_list)
        m = Kernel.trunc(2*roots(len)-1)
        n = Integer.floor_div(len, m)
        chunks = Enum.chunk_every(worker_list, n, m, :discard) # m chunks of length n
        for chunk <- chunks do
            line(chunk)
        end
        other = Enum.drop(chunks, 1)
        for i <- chunks, j <- other do #build one hexagon at a time, overlapping on one edge
            zip_hexagons(i,j)
        end
        for worker <- worker_list do
            Project2.Server.add_neighbors(worker, Enum.random(worker_list))
        end
    end

    defp honey_list_pad(old_worker_list) do
        len = length(old_worker_list)
        new_worker_list = []
        new_worker_list = if len < 6 do
            new_worker_list ++ Project2.DynamicSupervisor.create_workers([], 8-len)
        else
            []
        end
        new_worker_list = if rem(len, 15) != 0 do
            new_worker_list ++ Project2.DynamicSupervisor.create_workers([], 4-rem(len, 4))
        else
            new_worker_list
        end
        old_worker_list ++ new_worker_list
    end

    defp zip_hexagons(list1, list2) do # builds the honeycomb structure
        p = Integer.floor_div(length(list1), 2)
        actors1 = Enum.drop_every(list1,2)
        actors2 = Enum.drop_every(list2,2)
        for i <- actors1, j <- actors2 do
            Project2.Server.add_neighbors(i,j)
            Project2.Server.add_neighbors(j,i)
        end
    end
end
