# CanningsSimulator

Monte Carlo simulator for studying fixation probabilities and fixation times in Cannings models with multiple-merger coalescents. The simulator implements the Schweinsberg offspring distribution and supports both **fecundity** and **viability** selection under constant or sinusoidally varying coefficients.

## Background

Classical population genetics often assumes the Wright-Fisher model (each individual contributes exactly Poisson-many offspring). Cannings models generalise this by allowing high-variance offspring distributions, which give rise to multiple-merger (Lambda- or Xi-) coalescents. This simulator focuses on the **Schweinsberg** offspring mechanism, parameterised by an exponent `alpha` in `(1, 2]`, where smaller alpha produces heavier tails and more frequent large family sizes.

The simulator estimates two key quantities by repeated Monte Carlo trials:

- **Fixation probability** — the fraction of runs in which a single mutant allele (starting from 1 copy) reaches fixation.
- **Fixation time** — the mean number of generations to fixation, conditional on fixation occurring.

## Project structure

```
├── src/
│   ├── CanningsSimulator.jl   # Core module: offspring distributions, selection, allele tracing
│   ├── simulator.jl           # CLI entry point (Julia + ArgParse)
│   └── test.jl                # Quick sanity check for offspring draws
│
├── scripts/
│   ├── fixation_probability/  # Bash scripts for fixation probability sweeps
│   ├── fixation_time/         # Bash scripts for fixation time sweeps
│   └── both/                  # Combined fecundity + viability selection sweeps
│
├── plotting/
│   ├── AD_figures*.ipynb      # Main paper and addendum figures (Jupyter/Python)
│   └── notebooks/             # Additional exploratory plotting notebooks
│
├── original_data/
│   └── data.zip               # Original simulation results (pre-addendum)
│
├── pyproject.toml             # Python dependencies (plotting, Jupyter)
└── README.md
```

Simulation results for the addendum are stored as compressed archives:

- `src/simulations_addendum_v1.zip`
- `src/simulations_addendum_v2.zip`

## Requirements

### Julia (simulation)

- **Julia >= 1.8**
- Julia packages: `Distributions`, `DataFrames`, `ArgParse`, `CSV`, `PyCall`
- Python packages accessible via PyCall: `scipy`, `numpy`

Install Julia packages from the Julia REPL:

```julia
using Pkg
Pkg.add(["Distributions", "DataFrames", "ArgParse", "CSV", "PyCall"])
```

### Python (plotting)

- **Python >= 3.12** (managed via [uv](https://docs.astral.sh/uv/))
- Key packages: `matplotlib`, `seaborn`, `jupyter`, `ipykernel`

```bash
uv sync
```

## Usage

### Running a single simulation

All simulations are launched through `src/simulator.jl`. From the project root:

```bash
julia src/simulator.jl \
  --type probability \
  -N 1000 \
  -t viability_constant \
  -s 0.01 \
  -m Schweinsberg \
  -p 1.5 \
  -c constant \
  -o fixation_probability \
  --nb_simulations 500000
```

#### CLI arguments

| Flag | Description | Example values |
|---|---|---|
| `--type` | Simulation type | `probability`, `time` |
| `-N` | Population size | `500`, `1000`, `5000` |
| `-t` | Selection type | `fecundity_constant`, `viability_constant`, `fecundity_sinus`, `viability_sinus`, `both` |
| `-s` | Selection coefficient | `0.0`, `0.01`, `0.1` |
| `--selection_coefficient2` | Second coefficient (only for `both`) | `0.01` |
| `--selection_period` | Period for sinusoidal selection | `0.06283` (default, ~100 generations) |
| `-m` | Offspring model | `Schweinsberg`, `fecundity_adapted_Schweinsberg`, `Poisson` |
| `-p` | Model parameter (alpha for Schweinsberg, lambda for Poisson) | `1.1` – `2.0` |
| `-c` | Population size model | `constant`, `sinus` |
| `--shiftsinusby` | Phase shift for sinusoidal modifiers | `0.0`, `3.141592653` |
| `-o` | Output filename prefix | `fixation_probability` |
| `--nb_simulations` | Number of simulation replicates | `500000` (probability), `5000` (time) |

Results are written as CSV files to `./simulations/`.

### Running batch simulations

The `scripts/` directory contains ready-made bash scripts that sweep over parameter combinations:

```bash
# Fixation probabilities across alpha values and selection types
bash scripts/fixation_probability/fixation_probability_schweinsberg.sh

# Fixation times
bash scripts/fixation_time/fixation_time_schweinsberg.sh

# Combined fecundity + viability selection
bash scripts/both/fixation_time_probability_both_selection_types.sh
```

These scripts launch many simulations in parallel. Adjust `wait` calls or remove the trailing `&` if you want to limit concurrency.

### Plotting

Figures are generated from Jupyter notebooks in `plotting/`. After running simulations (or unzipping the provided result archives), start Jupyter:

```bash
uv run jupyter notebook
```

The main addendum figures are in:

- `plotting/AD_figures_probabilities.ipynb` — fixation probability figures
- `plotting/AD_figures_times.ipynb` — fixation time figures
- `plotting/AD2_figures_probabilities.ipynb` — addendum v2 probability figures

## Key implementation details

**Schweinsberg offspring distribution** — Each of `N` individuals independently draws `U ~ Uniform(0,1)` and contributes `floor((1-p0)/U)^{1/alpha}` offspring. The total family size is the sum of these floored terms.

**Selection mechanisms:**

- *Fecundity selection* — the mutant type's total offspring count is multiplied by `(1 + s)`.
- *Adapted fecundity selection* — the alpha parameter of the Schweinsberg distribution is rescaled to incorporate selection, preserving the coalescent structure.
- *Viability selection* — after pooling all offspring, survivors are drawn via a non-central Wallenius hypergeometric distribution (from `scipy.stats`), biasing survival toward the mutant type.

**Population regulation** — If total offspring exceed the carrying capacity `N`, a hypergeometric (or non-central hypergeometric) draw selects exactly `N` survivors. If offspring fall short, the deficit is filled via a binomial draw proportional to current type frequencies.

## License

See repository for license information.
