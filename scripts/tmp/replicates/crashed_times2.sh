c="constant"
for selection_type in "fecundity_sinus"; do
        for s in "1.01"; do
                for a in "1.4" "1.6" "1.9"; do
                        for n in 5000; do
                                echo "julia simulator.jl -N $n -t $selection_type -s $s -m Schweinsberg -p $a -c $c -o "fixation_time" --type "time" --nb_simulations 5000 --shiftsinusby 3.141592653"
                                #time julia simulator.jl -N $n -t $selection_type -s $s -m Schweinsberg -p $a -c $c -o "fixation_time" --type "time" --nb_simulations 5000 --shiftsinusby 3.141592653 &
                        done
                done
        done
done

