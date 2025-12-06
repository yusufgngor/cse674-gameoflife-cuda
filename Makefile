# Makefile for CUDA and OpenMP Game of Life

# CUDA compiler
NVCC = nvcc

# C++ compiler
CXX = g++

# Compiler flags
NVCC_FLAGS = -O2 -arch=sm_50
CXX_FLAGS = -O2 -fopenmp -std=c++11

# Target executables
TARGET_CUDA = game_of_life
TARGET_OPENMP = game_of_life_openmp

# Source files
SOURCES_CUDA = main.cu
SOURCES_OPENMP = main_openmp.cpp

# Build all
all: $(TARGET_CUDA) $(TARGET_OPENMP)

# Build CUDA version
$(TARGET_CUDA): $(SOURCES_CUDA)
	$(NVCC) $(NVCC_FLAGS) $(SOURCES_CUDA) -o $(TARGET_CUDA)

# Build OpenMP version
$(TARGET_OPENMP): $(SOURCES_OPENMP)
	$(CXX) $(CXX_FLAGS) $(SOURCES_OPENMP) -o $(TARGET_OPENMP)

# Build only CUDA version
cuda: $(TARGET_CUDA)

# Build only OpenMP version
openmp: $(TARGET_OPENMP)

# Run CUDA version
run: $(TARGET_CUDA)
	./$(TARGET_CUDA)

# Run OpenMP version
run-openmp: $(TARGET_OPENMP)
	./$(TARGET_OPENMP)

# Clean build artifacts
clean:
	rm -f $(TARGET_CUDA) $(TARGET_OPENMP)

.PHONY: all cuda openmp run run-openmp clean
