
for s in 0.1 0.01; do
    for s2 in 0.1 0.01; do
        for a in "2.0" "1.9" "1.7" "1.5" "1.3" "1.1"; do
            for n in 500 1000 5000; do
                #echo "julia simulator.jl -N $n -t "both" -s $s -m Schweinsberg -p $a -c "constant" -o "fixation_time" --type "time" --nb_simulations 5000 --selection_coefficient2 $s2" 
                time julia simulator.jl -N $n -t "both" -s $s -m Schweinsberg -p $a -c "constant" -o "fixation_time" --type "time" --nb_simulations 5000 --selection_coefficient2 $s2 &

            done
        done
    done
done


for s in 0.1 0.01; do
    for s2 in 0.1 0.01; do
        for a in "2.0" "1.9" "1.7" "1.5" "1.3" "1.1"; do
            for n in 500 1000 5000; do
                #echo "julia simulator.jl -N $n -t "both" -s $s -m Schweinsberg -p $a -c "constant" -o "fixation_probability" --type "probability" --nb_simulations 500000 --selection_coefficient2 $s2" 
                time julia simulator.jl -N $n -t "both" -s $s -m Schweinsberg -p $a -c "constant" -o "fixation_probability" --type "probability" --nb_simulations 500000 --selection_coefficient2 $s2 &
            done
        done
    done
done
