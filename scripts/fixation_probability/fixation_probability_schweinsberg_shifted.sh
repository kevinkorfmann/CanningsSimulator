for c in "sinus"; do
	for selection_type in "fecundity_constant" "viability_constant"; do
		for s in 0.1 0.01 0.0; do
			for a in "2.0" "1.9" "1.7" "1.5" "1.3" "1.1"; do
				if [[ $c == "sinus" ]]; then
					for n in 578 1156 5777; do
						#echo "julia simulator.jl -N $n -t $selection_type -s $s -m Schweinsberg -p $a -c $c -o "fixation_probability" --type "probability" --nb_simulations 500000 --shiftsinusby 3.141592653"
						time julia simulator.jl -N $n -t $selection_type -s $s -m Schweinsberg -p $a -c $c -o "fixation_probability" --type "probability" --nb_simulations 500000 --shiftsinusby 3.141592653 &
						if [[ $a == "1.5" ]]; then
							wait
						fi
					done
				fi
			done
		done
	done
done

