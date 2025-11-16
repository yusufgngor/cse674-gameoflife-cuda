# CUDA Game of Life

A GPU-accelerated Conway's Game of Life implementation with custom rules.

## Custom Rules

- **Survival Rule**: A living cell survives if it has at least 4 neighbors
- **Death Rule**: A living cell dies if it has fewer than 4 neighbors
- **No Rebirth**: Dead cells stay dead (no resurrection)

## Requirements

- NVIDIA GPU with CUDA support
- CUDA Toolkit installed
- C++ compiler

## Compilation

```bash
make
```

Or compile manually:
```bash
nvcc -O2 -arch=sm_50 main.cpp -o game_of_life
```

## Running

```bash
make run
```

Or run directly:
```bash
./game_of_life
```

## Controls

- **\<Enter\>**: Advance by 1 time step
- **\<number\>**: Advance by N time steps (e.g., type `10` and press Enter for 10 steps)
- **r**: Reset with a new random pattern
- **h**: Show help
- **q**: Quit the program

## Grid Settings

- Grid size: 80x40 cells
- Initial population density: ~30% (randomly generated)
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