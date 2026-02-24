# Programming Assignment 2: Atomic Snapshot

**Points:** 100

## Learning Objectives

This assignment focuses on **testing concurrent correctness**. You will:

1. Implement an n-register atomic snapshot using the double-collect algorithm
2. Write property-based linearizability tests using **QCheck-Lin**
3. Complete state machine tests using **QCheck-STM**
4. Use **ThreadSanitizer (TSAN)** to detect data races
5. Understand how to verify concurrent correctness systematically

**Primary focus:** Testing methodology and concurrent correctness verification.

---

## Prerequisites

Make sure your OCaml environment is set up before starting. See the [course
resources page](/resources/) for full installation instructions.

The packages required for this assignment are included in the standard course
setup:

```bash
opam install qcheck-lin qcheck-stm
```

For Part 5 (TSAN) you will need an additional TSAN-enabled switch — instructions
are in the Part 5 section below.

---

## Background

### Atomic Snapshot Objects

An **atomic snapshot object** provides:

- Multiple **registers** that can be updated independently. All updates use
unique values.
- An atomic **scan** operation that returns a consistent view of all registers

The challenge: How do you read multiple locations "simultaneously" without
locks?

### The Double-Collect Algorithm

The double-collect algorithm (seen in Quiz 2) provides a simple solution:

1. Collect all register values once
2. Collect all register values again
3. If both reads match → return the result (no update occurred between reads)
4. If they differ → retry (a concurrent update may have interleaved)

**Key insight:** If two consecutive collects return the same values, no update
*occurred between them, so the result represents a real state that existed.

**Properties:**

- ✅ **Linearizable**: Every scan returns a state that actually existed
- ✅ **Lock-free**: System makes progress (writers always succeed)
- ❌ **Not wait-free**: Individual scanner can starve (keep retrying)

---

## Your Task

You will implement and thoroughly test an atomic snapshot object.

### Files to Complete

1. **`Snapshot.ml`** - Atomic snapshot implementation
   - `create` - initialize n registers
   - `update` - write to a register
   - `scan` - atomic snapshot using double-collect
   - `size` - return number of registers

2. **`test_manual.ml`** - Manual concurrent tests
   - Test sequential operations
   - Test concurrent updates from multiple threads
   - Test concurrent scans
   - Test high contention scenarios

3. **`qcheck_lin_snapshot.ml`** - QCheck-Lin linearizability test
   - **You write this from scratch** following Lecture 3 examples
   - Define the Lin API specification
   - Generate linearizability tests
   - Should PASS (double-collect is linearizable)

4. **`qcheck_stm_snapshot.ml`** - QCheck-STM state machine test
   - **Complete the TODOs** in the provided skeleton
   - Implement `next_state` - update model state
   - Implement `postcond` - verify results match model
   - Understand sequential vs. concurrent testing

### Provided Files

- **`Snapshot.mli`** - Complete interface (do not modify)
- **`dune`**, **`dune-project`** - Build configuration
- **`Makefile`** - Convenience targets

---

## Part 1: Implementation (20 points)

Implement the atomic snapshot in `Snapshot.ml`.

### Requirements

1. Use `Atomic.t` for registers (avoid data races)
2. Implement double-collect algorithm for scan
3. Handle invalid arguments (negative size, out-of-bounds index)

---

## Part 2: Manual Tests (20 points)

Complete `test_manual.ml` with concurrent correctness tests.

### Required Tests

1. **Sequential test**: Basic operations work correctly
2. **Concurrent updates**: Multiple threads updating different registers
3. **Concurrent scans**: Multiple simultaneous scanners verify consistency
4. **High contention**: Many readers and writers on few registers

### Testing Strategy

For concurrent scans, verify **consistency**: if your writers maintain a known
relationship between registers (e.g., always update them together so that a
certain invariant holds), every scan should observe a state where that invariant
holds. A scan that sees a "mixed" state would indicate a linearizability
violation.

Think about what invariant to establish and how to check it in each scan result.

---

## Part 3: QCheck-Lin Test (25 points)

Write `qcheck_lin_snapshot.ml` from scratch, following Lecture 3 examples.

### Study These Examples

From Lecture 3 code (course public repository):

- `lectures/03_concurrent_objects/code/test/qcheck_lin_bounded.ml`
- `lectures/03_concurrent_objects/code/test/qcheck_lin_lockfree.ml`

