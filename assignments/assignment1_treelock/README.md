# Programming Assignment 1: Tree Lock

## Overview

In this assignment, you will implement a **Tree Lock** - a scalable mutual exclusion lock for *n* threads using Peterson's algorithm as building blocks.

## Background

### Peterson's Algorithm

Peterson's algorithm provides mutual exclusion for **at most two threads**. The algorithm uses two boolean flags and a victim variable to ensure:

- **Mutual Exclusion**: At most one thread is in the critical section
- **Deadlock Freedom**: If threads are trying to enter, one will eventually succeed
- **Starvation Freedom**: Every thread that tries to enter will eventually succeed

### The TreeLock Approach

To achieve mutual exclusion for *n* threads, we arrange individual Peterson locks (Peterson Nodes) into a **binary tree structure**:

- Each **leaf** corresponds to a thread (identified by thread ID 0 to n-1)
- Each **internal node** is a Peterson lock protecting access between left and right subtrees
- To acquire the TreeLock, a thread must acquire **all** Peterson nodes on the path from its leaf to the root
- Once a thread acquires the root node, it has exclusive access to the critical section

#### Example: TreeLock for 4 threads

```text
                [Root Node 0]
                /           \
        [Node 1]            [Node 2]
         /    \              /    \
      T0      T1          T2      T3
```

Each internal node is a Peterson lock. Thread 0 would acquire Node 1, then Node 0 (root).

### Key Algorithm Properties

- **Tree Depth**: For *n* threads, minimum depth is ⌈log₂(n)⌉
- **Number of Nodes**: A complete binary tree of depth *d* has 2^*d* - 1 internal nodes
- **Lock Acquisition**: Threads acquire locks from leaf to root
- **Lock Release**: Threads release locks from root to leaf (reverse order)
- **Scalability**: Each thread acquires O(log n) locks, reducing contention

## Your Task

You will find the following files in your starter code:

**Provided (complete):**

- `PetersonNode.ml` - Complete Peterson lock implementation using atomics
- `PetersonNode.mli` - Peterson lock interface
- `TreeLock.mli` - TreeLock interface specification

**To implement:**

- `TreeLock.ml` - Tree lock using Peterson nodes
- `Test.ml` - Comprehensive tests

**Important:** The PetersonNode implementation is provided complete because it requires proper use of atomic operations to avoid data races. You don't need to understand the details of this implementation. Study the PetersonNode interface carefully to understand how to use it in your TreeLock implementation.

### TreeLock Module

Implement the following functions in `TreeLock.ml`:

1. **`calculate_depth n`** - Calculate tree depth for n threads (⌈log₂(n)⌉)

2. **`thread_id_to_path thread_id depth`** - Map thread ID to its path through the tree
   - Hint: Use binary representation
   - Returns array of 0s and 1s (0=left, 1=right)

3. **`path_to_index path level`** - Convert path to array index at given level
   - Use standard binary tree array indexing
   - Parent at i, children at 2i+1 and 2i+2

4. **`create num_threads`** - Initialize the tree lock
   - Calculate depth
   - Create array of Peterson nodes (2^depth - 1 nodes)

5. **`lock tree thread_id`** - Acquire the lock
   - Get path from root to this thread's leaf
   - Acquire Peterson locks from **leaf to root**
   - At each node, use 0 for left branch, 1 for right branch

6. **`unlock tree thread_id`** - Release the lock
   - Release locks from **root to leaf** (reverse order)

### Testing

Add comprehensive tests in `Test.ml`:

- Test with 2, 4, 8 threads
- Test with non-power-of-two thread counts (e.g., 5 threads)
- Verify mutual exclusion with concurrent counter increments
- Test tree structure (correct depth and node count)
- Stress tests with complex critical sections

A basic two-thread test is provided as a starting point.

## Implementation Hints

### Tree Structure

- Depth: *d* = ⌈log₂(n)⌉
- Total nodes: 2^*d* - 1
- Store in array: parent at index *i*, children at 2*i*+1 and 2*i*+2

### Thread Path Mapping

Use binary representation of thread ID:

- Thread 0 (binary: 00) → left, left
- Thread 1 (binary: 01) → left, right
- Thread 2 (binary: 10) → right, left
- Thread 3 (binary: 11) → right, right

### Lock Acquisition Order

**Critical**: Acquire locks **leaf → root**, release **root → leaf**

