for s in 0.1 0.01 0.0; do
    for a in "2.0"; do

        for n in 1000; do
            time julia simulator.jl -N $n -t fecundity_constant -s $s -m fecundity_adapted_Schweinsberg -p $a --type "probability" -c constant -o "fixation_probability" --nb_simulations 500000
        done

    done
done
