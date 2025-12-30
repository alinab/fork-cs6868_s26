# Project Structure

```
code/
├── Lock.ml              # Common lock interface (LOCK signature)
├── Benchmark.ml         # Shared benchmarking utilities
├── TASLock.ml          # Test-And-Set lock implementation
├── test_tas.ml         # Correctness test for TAS lock
├── benchmark_tas.ml    # Performance benchmark for TAS lock
├── compare_locks.ml    # Compare all lock implementations
├── run_benchmarks.sh   # Hyperfine benchmark script
├── dune                # Build configuration
├── dune-project        # Dune project file
├── Makefile            # Convenience targets
└── README.md           # Documentation
```

## Key Design Principles

### 1. Shared Interface (Lock.ml)
All lock implementations must implement the `LOCK` signature:
```ocaml
module type LOCK = sig
  type t
  val create : unit -> t
  val lock : t -> unit
  val unlock : t -> unit
  val name : string
end
```

### 2. Shared Benchmarking (Benchmark.ml)
Common utilities used by all locks:
- `benchmark_lock` - Run a benchmark on any lock
- `run_single` - Run and display single lock benchmark
- `compare_locks` - Compare multiple locks
- `parse_args` - Parse command-line arguments

### 3. Lock Implementations
Each lock is a separate module implementing `Lock.LOCK`:
- `TASLock.ml` - Contains the TASLock module
- Future: `TTASLock.ml`, `BackoffLock.ml`, etc.

### 4. Executables
- `test_*.exe` - Correctness tests
- `benchmark_*.exe` - Individual benchmarks
- `compare_locks.exe` - Compare all implementations

## Adding a New Lock

1. Create `NewLock.ml`:
```ocaml
module NewLock : Lock.LOCK = struct
  type t = { (* state *) }
  let name = "New Lock"
  let create () = (* ... *)
  let lock t = (* ... *)
  let unlock t = (* ... *)
end
```

2. Update `dune`:
```dune
(library
 (name spinlocks)
 (modules Lock Benchmark TASLock NewLock))  ; Add NewLock
```

3. Create `benchmark_new.ml`:
```ocaml
let () =
  let threads, iterations = Spinlocks.Benchmark.parse_args () in
  Spinlocks.Benchmark.run_single
    (module Spinlocks.NewLock.NewLock)
    threads iterations
```

4. Add to `dune`:
```dune
(executable
 (name benchmark_new)
 (libraries unix spinlocks)
 (modules benchmark_new)
 (modes exe))
```

5. Update `compare_locks.ml`:
```ocaml
let locks = [
  (module Spinlocks.TASLock.TASLock : Spinlocks.Lock.LOCK);
  (module Spinlocks.NewLock.NewLock : Spinlocks.Lock.LOCK);
]
```

That's it! The new lock will automatically work with all benchmarking infrastructure.
