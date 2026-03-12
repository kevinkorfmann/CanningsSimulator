module CanningsSimulator

using Random, Distributions
using Test
using DataFrames
using PyCall
using Statistics

scipy_stats = pyimport("scipy.stats");
numpy_random = pyimport("numpy.random");

# Poisson number of offspring

function poisson_offspring(λ,  nb_individuals=1)::Int
    return sum(rand(Poisson(λ), nb_individuals))
end;



# Schweinsberg number of offspring
#function schweinsberg_offspring(nb_individuals, alpha, p0)
#    if p0 == 1
#        return 0
#    end
#    random_uni = rand(Uniform(), nb_individuals)
#    return nb_offspring = sum(floor.(exp.(1/alpha * log.((1-p0)./random_uni))))
#end

# Schweinsberg number of offspring

#function schweinsberg_offspring(nb_individuals, alpha, p0)
#    if p0 == 1
#        return 0
#    end
#
#    random_uni = rand(Uniform(), nb_individuals)
#    vals = exp.(1/alpha * log.((1 - p0) ./ random_uni))
#
#    total = sum(vals)
#    int_part = floor(total)
#    frac_part = total - int_part
#
#    return int_part + (rand() < frac_part)
#end

function schweinsberg_offspring(nb_individuals, alpha, p0)
    if p0 == 1
        return 0
    end
    random_uni = rand(Uniform(), nb_individuals)
    #return nb_offspring = floor(sum(exp.(1/alpha * log.((1-p0)./random_uni))))
    return nb_offspring = sum(floor.(exp.(1/alpha * log.((1-p0)./random_uni))))
end



function get_schweinsber_param(alpha_x=2,p0_x=0,s=0,optimize_alpha=true)
    results = Dict()
    DOABLE = true
    if optimize_alpha
      p0_y = p0_x
      truc=(1+s)*((alpha_x+1)/(alpha_x) )
      alpha_y=1/(truc-1)
      if(alpha_y<1 || alpha_y>2)
        DOABLE=false
      end
    else
      alpha_y = alpha_x
      truc=((1+s)^alpha_x)*(1-p0_x)
      p0_y=(1 - truc)
      if(p0_y<0 || p0_y>1)
        DOABLE=false
      end
     end
   
    if DOABLE 
      results["alpha_y"] = alpha_y
      results["p0_y"] = p0_y
    end 
    return results
  end


"""
  function get_schweinsber_param(alpha_x=2, p0_x=0, s=0, optimize_alpha=true)
    results = Dict()
    doable = true

    if optimize_alpha
        # simple alpha-rescale
        alpha_y = alpha_x / (1 + s)
        p0_y    = p0_x
        # keep alpha in (1,2]
        if alpha_y < 1 || alpha_y > 2
            doable = false
        end

    else
        # original p0-rescale branch unchanged
        alpha_y = alpha_x
        truс     = ((1 + s)^alpha_x) * (1 - p0_x)
        p0_y     = 1 - truс
        if p0_y < 0 || p0_y > 1
            doable = false
        end
    end

    if doable
        results["alpha_y"] = alpha_y
        results["p0_y"]    = p0_y
    end

    return results
end
"""


  


function schweinsberg_under_selection_offspring(nb_individuals, alpha, p0, s)
    new_alpha = get_schweinsber_param(alpha, p0, s, true)["alpha_y"]
    #print("Fecundity adapted offspring func. ", new_alpha )
    return schweinsberg_offspring(nb_individuals, new_alpha, p0)
end



abstract type Sampler end

mutable struct PoissonSampler <: Sampler
     λ::Float64
     nb_individuals::Int64 

     function PoissonSampler(λ::Float64)
          return new(λ, 0)
     end
end

mutable struct SchweinsbergSampler <: Sampler
     nb_individuals::Int64
     alpha::Float64
     p0::Float64
     s::Float64

     function SchweinsbergSampler(alpha::Float64)
          return new(0, alpha, 0.0)
     end

     function SchweinsbergSampler(alpha::Float64, s)
        return new(0, alpha, 0.0, s)
   end

end


