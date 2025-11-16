# Makefile for CUDA Game of Life

# CUDA compiler
NVCC = nvcc

# Compiler flags
NVCC_FLAGS = -O2 -arch=sm_50

# Target executable
TARGET = game_of_life

# Source files
SOURCES = main.cu

# Build rule
all: $(TARGET)

$(TARGET): $(SOURCES)
	$(NVCC) $(NVCC_FLAGS) $(SOURCES) -o $(TARGET)

# Run the program
run: $(TARGET)
	./$(TARGET)

# Clean build artifacts
clean:
	rm -f $(TARGET)

.PHONY: all run clean
