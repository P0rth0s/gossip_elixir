defmodule Project2.Topology do
    def build_topology(top) do
        case top do
            "full_network" -> full_network()
            "line" -> line()
            "random_2d_grid" -> random_2d_grid()
            "torud_grid_3d" -> torus_grid_3d()
            "honey_comb" -> honey_comb()
            "honey_comb_random" -> honey_comb_random()
        end
    end

    def full_network do
    end

    def line do
    end

    def random_2d_grid do

    end

    def torus_grid_3d do
    end

    def honey_comb do
    end

    def honey_comb_random do
    end
end
