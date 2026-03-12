



for c in "sinus"; do
	for selection_type in "viability_constant"; do
		for s in 0.01; do
			for a in "1.1"; do


				if [[ $c == "sinus" ]]; then
					for n in 5777; do
						echo "julia simulator.jl -N $n -t $selection_type -s $s -m Schweinsberg -p $a -c $c -o "fixation_time" --type "time" --nb_simulations 1000"
						time julia simulator.jl -N $n -t $selection_type -s $s -m Schweinsberg -p $a -c $c -o "fixation_time" --type "time"  --nb_simulations 1000
						if [[ $a == "1.5" ]]; then
							wait
						fi
					done
				fi


			done
		done
	done
done

