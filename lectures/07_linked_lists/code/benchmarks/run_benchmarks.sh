#!/bin/bash
# Run comprehensive benchmarks for all list implementations

set -e

BENCHMARK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULTS_DIR="$BENCHMARK_DIR/results"
mkdir -p "$RESULTS_DIR"

DURATION=3.0
RUNS=3
IMPLEMENTATIONS="coarse fine optimistic lazy lockfree lazy_racefree optimistic_racefree"
THREAD_COUNTS="1 2 4 8 12 16 20 24 28"

echo "=== Starting Comprehensive List Benchmarks ==="
echo "Duration: ${DURATION}s per run"
echo "Runs: $RUNS"
echo "Implementations: $IMPLEMENTATIONS"
echo "Thread counts: $THREAD_COUNTS"
echo ""

cd "$BENCHMARK_DIR"

# Experiment 1: High contains ratio (90%)
echo "Experiment 1: High Contains Ratio (90% read, 5% add, 5% remove)"
CSV_FILE="$RESULTS_DIR/high_contains.csv"
rm -f "$CSV_FILE"
echo "impl,threads,contains_pct,median,avg" > "$CSV_FILE"

for impl in $IMPLEMENTATIONS; do
  for threads in $THREAD_COUNTS; do
    echo "  Running $impl with $threads threads..."
    dune exec benchmarks/benchmark_lists.exe -- \
      --impl "$impl" \
      --threads "$threads" \
      --contains 90 \
      --duration "$DURATION" \
      --runs "$RUNS" \
      --csv "$CSV_FILE" \
      2>&1 | tail -1
  done
done

echo ""
echo "Results saved to $CSV_FILE"
echo ""

# Experiment 2: Low contains ratio (50%)
echo "Experiment 2: Low Contains Ratio (50% read, 25% add, 25% remove)"
CSV_FILE="$RESULTS_DIR/low_contains.csv"
rm -f "$CSV_FILE"
echo "impl,threads,contains_pct,median,avg" > "$CSV_FILE"

for impl in $IMPLEMENTATIONS; do
  for threads in $THREAD_COUNTS; do
    echo "  Running $impl with $threads threads..."
    dune exec benchmarks/benchmark_lists.exe -- \
      --impl "$impl" \
      --threads "$threads" \
      --contains 50 \
      --duration "$DURATION" \
      --runs "$RUNS" \
      --csv "$CSV_FILE" \
      2>&1 | tail -1
  done
done

echo ""
echo "Results saved to $CSV_FILE"
echo ""

# Experiment 3: Varying contains ratio (28 threads)
echo "Experiment 3: Varying Contains Ratio (fixed 28 threads)"
CSV_FILE="$RESULTS_DIR/varying_contains.csv"
rm -f "$CSV_FILE"
echo "impl,threads,contains_pct,median,avg" > "$CSV_FILE"

for impl in $IMPLEMENTATIONS; do
  for contains in 0 10 20 30 40 50 60 70 80 90 100; do
    echo "  Running $impl with $contains% contains..."
    dune exec benchmarks/benchmark_lists.exe -- \
      --impl "$impl" \
      --threads 28 \
      --contains "$contains" \
      --duration "$DURATION" \
      --runs "$RUNS" \
      --csv "$CSV_FILE" \
      2>&1 | tail -1
  done
done

echo ""
echo "Results saved to $CSV_FILE"
echo ""

echo "=== All benchmarks complete! ==="
echo "Results are in: $RESULTS_DIR"
