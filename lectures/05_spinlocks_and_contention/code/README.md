# Spinlocks and Contention

This directory contains OCaml implementations of various spinlock algorithms from the "Art of Multiprocessor Programming" book.

## Code Structure

The code is organized using a shared infrastructure:

- **Lock.ml** - Common lock interface that all implementations must follow
- **Benchmark.ml** - Shared benchmarking utilities for testing locks
- **TASLock.ml** - Test-And-Set lock implementation
- **test_tas.ml** - Simple correctness test for TAS lock
- **benchmark_tas.ml** - Performance benchmark for TAS lock
- **compare_locks.ml** - Compare performance of all lock implementations

## Spinlock Implementations

### 1. TAS Lock (Test-And-Set)
The simplest spinlock using atomic test-and-set operations.

**Files:**
- `TASLock.ml` - Basic implementation with simple test
- `benchmark_tas.ml` - Performance benchmarks with varying thread counts

**How it works:**
- Uses a single atomic boolean to represent lock state
- `lock()`: Continuously tries to atomically set state to true until successful
- `unlock()`: Sets state back to false

**Performance characteristics:**
- Simple but generates high cache coherence traffic
- Every spinning thread performs atomic operations continuously
- Each failed test-and-set invalidates other threads' caches

**Build and run:**
```bash
dune build

# Run correctness test
dune exec ./test_tas.exe

# Run benchmark with custom parameters
dune exec ./benchmark_tas.exe -- --threads 4 --iterations 10000
dune exec ./benchmark_tas.exe -- --threads 8 --iterations 5000

# Run comprehensive benchmarks with hyperfine
./run_benchmarks.sh
```

### 2. TTAS Lock (Test-Test-And-Set)
Improved spinlock that reads before writing to reduce cache coherence traffic.

**Files:**
- `TTASLock.ml` - Implementation with detailed comments
- `test_ttas.ml` - Correctness test
- `benchmark_ttas.ml` - Performance benchmark

**How it works:**
- First spin-reads the lock state (cheap, no cache invalidation)
- Only attempts atomic test-and-set when lock appears free
- If test-and-set fails, go back to reading

**Performance characteristics:**
- Much better than TAS under contention
- Read operations don't invalidate other caches
- Only generates coherence traffic when competing for free lock
- Cache line can be shared (S state) while threads spin-read

**Build and run:**
```bash
# Run correctness test
dune exec ./test_ttas.exe

# Run benchmark
dune exec ./benchmark_ttas.exe -- --threads 8 --iterations 10000
```

### 3. Backoff Lock
Improved spinlock with exponential backoff to reduce contention.

**Files:**
- `BackoffLock.ml` - Implementation with exponential backoff using Domain.cpu_relax
- `test_backoff.ml` - Correctness test
- `benchmark_backoff.ml` - Performance benchmark
- `tune_backoff.ml` - Parameter tuning tool to find optimal MIN/MAX delays

**How it works:**
- Like TTAS: spin-read until lock appears free
- Try atomic test-and-set
- **New:** If acquisition fails, back off exponentially
- Uses `Domain.cpu_relax()` for efficient waiting
- Backoff delay doubles each time (up to MAX_DELAY)

**Performance characteristics:**
- Best under high contention
- Reduces cache coherence traffic by spreading out retries
- MIN_DELAY and MAX_DELAY need tuning for specific workloads
- Generally: (1, 256) is a good default for most cases

**Build and run:**
```bash
# Run correctness test
dune exec ./test_backoff.exe

# Run benchmark
dune exec ./benchmark_backoff.exe -- --threads 8 --iterations 10000

# Tune parameters for your workload
dune exec ./tune_backoff.exe -- --threads 8 --iterations 10000
```

### 4. Array Lock (ALock)
Queue-based lock where each thread spins on a different array element.

**Files:**
- `ALock.ml` - Implementation using array of atomic booleans with make_contended
- `test_alock.ml` - Correctness test
- `benchmark_alock.ml` - Performance benchmark

**How it works:**
- Array of flags (atomic booleans), one per potential thread
- Uses `Atomic.make_contended()` to prevent false sharing
- Threads take tickets using atomic fetch-and-add
- Each thread spins on its own flag (different cache line)
- Lock holder signals next thread when releasing

**Design notes:**
- Array capacity should match expected thread count
- Uses Domain.DLS to store each domain's slot
- `make_contended` adds padding between array elements

**Performance characteristics:**
- Eliminates spinning cache coherence traffic
- Each thread waits on different memory location
- Traffic only when passing lock between threads
- Current implementation shows moderate performance; may benefit from further optimization

**Build and run:**
```bash
# Run correctness test
dune exec ./test_alock.exe

# Run benchmark with default capacity
dune exec ./benchmark_alock.exe -- --threads 8 --iterations 10000

# Run with custom capacity matching thread count
dune exec ./benchmark_alock_custom.exe -- --threads 8 --iterations 10000
```

## Building All Examples

```bash
dune build
```

## Running Examples

```bash
# Test individual locks
dune exec ./test_tas.exe

# Benchmark specific lock with custom parameters
dune exec ./benchmark_tas.exe -- --threads 4 --iterations 10000

# Compare all lock implementations
dune exec ./compare_locks.exe -- --threads 8 --iterations 10000

# Run all benchmarks with hyperfine (requires hyperfine to be installed)
./run_benchmarks.sh
```

## Using Hyperfine for Benchmarking

The `run_benchmarks.sh` script uses [hyperfine](https://github.com/sharkdp/hyperfine) for reliable benchmarking:

```bash
# Install hyperfine (macOS)
brew install hyperfine

# Run benchmarks
./run_benchmarks.sh
```

This will:
- Warm up each benchmark with 3 runs
- Execute 10 runs per configuration
- Save results as JSON files for further analysis
- Test with 1, 2, 4, 8, and 16 threads

## Adding New Lock Implementations

To add a new lock implementation:

1. Create a new file (e.g., `TTASLock.ml`) implementing the `Lock.LOCK` signature
2. Add the module to the library in `dune`
3. Add a benchmark executable in `dune`
4. Uncomment the corresponding line in `compare_locks.ml`

Example lock implementation:
```ocaml
module MyLock : Lock.LOCK = struct
  type t = { (* your state *) }
  let name = "My Lock"
  let create () = (* initialize *)
  let lock t = (* acquire lock *)
  let unlock t = (* release lock *)
end
```

## Performance Notes

When running benchmarks, you'll observe:
- Performance typically degrades with more threads due to contention
- TAS lock generates significant cache coherence traffic
- TTAS lock (when implemented) should show better performance
- Backoff lock (when implemented) should further improve under high contention

## References

- "The Art of Multiprocessor Programming" by Maurice Herlihy and Nir Shavit
- Chapter 7: Spin Locks and Contention