Study these examples carefully and adapt them for the Snapshot API. Your code
must properly specify the `update` and `scan` operations in the Lin DSL.

### Lin DSL Hints

The key challenge is specifying the return type of `scan`, which returns an `int
array`. The examples you are studying only show `int` and `unit` return types —
here is the full set of relevant combinators:

| Return type | Lin combinator |
| --- | --- |
| `unit` | `returning unit` |
| `int` | `returning int` |
| `int array` | `returning (array int)` |
| `unit` (may raise) | `returning_or_exc unit` |
| `int` (may raise) | `returning_or_exc int` |

**`returning` vs `returning_or_exc`**: Use `returning` when your generator
ensures the inputs are always valid (no exception expected). Use
`returning_or_exc` when the function may legitimately raise.

For this assignment, define `index` and `int_small` generators yourself,
following the pattern in the examples. The index generator should only produce
values within the length of the atomic snapshot object, so `Invalid_argument`
will never be raised during tests.

### What Lin Tests

- Generates random concurrent scenarios (sequential prefix + parallel domains)
- Records all operation results
- Searches for a sequential interleaving that produces same results
- If none found → **linearizability violation!**

Your test should **PASS** (double-collect is linearizable).

---

## Part 4: QCheck-STM Test (25 points)

Complete `qcheck_stm_snapshot.ml` by filling in TODOs.

### Study This Example

From Lecture 3 code (course public repository):

- `lectures/03_concurrent_objects/code/test/qcheck_stm_lockfree.ml`

Pay attention to how `next_state` and `postcond` are structured, and how the
model `state` type maps to the real implementation's state.

### What is STM Testing?

State Machine Testing compares your implementation against a sequential model:

1. **Model state**: Simple array representing register values
2. **Commands**: Update(idx, value) and Scan()
3. **next_state**: How command should update the model
4. **run**: Execute command on real implementation
5. **postcond**: Verify real result matches model prediction

### Your Tasks

Implement these functions:

#### 1. `next_state` - Update the model

Given a command and the current model state (an array of register values),
return the new model state after the command executes. For `Update`, this means
reflecting the write in the model. For `Scan`, the state is unchanged.

#### 2. `postcond` - Verify correctness

Given a command, the model state **before** the command, and the actual result
from the implementation, return `true` if the result is consistent with what the
model predicts. Think carefully about what the model says each command should
return.

### Running STM Tests

```bash
# Sequential test (should pass easily)
dune exec ./qcheck_stm_snapshot.exe -- sequential

# Concurrent test (tests linearizability)
dune exec ./qcheck_stm_snapshot.exe -- concurrent
```

---

## Part 5: TSAN Verification (10 points)

Use ThreadSanitizer to verify your implementation is data-race-free.

### Setup

You need OCaml with TSAN support:

```bash
# Disable ASLR (Has to be executed after every reboot)
sudo sysctl -w kernel.randomize_va_space=0

# Install TSAN-enabled compiler
opam switch create 5.4.0+tsan ocaml-option-tsan
eval $(opam env)
```

### Testing for Data Races

#### Test 1: Non-Atomic Implementation (should have races)

Temporarily modify `Snapshot.ml` to use regular (non-atomic) mutable references
instead of `Atomic.t` for the registers. Run your manual tests under TSAN.

**Expected:** TSAN reports data races on unsynchronized register access.

#### Test 2: Atomic Implementation (should be race-free)

Restore the original implementation with `Atomic.t`:

```bash
dune exec ./test_manual.exe
```

**Expected:** Clean run with no TSAN warnings.

### Report (submit as `TSAN_REPORT.md`)

Document your findings:

1. What data races did TSAN detect with refs?
2. Why does atomic implementation avoid races?
3. Screenshot or copy TSAN output for both cases

---

## Bonus part: Wait-free Atomic Snapshots

