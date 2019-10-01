mix escript.build
echo "Gossip"
for i in 10 100 1000 10000
do
    echo "Full Network $i"
    time ./project2 $i "full_network" Gossip
    echo "Line $i"
    time ./project2 $i "line" Gossip
    echo "Random $i"
    time ./project2 $i "random_2d_grid" Gossip
done

echo "**********************"
echo "Push Sum"
for i in 10 100 1000 10000
do
    echo "Full Network $i"
    time ./project2 $i "full_network" Push_Sum
    echo "Line $i"
    time ./project2 $i "line" Push_Sum
    echo "Random $i"
    time ./project2 $i "random_2d_grid" Push_Sum
done

#echo "Torus"
#time ./project2  16 "torus_grid_3d" Gossip
#echo "Honeycomb"
#./project2  11 "honeycomb" Gossip
#echo "Honeycomb Random"
#./project2  11 "honeycomb_random" Gossip