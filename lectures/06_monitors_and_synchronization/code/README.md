# Monitors and Synchronization - Code Examples

This directory contains OCaml implementations demonstrating different synchronization approaches using monitors (mutexes and condition variables).

## Bounded Queue Implementations

Three implementations of a bounded queue showing the progression from simple to sophisticated synchronization:

### 1. **Non-Blocking Queue** (`lib/queue_non_blocking.ml`)
- Uses a mutex for mutual exclusion
- **Raises exceptions** (`Full`/`Empty`) when operations cannot proceed
- Simplest approach but requires caller to handle exceptions and retry
- Demonstrates: basic mutex protection with fail-fast behavior

### 2. **Spin-Wait Queue** (`lib/queue_spin_wait.ml`)
- Uses busy-waiting with `Domain.cpu_relax()`
- Repeatedly checks condition in a loop, releasing and reacquiring the lock
- No exceptions, but **wastes CPU cycles** while waiting
- Demonstrates: spin-lock pattern (inefficient but functional)

### 3. **Blocking Queue** (`lib/queue_blocking.ml`)
- Uses **condition variables** (`Condition.wait`/`signal`)
- Threads efficiently block and are woken when state changes
- **The correct approach** for producer-consumer scenarios
- Demonstrates: monitor pattern with condition variables

**Key Concept**: All three use unbounded monotonic counters (`head`, `tail`) to avoid the ambiguity problem in circular buffers where `head = tail` could mean either empty or full.

## Read-Write Lock Implementations

Two implementations showing different fairness policies:

### 4. **Simple Read-Write Lock** (`lib/simple_rw_lock.ml`)
- Multiple readers can hold the lock simultaneously
- Writers have exclusive access
- **Readers-preference**: can starve writers if readers keep arriving
- Demonstrates: basic reader-writer synchronization

### 5. **FIFO Read-Write Lock** (`lib/fifo_rw_lock.ml`)
- Multiple readers, exclusive writers (same semantics)
- Uses cumulative counters (`read_acquires`, `read_releases`) for FIFO ordering
- **Fair**: prevents writer starvation
- Demonstrates: FIFO fairness using acquisition counters

## Running the Tests

Build all tests:
```bash
dune build
```

Run individual tests:
```bash
# Test non-blocking queue (shows exceptions and retries)
dune exec test/test_non_blocking.exe

# Test spin-wait queue (smooth operation, busy-waiting)
dune exec test/test_spin_wait.exe

# Test blocking queue (efficient blocking with condition variables)
dune exec test/test_blocking.exe

# Test both read-write lock implementations
dune exec test/test_rw_locks.exe
```

Run all tests:
```bash
dune exec test/test_non_blocking.exe && \
dune exec test/test_spin_wait.exe && \
dune exec test/test_blocking.exe && \
dune exec test/test_rw_locks.exe
```

## Project Structure

```
code/
├── lib/                          # Implementation files
│   ├── queue_non_blocking.ml/mli    # Exception-based queue
│   ├── queue_spin_wait.ml/mli       # Busy-waiting queue
│   ├── queue_blocking.ml/mli        # Condition variable queue
│   ├── simple_rw_lock.ml/mli        # Simple reader-writer lock
│   ├── fifo_rw_lock.ml/mli          # Fair FIFO RW lock
│   └── dune                         # Library build config
├── test/                         # Test files
│   ├── test_non_blocking.ml         # Concurrent test with exceptions
│   ├── test_spin_wait.ml            # Concurrent test with spin-waiting
│   ├── test_blocking.ml             # Concurrent test with blocking
│   ├── test_rw_locks.ml             # Test both RW lock implementations
│   └── dune                         # Test executables config
└── README.md                     # This file
```

## Key Patterns

### Monitor Pattern
All implementations follow the monitor pattern:
```ocaml
Mutex.lock lock;
Fun.protect ~finally:(fun () -> Mutex.unlock lock) @@ fun () ->
  (* Critical section with automatic unlock on exception *)
  while condition_not_met do
    Condition.wait condition lock  (* Atomically unlocks and waits *)
  done;
  (* Perform operation *)
  Condition.signal other_condition  (* Wake waiting threads *)
```

### Using `Fun.protect` for Exception Safety
```ocaml
Fun.protect ~finally:(fun () -> Mutex.unlock lock) @@ fun () ->
  (* Code that may raise exceptions *)
```
Ensures the mutex is always unlocked, even if an exception is raised.

## Learning Progression

Students should study the implementations in this order:
1. **Non-blocking queue** - Understand basic mutex protection and exception handling
2. **Spin-wait queue** - See the inefficiency of busy-waiting
3. **Blocking queue** - Learn the proper condition variable pattern
4. **Simple RW lock** - Understand reader-writer synchronization
5. **FIFO RW lock** - See how to achieve fairness with cumulative counters
