# Work-Stealing Deque Implementation in OCaml 5

An implementation of the Chase-Lev dynamic circular work-stealing deque
([SPAA 2005](https://dl.acm.org/doi/10.1145/1073970.1073974)) in OCaml 5,
together with a parallel task scheduler and benchmarks.

## Repository structure

```
.
├── lib/          Core library
│   ├── circular_array.ml   Dynamic cyclic array backing the deque
│   ├── deque.ml            Lock-free work-stealing deque (Chase-Lev)
│   ├── future.ml           Thread-safe single-assignment result box
│   ├── scheduler.ml        Parallel work-stealing scheduler (fork/join)
│   ├── naive_scheduler.ml  Mutex-protected shared-queue scheduler
│   └── benchmark.ml        Shared timing and statistics utilities
│
├── bin/          Benchmark executables
│   ├── fibonacci.ml        Parallel Fibonacci — compute-bound, balanced
│   ├── mergesort.ml        Parallel mergesort — memory-bound, unbalanced
│   └── map.ml              Parallel prime map — compute-bound, balanced
│
├── test/         Correctness tests
│   ├── test_deque_qcheck_lin.ml   QCheck-Lin linearizability tests
│   └── test_deque_qcheck_stm.ml   QCheck-STM sequential model tests
│
├── outputs/      Benchmark results and plots
│
├── report/       LaTeX source for the project report
│
└── dune-project  Dune build configuration
```

## Building

Requires OCaml 5.4 and opam.

```bash
# To check for data races, please install TSAN-instrumented OCaml switch
# and then install dependencies
opam switch create test-tsan ocaml-variants.5.4.0+options ocaml-option-tsan
opam install dune qcheck qcheck-lin qcheck-stm unix
```bash

# Build everything
dune build

# Run tests
dune test
```

## Running benchmarks

```bash
dune exec bin/fibonacci.exe
dune exec bin/mergesort.exe
dune exec bin/map.exe
```

## Running tests

```bash
# QCheck-Lin linearizability test
dune exec test/test_deque_qcheck_lin.exe

# QCheck-STM sequential model test
dune exec test/test_deque_qcheck_stm.exe
```

## Main References

- Chase & Lev. *Dynamic Circular Work-Stealing Deque*. SPAA 2005.
- Arora, Blumofe & Plaxton. *Thread Scheduling for Multiprogrammed
  Multiprocessors*. SPAA 1998.
- Herlihy, Shavit, Luchangco & Spear. *The Art of Multiprocessor
  Programming*. 2nd ed. 2020.
