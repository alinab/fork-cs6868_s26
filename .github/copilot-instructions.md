# CS6868 Concurrent Programming - AI Coding Agent Instructions

## Project Overview
This is a course website and materials repository for CS6868 (Concurrent Programming) at IITM, Spring 2026. The project combines:
- **Jekyll-based course website** (`_config.yml`, `_layouts/`, `_includes/`, `_sass/`) deployed to GitHub Pages
- **OCaml 5 concurrent programming examples** in `lectures/*/code/` directories  
- **Private assignment solutions** in `cs6868_s26_private/`
- **Reference materials** from related courses in `references/`

## Technology Stack
- **OCaml 5.4+**: Primary language for concurrent/parallel programming examples
- **Dune 3.0+**: Build system for all OCaml code
- **Jekyll 4.3**: Static site generator for course website
- **Ruby/Bundler**: For Jekyll dependencies
- **Hyperfine**: Performance benchmarking tool used throughout

## Architecture & Structure

### Jekyll Website
- **Entry point**: `index.md` (course homepage)
- **Navigation**: Defined in `_data/menu.yml`
- **Lectures metadata**: `_data/lectures.yml` (currently minimal/placeholder)
- **URL structure**: Base URL is `/cs6868_s26` (configured in `_config.yml`)
- **Build output**: `_site/` directory (git-ignored)

### OCaml Code Organization
Each lecture directory (`lectures/NN_topic/code/`) follows a consistent pattern:
- **`dune-project`**: Declares OCaml project (lang dune 3.0)
- **`dune`**: Build rules for executables/libraries
- **`Makefile`**: Provides convenient build/benchmark commands (wraps dune)
- **`README.md`**: Documents the lecture's code examples

Advanced lectures use library structure:
- `lib/`: Multiple library modules (see `lectures/07_linked_lists/code/lib/`)
- `test/`: Test executables including QCheck-based tests (`qcheck-lin`, `qcheck-stm`)
- `benchmarks/`: Performance comparison programs

## Critical Workflows

### Building OCaml Code
```bash
# From any lecture/code directory:
dune build                    # Build all targets
dune exec -- ./program.exe    # Run specific executable
dune clean                    # Clean build artifacts

# Using Makefiles (preferred for benchmarks):
make build                    # Wrapper around dune build
make bench                    # Run hyperfine benchmarks
make bench-quick              # Faster iteration with smaller inputs
```

### Performance Benchmarking
**Convention**: Use `hyperfine` for all performance measurements
```bash
# Standard pattern from lectures/01_introduction/code/Makefile:
hyperfine --warmup 2 --runs 10 \
  --export-markdown results.md \
  --command-name 'sequential' \
  'dune exec -- ./prime_sequential.exe 20000000'
```
- Results exported to markdown for easy inclusion in documentation
- Use variables like `LIMIT := 20_000_000` for configurable parameters
- Quick benchmarks use smaller limits (e.g., `LIMIT_SMALL := 1_000_000`)

### Jekyll Website Development
```bash
# From cs6868_s26/ root:
bundle install           # Install Jekyll dependencies (first time)
bundle exec jekyll serve # Local preview at http://localhost:4000/cs6868_s26/
bundle exec jekyll build # Generate static site to _site/
```

## Key Conventions

### OCaml Multicore Patterns
**Domains**: OCaml 5's parallelism primitive (see `lectures/01_introduction/code/`)
```ocaml
(* Common pattern for parallel computation: *)
let num_domains = int_of_string Sys.argv.(2) in
let domains = Array.init num_domains (fun _ -> 
  Domain.spawn (fun () -> (* work *))) in
Array.iter Domain.join domains
```

**Libraries used consistently**:
- `unix`: For timing and process management
- `domainslib`: Higher-level parallel programming (task pools)
- `qcheck-lin.domain`: Linearizability testing
- `qcheck-stm.domain`: State machine testing

### Mutual Exclusion Implementations
Assignments and lectures build hierarchically:
1. Peterson's lock (2 threads) - Building block
2. Tree lock (n threads) - Composition of Peterson locks at tree nodes
3. Various spinlocks - TAS, TTAS, backoff (lectures/05)
4. Concurrent lists - Coarse, fine, optimistic, lazy, lock-free (lectures/07)

**File naming**: `{algorithm}_{variant}.ml` (e.g., `coarse_list.ml`, `lockfree_list.ml`)

### Testing Strategy
Lecture 07 demonstrates the testing approach for concurrent data structures:
- **Manual tests**: `test/test_{structure}.ml` - Basic correctness
- **Linearizability tests**: `qcheck_lin_{structure}.ml` - Multi-domain safety
- **STM tests**: `qcheck_stm_{structure}.ml` - Sequential/parallel property testing

## Assignment Structure
Located in `cs6868_s26_private/ProgrammingAssignments/`:
- **README.md**: Full specification with background, requirements, and grading rubric
- **Solution files**: Commented with `SOLUTION FILE` markers
- **Template pattern**: Provide skeleton with TODO comments for students

Example from `assignment1_tree_lock/TreeLock.ml`:
```ocaml
(* Calculate the depth of the tree needed for n threads *)
let calculate_depth n =
  (* Depth = ceiling(log2(n)) *)
  if n <= 0 then invalid_arg "Number of threads must be positive";
  (* Implementation details... *)
```

## File Paths & Module Resolution
- Use absolute paths when referencing from root: `lectures/07_linked_lists/code/lib/coarse_list.ml`
- Jekyll includes: Use relative paths from `_includes/` directory
- OCaml modules: Match filename (without .ml) to module name

## Common Pitfalls
- **OCaml**: Ensure OCaml 5.4+ for Domains/Effects support (check with `ocaml --version`)
- **Dune**: Projects use dune 3.0 syntax - don't mix with older dune 2.x patterns
- **Jekyll**: Base URL `/cs6868_s26` means links need proper prefixing in templates
- **Benchmarks**: Always use `--warmup` to avoid cold-start effects in measurements
- **Private code**: Files in `cs6868_s26_private/` are not published to website

## References & Attribution
Course material adapted from:
- "The Art of Multiprocessor Programming" (Herlihy et al.)
- YSC4231 course (Ilya Sergey) - see `references/YSC4231/`
- Xavier Leroy's control structures material

When creating new content, acknowledge sources and maintain academic integrity.
