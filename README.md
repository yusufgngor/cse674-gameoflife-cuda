# Game of Life - CUDA and OpenMP Implementations

Parallel implementations of Conway's Game of Life with custom rules using CUDA (GPU) and OpenMP (CPU multi-threading).

## Custom Rules

- **Survival Rule**: A living cell survives if it has at least 4 neighbors
- **Death Rule**: A living cell dies if it has fewer than 4 neighbors
- **No Rebirth**: Dead cells stay dead (no resurrection)

## Requirements

### CUDA Version
- NVIDIA GPU with CUDA support
- CUDA Toolkit installed

### OpenMP Version
- C++ compiler with OpenMP support (g++, clang++)
- Multi-core CPU

## Compilation

### Build both versions:
```bash
make
```

### Build only CUDA version:
```bash
make cuda
```

### Build only OpenMP version:
```bash
make openmp
```

### Or compile manually:

**CUDA version:**
```bash
nvcc -O2 -arch=sm_50 main.cu -o game_of_life
```

**OpenMP version:**
```bash
g++ -O2 -fopenmp -std=c++11 main_openmp.cpp -o game_of_life_openmp
```

## Running

### Run CUDA version:
```bash
make run
```
or
```bash
./game_of_life
```

### Run OpenMP version:
```bash
make run-openmp
```
or
```bash
./game_of_life_openmp
```

You can set the number of OpenMP threads with:
```bash
OMP_NUM_THREADS=8 ./game_of_life_openmp
```

## Controls

- **\<Enter\>**: Advance by 1 time step
- **\<number\>**: Advance by N time steps (e.g., type `10` and press Enter for 10 steps)
- **r**: Reset with a new random pattern
- **h**: Show help
- **q**: Quit the program

## Grid Settings

- Grid size: 80x200 cells
- Initial population density: ~60% (randomly generated)

## Performance Comparison

Both implementations use the same custom rules and grid size. The CUDA version parallelizes computation on the GPU, while the OpenMP version uses CPU multi-threading. You can compare their performance by running the same number of steps on each version.
- Toroidal topology (edges wrap around)

## Examples

```
Command: <Enter>     # Advance 1 step
Command: 5           # Advance 5 steps
Command: 100         # Advance 100 steps
Command: r           # Reset with new random pattern
Command: q           # Quit
```

## How It Works

The program uses CUDA to parallelize the Game of Life computation across GPU threads. Each cell's next state is computed in parallel based on its neighbors' current states.

The display shows:
- Live cells as █ (filled blocks)
- Dead cells as spaces
- Current time step
- Number of alive cells
- Population percentage

Enjoy watching the patterns evolve!

to watch gpu usage "sudo nvidia-smi dmon"