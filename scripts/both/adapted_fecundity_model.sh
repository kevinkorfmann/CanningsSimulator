for s in 0.01 0.1 0.0; do
    for a in "2.0" "1.9" "1.7" "1.5" "1.3"; do
            for n in 1000 500 5000; do
                julia simulator.jl -N $n -t fecundity_constant -s $s -m fecundity_adapted_Schweinsberg -p $a -c constant -o "fixation_time" --type "time" --nb_simulations 5000 &
            done
    done
done



for s in 0.1 0.01 0.0; do
    for a in "2.0" "1.9" "1.7" "1.5" "1.3"; do

        for n in 500 1000 5000; do
            julia simulator.jl -N $n -t fecundity_constant -s $s -m fecundity_adapted_Schweinsberg -p $a --type "probability" -c constant -o "fixation_probability" --nb_simulations 500000 &
        done

    done
done


