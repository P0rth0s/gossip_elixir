#At 10,000 nodes might take a while to finish, be patient
mix escript.build
echo "Gossip"
for i in 4 16 32 64 128 256 512 1024 2048
do
    echo "Full Network $i"
    time ./project2 $i "full_network" Gossip
    echo "Line $i"
    time ./project2 $i "line" Gossip
    echo "Random $i"
    time ./project2 $i "random_2d_grid" Gossip
    echo "Torus $i"
    time ./project2  $i "torus_grid_3d" Gossip
    echo "Honeycomb $i"
    time ./project2  $i "honeycomb" Gossip
    echo "Honeycomb Random $i"
    time ./project2  $i "honeycomb_random" Gossip
done

echo "**********************"
echo "Push Sum"
for i in 4 16 32 64 128 256 512 1024 2048
do
    echo "Full Network $i"
    time ./project2 $i "full_network" Push_Sum
    echo "Line $i"
    time ./project2 $i "line" Push_Sum
    echo "Random $i"
    time ./project2 $i "random_2d_grid" Push_Sum
    echo "Torus $i"
    time ./project2  $i "torus_grid_3d" Gossip
    echo "Honeycomb $i"
    time ./project2  $i "honeycomb" Gossip
    echo "Honeycomb Random $i"
    time ./project2  $i "honeycomb_random" Gossip
done