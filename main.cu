#include <iostream>
#include <cuda_runtime.h>
#include <cstdlib>
#include <ctime>
#include <cstring>

#define GRID_WIDTH 80
#define GRID_HEIGHT 40
#define BLOCK_SIZE 16

// CUDA kernel for Game of Life with custom rules
// Rule: Cell lives if it has at least 4 neighbors (no rebirth)
__global__ void gameOfLifeKernel(int* currentGrid, int* nextGrid, int width, int height) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    
    if (x >= width || y >= height) return;
    
    int idx = y * width + x;
    int neighbors = 0;
    
    // Count alive neighbors (8-connectivity)
    for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
            if (dx == 0 && dy == 0) continue; // Skip center cell
            
            int nx = x + dx;
            int ny = y + dy;
            
            // Wrap around edges (toroidal topology)
            if (nx < 0) nx = width - 1;
            if (nx >= width) nx = 0;
            if (ny < 0) ny = height - 1;
            if (ny >= height) ny = 0;
            
            int nidx = ny * width + nx;
            neighbors += currentGrid[nidx];
        }
    }
    
    // Custom rules:
    // - No rebirth (dead cells stay dead)
    // - Cell lives if it has at least 4 neighbors
    if (currentGrid[idx] == 1) {
        // Cell is alive
        if (neighbors >= 4) {
            nextGrid[idx] = 1; // Stays alive
        } else {
            nextGrid[idx] = 0; // Dies
        }
    } else {
        // Cell is dead - no rebirth
        nextGrid[idx] = 0;
    }
}


class GameOfLife {
private:
    int width, height;
    int* h_grid;       
    int* d_currentGrid;
    int* d_nextGrid;
    int timeStep;
    
public:
    GameOfLife(int w, int h) : width(w), height(h), timeStep(0) {
        h_grid = new int[width * height];
        
        cudaMalloc(&d_currentGrid, width * height * sizeof(int));
        cudaMalloc(&d_nextGrid, width * height * sizeof(int));
        
        initializeRandom();
    }
    
    ~GameOfLife() {
        delete[] h_grid;
        cudaFree(d_currentGrid);
        cudaFree(d_nextGrid);
    }
    
    void initializeRandom(float density = 0.6f) {
        srand(time(NULL));
        for (int i = 0; i < width * height; i++) {
            h_grid[i] = (rand() / (float)RAND_MAX) < density ? 1 : 0;
        }
        // Copy to device
        cudaMemcpy(d_currentGrid, h_grid, width * height * sizeof(int), 
                                   cudaMemcpyHostToDevice);
        timeStep = 0;
    }
    
    void step(int steps = 1) {
        dim3 blockDim(BLOCK_SIZE, BLOCK_SIZE);
        dim3 gridDim((width + BLOCK_SIZE - 1) / BLOCK_SIZE, 
                     (height + BLOCK_SIZE - 1) / BLOCK_SIZE);
        
        for (int i = 0; i < steps; i++) {
            // Launch kernel
            gameOfLifeKernel<<<gridDim, blockDim>>>(d_currentGrid, d_nextGrid, width, height);
            cudaDeviceSynchronize();
            
            // Swap grids
            int* temp = d_currentGrid;
            d_currentGrid = d_nextGrid;
            d_nextGrid = temp;
            
            timeStep++;
        }
    }
    
    void display() {
        // Copy current grid from device to host
        cudaMemcpy(h_grid, d_currentGrid, width * height * sizeof(int), 
                                   cudaMemcpyDeviceToHost);
        
        // Clear screen (ANSI escape code)
        std::cout << "\033[2J\033[H";
        
        // Display header
        std::cout << "╔";
        for (int x = 0; x < width; x++) std::cout << "═";
        std::cout << "╗\n";
        
        // Display grid
        for (int y = 0; y < height; y++) {
            std::cout << "║";
            for (int x = 0; x < width; x++) {
                int idx = y * width + x;
                std::cout << (h_grid[idx] ? "X" : " ");
            }
            std::cout << "║\n";
        }
        
        // Display footer
        std::cout << "╚";
        for (int x = 0; x < width; x++) std::cout << "═";
        std::cout << "╝\n";
        
        // Display statistics
        int aliveCount = 0;
        for (int i = 0; i < width * height; i++) {
            aliveCount += h_grid[i];
        }
        
        std::cout << "\nTime Step: " << timeStep << " | Alive Cells: " << aliveCount 
                  << " | Population: " << (100.0f * aliveCount / (width * height)) << "%\n";
    }
    
};

void printHelp() {
    std::cout << "\n=== CUDA Game of Life ===\n";
    std::cout << "Custom Rules:\n";
    std::cout << "  - Cells live if they have at least 4 neighbors\n";
    std::cout << "  - Dead cells stay dead (no rebirth)\n\n";
    std::cout << "Commands:\n";
    std::cout << "  <number> - Advance by N time steps (e.g., '10' for 10 steps)\n";
    std::cout << "  <Enter>  - Advance by 1 time step\n";
    std::cout << "  r        - Reset with new random pattern\n";
    std::cout << "  h        - Show this help\n";
    std::cout << "  q        - Quit\n";
    std::cout << "\nPress Enter to continue...";
    std::cin.ignore();
}

int main() {
    // Check for CUDA device
    int deviceCount = 0;
    cudaGetDeviceCount(&deviceCount);
    if (deviceCount == 0) {
        std::cerr << "No CUDA-capable device found!\n";
        return 1;
    }
    
    std::cout << "CUDA Game of Life - Initializing...\n";
    
    GameOfLife game(GRID_WIDTH, GRID_HEIGHT);
    
    printHelp();
    
    // Initial display
    game.display();
    
    std::string input;
    while (true) {
        std::cout << "\nCommand: ";
        std::getline(std::cin, input);
        
        if (input.empty()) {
            // Advance 1 step
            game.step(1);
            game.display();
        }
        else if (input == "q" || input == "quit") {
            std::cout << "Exiting...\n";
            break;
        }
        else if (input == "r" || input == "reset") {
            game.initializeRandom();
            game.display();
            std::cout << "Grid reset with new random pattern.\n";
        }
        else if (input == "h" || input == "help") {
            printHelp();
            game.display();
        }
        else {
            // Try to parse as number
            try {
                int steps = std::stoi(input);
                if (steps > 0 && steps <= 10000) {
                    std::cout << "Advancing " << steps << " steps...\n";
                    game.step(steps);
                    game.display();
                } else {
                    std::cout << "Please enter a number between 1 and 10000.\n";
                }
            } catch (...) {
                std::cout << "Invalid command. Type 'h' for help.\n";
            }
        }
    }
    
    return 0;
}
