# Linked List Benchmarks

Comprehensive benchmarking suite for concurrent linked list implementations.

## Implementations

The benchmark suite tests 7 different implementations:

1. **coarse** - Coarse-grained locking (single global lock)
2. **fine** - Fine-grained locking (hand-over-hand locking)
3. **optimistic** - Optimistic synchronization (traverse without locks, validate)
4. **optimistic_racefree** - Race-free optimistic using `Atomic.Loc`
5. **lazy** - Lazy synchronization (logical deletion with marked field)
6. **lazy_racefree** - Race-free lazy using `Atomic.Loc`
7. **lockfree** - Lock-free using atomic operations and CAS

## Usage

### Run a single benchmark

```bash
dune exec benchmarks/benchmark_lists.exe -- \
  --impl lazy \
  --threads 24 \
  --contains 90 \
  --duration 3.0 \
  --runs 3
```

### Run comprehensive benchmark suite

```bash
cd benchmarks
chmod +x run_benchmarks.sh
./run_benchmarks.sh
```

This will:
- Test all 7 implementations
- Use thread counts: 1, 2, 4, 8, 12, 16, 20, 24, 28
- Run 3 experiments:
  1. High contains ratio (90% read, 5% add, 5% remove)
  2. Low contains ratio (50% read, 25% add, 25% remove)
  3. Varying contains ratio (0-100% in 10% increments at 28 threads)
- Save results to `../results/` directory

### Generate plots

```bash
python3 plot_results.py
```

This generates three plots:
- `plot_high_contains.png` - Thread scaling with 90% contains
- `plot_low_contains.png` - Thread scaling with 50% contains
- `plot_varying_contains.png` - Performance vs contains ratio (28 threads)

## Parameters

- `--impl` - Implementation to test
- `--threads` - Number of concurrent threads
- `--contains` - Percentage of contains operations (0-100)
- `--duration` - Duration of each run in seconds
- `--initial-size` - Initial number of elements in list
- `--value-range` - Range of values [0, N)
- `--runs` - Number of runs per configuration (for statistical stability)
- `--csv` - Output CSV file path (optional)

## Results

Results are saved as CSV files with columns:
- `impl` - Implementation name
- `threads` - Number of threads
- `contains_pct` - Percentage of contains operations
- `median` - Median throughput (ops/sec)
- `avg` - Average throughput (ops/sec)

## Comparing Race-Free vs Original

The race-free versions (`lazy_racefree`, `optimistic_racefree`) use OCaml 5.4's
`Atomic.Loc` feature for atomic record fields, eliminating data races while
maintaining the same algorithms. Use TSAN to verify:

```bash
opam switch 5.4.0+tsan
eval $(opam env)
dune clean
TSAN_OPTIONS="halt_on_error=1" dune exec benchmarks/benchmark_lists.exe -- \
  --impl lazy_racefree --threads 8 --duration 2
```

Original implementations (`lazy`, `optimistic`) have benign data races that
TSAN will detect.
