
for c in "constant"; do
	for selection_type in "fecundity_constant"; do
		for s in 0.0 0.1 0.01; do
			for a in "2.0"; do

				if [[ $c == "constant" ]]; then
					for n in 1000; do
						#echo "julia simulator.jl -N $n -t $selection_type -s $s -m Schweinsberg -p $a --type "probability" -c $c -o "fixation_probability" --nb_simulations 500000"
						time julia simulator.jl -N $n -t $selection_type -s $s -m Schweinsberg -p $a --type "probability" -c $c -o "fixation_probability" --nb_simulations 500000 &
						# decrease the number of parallel processes
						if [[ $a == "1.5" ]]; then
							wait
						fi
					done
				fi

				
			done
		done
	done
done

#"sinus"