sample_offspring(s::PoissonSampler) = poisson_offspring(s.λ, s.nb_individuals);
sample_offspring(s::SchweinsbergSampler) = schweinsberg_offspring(s.nb_individuals, s.alpha, s.p0);
sample_adapted_offspring(s::SchweinsbergSampler) = schweinsberg_under_selection_offspring(s.nb_individuals, s.alpha, s.p0, s.s);


function nb_next_generation(
    nb_individuals_type_1::Int64,
    pop_size::Int64,
    selection_fecundity,#::Float64,
    selection_viability::Float64,
    sampler::Sampler,
)::Int64

    sampler.nb_individuals = nb_individuals_type_1


    if typeof(selection_fecundity) == Float64
        nb_offspring_type_1 = floor((1+selection_fecundity) * sample_offspring(sampler))
    else
        selection_fecundity.nb_individuals = nb_individuals_type_1
        nb_offspring_type_1 = floor(sample_adapted_offspring(selection_fecundity))
    end

    if nb_offspring_type_1 > 100_000_000
        nb_offspring_type_1 = 100_000_000
        println("Bound offspring to 1e8 (nb_offspring_type_1)", nb_offspring_type_1);
    end


    sampler.nb_individuals = pop_size - nb_individuals_type_1
    @assert sampler.nb_individuals >= 0 string("pop_size ", pop_size, " - nb_individuals_type_1 ", nb_individuals_type_1, " should be positive")
    nb_other_offspring = sample_offspring(sampler)
    
    
    #println("nb_other_offspring ", nb_other_offspring)
    if nb_other_offspring > 100_000_000
        nb_other_offspring = 100_000_000
        println("Bound offspring to 1e8 (nb_other_offspring)", nb_other_offspring);
    end

    nb_offspring_total = nb_offspring_type_1 + nb_other_offspring

    if nb_offspring_total >= pop_size

        offspring_shortage = 0
        if selection_viability == 0
            surviving_offspring_type_1 = numpy_random.hypergeometric(nb_offspring_type_1, nb_other_offspring, pop_size)
        else


            #println("0 nb_offspring_total: ", nb_offspring_total," nb_offspring_type_1: ", nb_offspring_type_1," pop_size: ", pop_size, " 1+selection_viability:", 1+selection_viability)
            odds = max(1e-12, 1 + selection_viability)  # keep odds > 0
            #surviving_offspring_type_1 = scipy_stats.nchypergeom_wallenius.rvs(nb_offspring_total, nb_offspring_type_1, pop_size, 1+selection_viability)
            surviving_offspring_type_1 = scipy_stats.nchypergeom_wallenius.rvs(nb_offspring_total, nb_offspring_type_1, pop_size, odds)


            #println("1 nb_offspring_total: ", nb_offspring_total," nb_offspring_type_1: ", nb_offspring_type_1," pop_size: ", pop_size, " 1+selection_viability:", 1+selection_viability, " surviving_offspring_type_1:", surviving_offspring_type_1)
        end
        
    else
        offspring_shortage = pop_size - nb_offspring_total
        #println("offspring_shortage ", offspring_shortage)
        nb_additional_offspring_type_1 = rand(Binomial(offspring_shortage, nb_individuals_type_1/pop_size))
        #println("nb_additional_offspring_type_1 ", nb_additional_offspring_type_1)
        surviving_offspring_type_1 = nb_offspring_type_1 + nb_additional_offspring_type_1
    end

    return surviving_offspring_type_1
end;


function check_finished(nb_type_1, pop_size)
    fixation = nb_type_1 >= pop_size
    extinction = nb_type_1 == 0
    return fixation || extinction
end;






abstract type Modifier end


mutable struct ConstantModifier <: Modifier
    n
end


mutable struct SinusModifier <: Modifier
    t::Int64
    n::Float64
    period::Float64
    amplitude::Float64
    shiftxby::Float64
   
    function SinusModifier(
        n::Float64,
        period::Float64,
        amplitude::Float64,
        shiftxby::Float64
    )
        return new(1, n, period, amplitude, shiftxby)
   end
end


