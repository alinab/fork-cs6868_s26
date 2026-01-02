---
layout: page
title: Resources
permalink: /resources/
banner_image: visalam.jpeg
banner_link: https://www.architecturaldigest.in/story/visalam-the-greatest-example-of-chettinad-deco-in-india/
banner_credit: "Photo © Sam Dalrymple / Architectural Digest"
---

# Software

## OCaml 5

This course requires **OCaml 5.4 or later** for native support of parallelism (domains) and concurrency (effect handlers).

### Installation

Follow the official [OCaml installation guide](https://ocaml.org/docs/install.html). We recommend using `opam`, the OCaml package manager.

**Quick Start (Linux/macOS/WSL):**

```bash
bash -c "sh <(curl -fsSL https://opam.ocaml.org/install.sh)"
opam init
opam switch create 5.4.0
opam install ocaml-lsp-server ocamlformat utop domainslib qcheck-lin qcheck-stm
```

**Windows Users:** Use WSL (Windows Subsystem for Linux) for best compatibility.

### Development Environment

We recommend **Visual Studio Code** with the [OCaml Platform](https://marketplace.visualstudio.com/items?itemName=ocamllabs.ocaml-platform) extension for:

- Syntax highlighting and formatting
- Type information on hover
- Jump to definition
- Error checking
- Auto-completion

Other editors with good OCaml support: Emacs (with Tuareg/Merlin), Vim (with Merlin/coc.nvim).

## Build Tools

- **Dune**: OCaml build system (installed via opam above)
- **Make**: Some examples use Makefiles for convenience

## Benchmarking Tools

- **Hyperfine**: Command-line benchmarking tool - [Installation](https://github.com/sharkdp/hyperfine)

# Learning Resources

## Concurrent Programming

### Primary Textbooks

- **The Art of Multiprocessor Programming (2nd Edition)** by Maurice Herlihy, Nir Shavit, Victor Luchangco, and Michael Spear.
  [Publisher Link](https://shop.elsevier.com/books/the-art-of-multiprocessor-programming/herlihy/978-0-12-415950-1)

  Comprehensive coverage of concurrent algorithms, memory models, and synchronization primitives.

- **Control structures in programming languages: from goto to algebraic effects** by Xavier Leroy.
  [Free Online](https://xavierleroy.org/control-structures/)

  Essential reading on control structures, continuations, and effect handlers - foundational concepts for understanding concurrency and algebraic effects in OCaml 5.

## OCaml Resources

### Getting Started with OCaml

- **CS3100: Paradigms of Programming (Monsoon 2020)** by KC Sivaramakrishnan. [GitHub Repository](https://github.com/kayceesrk/cs3100_m20)

  Introduction to functional programming with OCaml, including lecture notes, code examples, and YouTube video lectures. Good foundation for students new to OCaml.

- **OCaml Programming: Correct + Efficient + Beautiful** by Michael Clarkson et al. [cs3110.github.io/textbook](https://cs3110.github.io/textbook/cover.html)

  Comprehensive textbook on functional programming and OCaml fundamentals.

- **Real World OCaml (2nd Edition)** by Yaron Minsky, Anil Madhavapeddy and Jason Hickey. [dev.realworldocaml.org](https://dev.realworldocaml.org/)

  Practical OCaml programming with real-world examples.

### OCaml 5 Multicore Features

- **OCaml 5.4 Manual**: [Domains](https://ocaml.org/manual/5.4/api/Domain.html) and [Effect Handlers](https://ocaml.org/manual/5.4/api/Effect.html)

- **Parallel Programming in Multicore OCaml**: [ocaml.org/manual/5.4/parallelism.html](https://ocaml.org/manual/5.4/parallelism.html)

- **Introduction to Effect Handlers**: [OCaml.org Tutorial](https://ocaml.org/docs/effects)

- **OCaml Multicore Wiki**: [github.com/ocaml-multicore/ocaml-multicore/wiki](https://github.com/ocaml-multicore/ocaml-multicore/wiki)

### Reference & Practice

- **OCaml Manual**: [ocaml.org/manual](https://ocaml.org/manual/)

- **OCaml API Documentation**: [ocaml.org/api](https://ocaml.org/api/)

- **99 OCaml Problems**: [ocaml.org/problems](https://ocaml.org/problems)

- **Exercism OCaml Track**: [exercism.org/tracks/ocaml](https://exercism.org/tracks/ocaml)

### Community

- **OCaml Discuss**: [discuss.ocaml.org](https://discuss.ocaml.org/)

- **OCaml Discord**: [discord.gg/cCYQbqN](https://discord.gg/cCYQbqN)

## Background Reading

### Computer Architecture & Systems

- **Computer Architecture: A Quantitative Approach** by Hennessy and Patterson

  Essential for understanding memory hierarchies, cache coherence, and multiprocessor systems.

- **Operating Systems: Three Easy Pieces** by Remzi and Andrea Arpaci-Dusseau. [Free online](https://pages.cs.wisc.edu/~remzi/OSTEP/)

  Excellent coverage of concurrency, synchronization, and operating system concepts.

### Memory Models & Consistency

- **C/C++ Memory Model**: [cppreference.com/w/cpp/atomic/memory_order](https://en.cppreference.com/w/cpp/atomic/memory_order)

  Understanding memory ordering and atomics in C/C++.

- **Linux Kernel Memory Barriers**: [kernel.org documentation](https://www.kernel.org/doc/Documentation/memory-barriers.txt)

  Low-level details of memory barriers in system programming.

### Advanced Topics

- **Preshing on Programming**: [preshing.com](https://preshing.com/)

  Excellent blog with articles on concurrency, lock-free programming, and memory models.

- **r/ocaml**: [reddit.com/r/ocaml](https://reddit.com/r/ocaml)
