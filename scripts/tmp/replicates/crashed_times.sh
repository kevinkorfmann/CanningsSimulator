for c in "constant" "sinus"; do
        for selection_type in "fecundity_constant" "viability_constant"; do
                for s in 0.0; do
                        for a in "2.0"; do

                                if [[ $c == "sinus" ]]; then
                                        for n in 5777; do
                                                echo "julia simulator.jl -N $n -t $selection_type -s $s -m Schweinsberg -p $a -c $c -o "fixation_time" --type "time" --nb_simulations 5000"
                                                #time julia simulator.jl -N $n -t $selection_type -s $s -m Schweinsberg -p $a -c $c -o "fixation_time" --type "time"  --nb_simulations 5000 &
                                                if [[ $a == "1.5" ]]; then
                                                        wait
                                                fi
                                        done
                                fi
                        done
                done
        done
done


for c in "constant" "sinus"; do
        for selection_type in "fecundity_constant" "viability_constant"; do
                for s in 0.0; do
                        for a in "2.0"; do

                                if [[ $c == "sinus" ]]; then
                                        for n in 5777; do
                                                echo "julia simulator.jl -N $n -t $selection_type -s $s -m Schweinsberg -p $a -c $c -o "fixation_time" --type "time" --nb_simulations 5000 --shiftsinusby 3.141592653"
                                                #time julia simulator.jl -N $n -t $selection_type -s $s -m Schweinsberg -p $a -c $c -o "fixation_time" --type "time"  --nb_simulations 5000 --shiftsinusby 3.141592653 &
                                                if [[ $a == "1.5" ]]; then
                                                        wait
                                                fi
                                        done
                                fi

                        done
                done
        done
done



c="constant"
for selection_type in "viability_sinus"; do
        for s in "1.01"; do
                for a in "1.9"; do
                        for n in 1000; do
                                echo "julia simulator.jl -N $n -t $selection_type -s $s -m Schweinsberg -p $a -c $c -o "fixation_time" --type "time" --nb_simulations 5000 --shiftsinusby 3.141592653"
                                #time julia simulator.jl -N $n -t $selection_type -s $s -m Schweinsberg -p $a -c $c -o "fixation_time" --type "time" --nb_simulations 5000 --shiftsinusby 3.141592653 &
                                # decrease the number of parallel processes
                                if [[ $a == "1.5" ]]; then
                                        wait
                                fi
                        done
                done
        done
done