function get_sinus_value(t, amplitude, period, n, shiftxby, discretize)
    if discretize
        return y = floor(amplitude * sin(period * t + shiftxby) + n)
    end
    return y = amplitude * sin(period * t + shiftxby) + n

end

function get_constant_value(n, discretize) 
    if discretize
        return floor(n)
    end
    return n end

get_value(m::SinusModifier, t, discretize=true) = get_sinus_value(t, m.amplitude, m.period, m.n, m.shiftxby, discretize);
get_value(m::ConstantModifier, t, discretize=true) = get_constant_value(m.n, discretize);







function trace_allele(
    nb_indiv_type_1::Int64,
    population_size_modifier::Modifier,
    fecundity_selection_modifier,#::Modifier,
    viability_selection_modifier::Modifier,
    sampler::Sampler,
)

    nb_generations = 1

    pop_size::Int64 = get_value(population_size_modifier, nb_generations)
    if typeof(fecundity_selection_modifier) == ConstantModifier || typeof(fecundity_selection_modifier) == SinusModifier
        selection_fecundity = get_value(fecundity_selection_modifier, nb_generations, false)
    else
        selection_fecundity = fecundity_selection_modifier
    end
    selection_viability = get_value(viability_selection_modifier, nb_generations, false)

    history = []
    append!(history, [nb_indiv_type_1])

    while !check_finished(nb_indiv_type_1, pop_size)
        
        #println(string(nb_indiv_type_1, " " ,pop_size))

        nb_indiv_type_1 = nb_next_generation(
            nb_indiv_type_1,
            pop_size, 
            selection_fecundity,
            selection_viability,
            sampler, 
        )

        pop_size = get_value(population_size_modifier, nb_generations)
        if typeof(fecundity_selection_modifier) == ConstantModifier || typeof(fecundity_selection_modifier) == SinusModifier
            selection_fecundity = get_value(fecundity_selection_modifier, nb_generations, false)
        else
            selection_fecundity = fecundity_selection_modifier
        end
        selection_viability = get_value(viability_selection_modifier, nb_generations, false)
        nb_generations += 1


        append!(history, [nb_indiv_type_1])
    end



    fixation = nb_indiv_type_1 >= pop_size
    return (fixation, nb_generations, history)
end;



function bootstrap_fixation_probability(
    nb_indiv_type_1::Int64,
    population_size_modifier::Modifier,
    fecundity_selection_modifier,#::Modifier,
    viability_selection_modifier::Modifier,
    sampler::Sampler,
    nb_simulations::Int64
)

    nb_fixations = 0
    for i = 1:nb_simulations
        fixation_status, num_generations, history = trace_allele(
            nb_indiv_type_1, population_size_modifier, fecundity_selection_modifier, viability_selection_modifier, sampler)
        if fixation_status
            nb_fixations += 1
        end
    end
    return nb_fixations/nb_simulations
end;

function bootstrap_fixation_time(
    nb_indiv_type_1::Int64,
    population_size_modifier::Modifier,
    fecundity_selection_modifier,#::Modifier,
    viability_selection_modifier::Modifier,
    sampler::Sampler,
    nb_fixation_events::Int64
)

    histories = []
    e = 1
    while e < nb_fixation_events

        
        fixation_status = false;
        history = []
        num_generations = -1;

        fixation_status, num_generations, history = trace_allele(nb_indiv_type_1, population_size_modifier, fecundity_selection_modifier, viability_selection_modifier, sampler);


        if fixation_status
            println(e, " ", nb_fixation_events)
            e += 1
            append!(histories, [history])
        end
    end
    return histories
end;



function average_fixation_time(histories)
    fixation_times = []
    for history ∈ histories
        append!(fixation_times, length(history))
    end
    return mean(fixation_times)
end;

function std_fixation_time(histories)
    fixation_times = []
    for history ∈ histories
        append!(fixation_times, length(history))
    end
    return std(fixation_times)
end;


function vector_dict_to_dataframe(vector_dict)
    frames = DataFrame.(vector_dict);
    frame = append!(frames[1], frames[2])
    for i = 3:length(frames)
        append!(frame, frames[i])
    end
    return frame
end;



end