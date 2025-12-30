.PHONY: all build clean test benchmark compare tas ttas backoff

all: build

build:
	dune build

clean:
	dune clean

# Run basic tests
test: build
	@echo "Running TAS Lock test..."
	dune exec ./test_tas.exe
	@echo ""
	@echo "Running TTAS Lock test..."
	dune exec ./test_ttas.exe
	@echo ""
	@echo "Running Backoff Lock test..."
	dune exec ./test_backoff.exe
	@echo ""
	@echo "Running Array Lock test..."
	dune exec ./test_alock.exe

# Run benchmarks
benchmark: build
	@echo "Running TAS Lock benchmark with default parameters..."
	dune exec ./benchmark_tas.exe

benchmark-hyperfine: build
	@echo "Running comprehensive benchmarks with hyperfine..."
	./run_benchmarks.sh

# Compare all lock implementations
compare: build
	@echo "Comparing all lock implementations..."
	dune exec ./compare_locks.exe

# Individual targets
tas: build
	@echo "Usage: dune exec ./benchmark_tas.exe -- --threads N --iterations N"
	dune exec ./benchmark_tas.exe

tas-test: build
	dune exec ./test_tas.exe

# TTAS Lock targets
ttas: build
	@echo "Usage: dune exec ./benchmark_ttas.exe -- --threads N --iterations N"
	dune exec ./benchmark_ttas.exe

ttas-test: build
	dune exec ./test_ttas.exe

# Backoff Lock targets
backoff: build
	@echo "Usage: dune exec ./benchmark_backoff.exe -- --threads N --iterations N"
	dune exec ./benchmark_backoff.exe

backoff-test: build
	dune exec ./test_backoff.exe

tune-backoff: build
	@echo "Tuning backoff parameters..."
	dune exec ./tune_backoff.exe

# Array Lock targets
alock: build
	@echo "Usage: dune exec ./benchmark_alock.exe -- --threads N --iterations N"
	dune exec ./benchmark_alock.exe

alock-test: build
	dune exec ./test_alock.exe