1. Start at leaf corresponding to your thread ID
2. Acquire Peterson lock at each node on path to root
3. At each Peterson node, use thread_id ∈ {0, 1} based on branch direction
4. Continue until you acquire the root
5. When unlocking, release in reverse order

## Building and Running

```bash
# Build the project
dune build

# Run tests
dune exec ./test.exe

# Or use Make
make build
make test
```

## Testing Your Implementation

The test suite is organized into three progressive parts:

### Part 1: Unit Tests

These test individual helper functions and structural properties:

1. **`test_calculate_depth`** - Verifies depth calculation for various thread counts
2. **`test_tree_structure`** - Checks tree structure (depth and node count)
3. **`test_boundary_conditions`** - Tests edge cases (single thread, powers of 2, invalid inputs)

Start by implementing the helper functions and ensuring these tests pass before moving to concurrent tests.

### Part 2: Sequential Correctness Tests

These verify basic functionality with a single thread:

1. **`test_single_thread`** - Single thread repeatedly acquires and releases the lock
2. **`test_sequential_acquisitions`** - Multiple threads acquire lock sequentially (no concurrency)

These tests confirm your lock/unlock logic works correctly without race conditions.

### Part 3: Concurrent Correctness Tests

These test mutual exclusion with actual concurrency:

1. **`test_two_threads`** - Basic two-thread test (provided as example)
2. **`test_four_threads`** - Four threads incrementing counter
3. **`test_eight_threads`** - Eight threads (power of 2)
4. **`test_five_threads`** - Five threads (non-power of 2)
5. **`test_stress`** - Stress test with complex critical sections
6. **`test_structure_verification`** - Re-verify structure properties under concurrent load
7. **`test_performance`** - Performance benchmark

### Testing Strategy

1. **Start with utility functions**: Implement and test `get_depth`, `get_num_nodes`, `print_tree_info`
2. **Implement helper functions**: Get unit tests passing for `calculate_depth`, `thread_id_to_path`, `path_to_index`
3. **Implement tree structure**: Get `create` working and verify tree structure tests pass
4. **Test sequentially**: Implement `lock` and `unlock`, verify with sequential tests
5. **Test concurrently**: Gradually add concurrent tests and verify mutual exclusion

Each test function (except `test_two_threads` which is provided) contains a `failwith "Not implemented"` that you should replace with actual test code once your TreeLock implementation is ready.

**Tip**: Run tests frequently as you implement each function. The progressive test structure helps you debug issues incrementally.

## Grading

Your assignment will be graded on:

- **Correctness (70%)**
  - TreeLock provides mutual exclusion (30%)
  - Correct tree structure and depth calculation (15%)
  - Correct lock acquisition/release order (15%)
  - Handles various thread counts correctly (10%)

- **Implementation Quality (20%)**
  - Clean, readable code (5%)
  - Efficient algorithms (5%)
  - Good code organization (5%)
  - Proper documentation/comments (5%)

- **Testing (10%)**
  - Comprehensive test coverage (5%)
  - Tests for edge cases (5%)

**Note:** PetersonNode.ml is provided complete for you to use. Focus your implementation on TreeLock and comprehensive testing.

## Submission

Submit the following files:

- `TreeLock.ml`
- `Test.ml`

**Do not submit** `PetersonNode.ml` - it is provided and should not be modified.

## Tips

1. **Start small**: Get it working for 2 threads first, then generalize
2. **Use the interface**: Study `TreeLock.mli` to understand what you need to implement
3. **Debug with print statements**: Use `Printf.printf` to trace lock acquisition
4. **Test incrementally**: Test each helper function before moving to the next
5. **Draw it out**: Sketch the tree structure for small examples (2, 4, 8 threads)

## Common Pitfalls

- ❌ Acquiring locks in wrong order (root→leaf instead of leaf→root)
- ❌ Off-by-one errors in array indexing
- ❌ Using floor instead of ceiling for log₂
- ❌ Not handling non-power-of-two thread counts
- ❌ Confusing global thread ID with Peterson node thread ID (0/1)

## Resources

- Course lecture notes on Peterson's algorithm
- Herlihy & Shavit, *The Art of Multiprocessor Programming*, Chapter 2
- OCaml `Atomic` module: <https://ocaml.org/api/Atomic.html>
- OCaml `Domain` module: <https://ocaml.org/api/Domain.html>

## Getting Help

If you get stuck:

1. Review the lecture slides on Peterson's algorithm
2. Draw the tree structure for a small example
3. Trace through the algorithm step-by-step
4. Check that your binary path calculation is correct

Good luck!
