#!/bin/bash
# run_benchmarks.sh
# 
# Uses hyperfine to benchmark TAS lock with different thread counts
# Each benchmark is run separately with proper warmup and statistics

set -e

echo "=== TAS Lock Hyperfine Benchmarks ==="
echo ""

# Check if hyperfine is installed
if ! command -v hyperfine &> /dev/null; then
    echo "Error: hyperfine is not installed."
    echo "Install it with: brew install hyperfine"
    exit 1
fi

# Build the project first
echo "Building project..."
dune build
echo ""

ITERATIONS=10000
THREAD_COUNTS=(1 2 4 8 16)

echo "Running benchmarks with $ITERATIONS iterations per thread"
echo "Thread counts: ${THREAD_COUNTS[@]}"
echo ""
echo "----------------------------------------"
echo ""

for THREADS in "${THREAD_COUNTS[@]}"; do
    echo "Benchmarking with $THREADS thread(s)..."
    hyperfine \
        --warmup 3 \
        --runs 10 \
        --export-json "results_tas_${THREADS}t.json" \
        "dune exec ./benchmark_tas.exe -- --threads $THREADS --iterations $ITERATIONS"
    echo ""
done

echo "----------------------------------------"
echo ""
echo "Benchmark results saved as results_tas_*t.json"
echo ""
echo "To compare all results, you can use:"
echo "hyperfine --warmup 3 \\"
for THREADS in "${THREAD_COUNTS[@]}"; do
    echo "  'dune exec ./benchmark_tas.exe -- --threads $THREADS --iterations $ITERATIONS' \\"
done | sed '$ s/ \\$//'
