using Distributions

function schweinsberg_offspring(nb_individuals, alpha, p0)
    if p0 == 1
        return 0
    end

    random_uni = rand(Uniform(), nb_individuals)
    vals = exp.(1/alpha * log.((1 - p0) ./ random_uni))

    total = sum(vals)
    int_part = floor(total)
    frac_part = total - int_part

    return int_part + (rand() < frac_part)
end

# ---- parameters ----
nb_individuals = 1
alpha = 1.1
p0 = 0.0

# ---- simulate multiple draws ----
for gen in 1:1000
    n_offspring = schweinsberg_offspring(nb_individuals, alpha, p0)
    println("Generation $gen: number of offspring = $n_offspring")
end

