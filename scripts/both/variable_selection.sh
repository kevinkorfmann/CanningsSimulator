#!/usr/bin/env bash
set -euo pipefail

# ------------------------------
# Grid
# ------------------------------
Nlist="500 1000 5000"
alphas="2.0 1.9 1.7 1.5 1.3 1.1"
amps="0.00 0.01 0.10"          # <-- selection COEFFICIENT amplitudes (not multipliers)
phis="0.0 3.141592653"         # phases: φ=0, φ=π
periods="0.06283 0.006283"     # <-- now runs both slow & fast periods

# Concurrency control (optional): run up to this many jobs in parallel
MAX_JOBS="${MAX_JOBS:-8}"
function wait_for_slots() {
  while (( $(jobs -rp | wc -l) >= MAX_JOBS )); do
    sleep 0.5
  done
}

# Small helper to launch a job with slot control
run() {
  wait_for_slots
  echo "[launch]" "$*"
  "$@" &
}

for period in $periods; do
  # ------------------------------
  # TIME simulations (nb_simulations=5000)
  # ------------------------------

  echo "=== TIME: fecundity_sinus, period=$period ==="
  for N in $Nlist; do
    for a in $alphas; do
      for amp in $amps; do
        for phi in $phis; do
          run julia simulator.jl -N "$N" -t fecundity_sinus -s "$amp" \
            -m Schweinsberg -p "$a" -c constant \
            -o fixation_time --type time --nb_simulations 5000 \
            --selection_period "$period" --shiftsinusby "$phi"
        done
      done
    done
  done

  echo "=== TIME: viability_sinus, period=$period ==="
  for N in $Nlist; do
    for a in $alphas; do
      for amp in $amps; do
        for phi in $phis; do
          run julia simulator.jl -N "$N" -t viability_sinus -s "$amp" \
            -m Schweinsberg -p "$a" -c constant \
            -o fixation_time --type time --nb_simulations 5000 \
            --selection_period "$period" --shiftsinusby "$phi"
        done
      done
    done
  done

  echo "TIME runs done for period=$period."

  # ------------------------------
  # PROBABILITY simulations (nb_simulations=500000)
  # ------------------------------

  echo "=== PROB: fecundity_sinus, period=$period ==="
  for N in $Nlist; do
    for a in $alphas; do
      for amp in $amps; do
        for phi in $phis; do
          run julia simulator.jl -N "$N" -t fecundity_sinus -s "$amp" \
            -m Schweinsberg -p "$a" -c constant \
            -o fixation_probability --type probability --nb_simulations 500000 \
            --selection_period "$period" --shiftsinusby "$phi"
        done
      done
    done
  done

  echo "=== PROB: viability_sinus, period=$period ==="
  for N in $Nlist; do
    for a in $alphas; do
      for amp in $amps; do
        for phi in $phis; do
          run julia simulator.jl -N "$N" -t viability_sinus -s "$amp" \
            -m Schweinsberg -p "$a" -c constant \
            -o fixation_probability --type probability --nb_simulations 500000 \
            --selection_period "$period" --shiftsinusby "$phi"
        done
      done
    done
  done

  echo "PROB runs done for period=$period."
done

wait
echo "All runs complete."
