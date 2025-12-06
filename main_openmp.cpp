#include <iostream>
#include <cstdlib>
#include <ctime>
#include <cstring>
#include <chrono>
#include <omp.h>

#define GRID_WIDTH 80
#define GRID_HEIGHT 200

class GameOfLife {
private:
    int width, height;
    int* currentGrid;
    int* nextGrid;
    int timeStep;
    
public:
    GameOfLife(int w, int h) : width(w), height(h), timeStep(0) {
        currentGrid = new int[width * height];
        nextGrid = new int[width * height];
        
        initializeRandom();
    }
    
    ~GameOfLife() {
        delete[] currentGrid;
        delete[] nextGrid;
    }
    
    void initializeRandom(float density = 0.35f) {
        srand(time(NULL));
        for (int i = 0; i < width * height; i++) {
            currentGrid[i] = (rand() / (float)RAND_MAX) < density ? 1 : 0;
        }
        timeStep = 0;
    }
    
    double step(int steps = 1) {
        auto start = std::chrono::high_resolution_clock::now();
        
        for (int s = 0; s < steps; s++) {
            // Parallelize the computation across cells
            #pragma omp parallel for collapse(2)
            for (int y = 0; y < height; y++) {
                for (int x = 0; x < width; x++) {
                    int idx = y * width + x;
                    int neighbors = 0;
                    
                    // Count neighbors
                    for (int dy = -1; dy <= 1; dy++) {
                        for (int dx = -1; dx <= 1; dx++) {
                            if (dx == 0 && dy == 0) continue; // Skip center cell
                            
                            int nx = x + dx;
                            int ny = y + dy;
                            
                            // Wrap around edges
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
                    // Cell is alive
                    if (neighbors >= 4) {
                        nextGrid[idx] = 1; // Stays alive
                    } else {
                        nextGrid[idx] = 0; // Dies
                    }
                }
            }
            
            // Swap grids
            int* temp = currentGrid;
            currentGrid = nextGrid;
            nextGrid = temp;
            
            timeStep++;
        }
        
        auto end = std::chrono::high_resolution_clock::now();
        std::chrono::duration<double, std::milli> elapsed = end - start;
        
        return elapsed.count();
    }
    
    void display() {
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
                std::cout << (currentGrid[idx] ? "X" : " ");
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
            aliveCount += currentGrid[i];
        }
        
        std::cout << "\nTime Step: " << timeStep << " | Alive Cells: " << aliveCount 
                  << " | Population: " << (100.0f * aliveCount / (width * height)) << "%\n";
    }
    
    int getTimeStep() const { return timeStep; }
};

void printHelp() {
    std::cout << "\n=== OpenMP Game of Life ===\n";
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
    // Display OpenMP information
    std::cout << "OpenMP Game of Life - Initializing...\n";
    std::cout << "Number of threads: " << omp_get_max_threads() << "\n";
    
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
            double elapsed = game.step(1);
            game.display();
            std::cout << "Execution time: " << elapsed << " ms\n";
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
                    double elapsed = game.step(steps);
                    game.display();
                    std::cout << "Execution time: " << elapsed << " ms";
                    std::cout << " (" << (elapsed / steps) << " ms/step)\n";
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