- Read, understand and implement the "Gang of Six" algorithm for wait-free atomic
snapshots, published in [this
paper](https://dl.acm.org/doi/10.1145/153724.153741) and described
[here](https://www.cs.yale.edu/homes/aspnes/pinewiki/AtomicSnapshots.html).
- If you choose to attempt this bonus part, submit the wait-free version of the
snapshot object separately as `Bonus.ml` file. It should adhere to the same
interface specified in `Snapshot.mli`.
- Bonus points for successful implementation = 2% of the total course grade
(extra 33% marks in the assignment).

---

## Building and Testing

```bash
# Build everything
make build

# Run all tests
make test

# Run individual test suites
make test-manual      # Manual tests
make test-lin         # QCheck-Lin
make test-stm-seq     # QCheck-STM sequential
make test-stm-conc    # QCheck-STM concurrent
```

---

## Grading Rubric

| Component | Points | Description |
| ----------- | ------ | ----------- |
| **Implementation** | 20 | Correct atomic snapshot with double-collect |
| **Manual Tests** | 20 | Comprehensive concurrent correctness tests |
| **QCheck-Lin** | 25 | Linearizability test (written from scratch) |
| **QCheck-STM** | 25 | State machine test (TODOs completed) |
| **TSAN Report** | 10 | Data race detection and analysis |
| **Total** | 100 | |

### Detailed Criteria

#### Implementation (20 pts)

- Correct double-collect algorithm (10 pts)
- Proper use of atomics (5 pts)
- Error handling (5 pts)

#### Manual Tests (20 pts)

- All four tests implemented (12 pts)
- Proper concurrency testing (5 pts)
- Consistency verification (3 pts)

#### QCheck-Lin (25 pts)

- Correct API specification (10 pts)
- Proper use of Lin DSL (10 pts)
- Test passes (5 pts)

#### QCheck-STM (25 pts)

- `next_state` correct (10 pts)
- `postcond` correct (10 pts)
- Understanding demonstrated (5 pts)

#### TSAN Report (10 pts)

- Detected races with refs (3 pts)
- Clean run with atomics (3 pts)
- Analysis and explanation (4 pts)

---

## Resources

### Course Materials

- Lecture 3: Concurrent Objects (linearizability, QCheck-Lin, QCheck-STM)
- Lecture 4: Memory Consistency Models (atomics, TSAN)
- Quiz 2: 2-register atomic snapshot

### QCheck Documentation

- [OCaml Multicore tests](https://github.com/ocaml-multicore/multicoretests)
- [QCheck-Lin](https://ocaml-multicore.github.io/multicoretests/0.10/qcheck-lin/)
- [QCheck-STM](https://ocaml-multicore.github.io/multicoretests/0.10/qcheck-stm/)

### OCaml Documentation

- [Atomic module](https://ocaml.org/api/Atomic.html)
- [Domain module](https://ocaml.org/api/Domain.html)
- [OCaml Memory Model](https://ocaml.org/manual/5.4/memorymodel.html)

### Academic References

- "The Art of Multiprocessor Programming" Chapter 4 - Foundations of Shared
Memory
- "You Don't Know Jack About Shared Variables" - Hans Boehm

---

## Submission

Submit the following files:

1. `Snapshot.ml` - Your implementation
2. `test_manual.ml` - Manual tests
3. `qcheck_lin_snapshot.ml` - QCheck-Lin test
4. `qcheck_stm_snapshot.ml` - Completed QCheck-STM test
5. `TSAN_REPORT.md` - TSAN analysis

**Submission format:** [TBD - via course management system]

---

## Tips and Common Pitfalls

### Implementation Tips

1. **The collect helper is crucial**: Factor it out and reuse it
2. **Equality check**: Arrays use structural equality in OCaml (`=` works)
3. **Atomic operations**: Always use `Atomic.get` and `Atomic.set`

### Testing Tips

1. **Start simple**: Test sequential operations first
2. **QCheck-Lin**: Follow the examples exactly, change only the relevant parts
3. **QCheck-STM**: Think about what the model *should* do, not what the code does
4. **TSAN**: Make sure you're in the TSAN-enabled switch before testing

### Common Mistakes

- ❌ Using `ref` instead of `Atomic.t` (causes data races)
- ❌ Forgetting to retry in scan when collects differ
- ❌ Wrong QCheck-Lin API signature (check return types!)
- ❌ Using `returning_or_exc` for `update` or `scan` — both should use `returning` since your generators never produce out-of-bounds indices
- ❌ Using `returning int` for `scan` — `scan` returns an array, use `returning (array int)`
- ❌ STM `next_state` mutates the original array — always `Array.copy` first
- ❌ STM postcond too strict — due to concurrency, scan may legitimately return an earlier state

---

## Getting Help

1. Review Lecture 3 examples thoroughly
2. Office hours: [TBD]
3. Discussion forum: [TBD]
4. Read the error messages carefully!

Good luck!
