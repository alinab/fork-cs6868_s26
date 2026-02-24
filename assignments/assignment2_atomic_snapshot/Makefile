# Programming Assignment 2: Atomic Snapshot
# Student Makefile

.PHONY: all build test clean help test-manual test-lin test-stm test-stm-seq test-stm-conc

# Default target
all: build

# Build the project
build:
	dune build

# Run all tests
test: test-manual test-lin test-stm-seq test-stm-conc

# Run manual concurrent tests
test-manual:
	@echo "=== Running Manual Tests ==="
	dune exec ./test_manual.exe

# Run QCheck-Lin linearizability test
test-lin:
	@echo ""
	@echo "=== Running QCheck-Lin Linearizability Test ==="
	dune exec ./qcheck_lin_snapshot.exe

# Run QCheck-STM sequential test
test-stm-seq:
	@echo ""
	@echo "=== Running QCheck-STM Sequential Test ==="
	dune exec ./qcheck_stm_snapshot.exe -- sequential

# Run QCheck-STM concurrent test
test-stm-conc:
	@echo ""
	@echo "=== Running QCheck-STM Concurrent Test ==="
	dune exec ./qcheck_stm_snapshot.exe -- concurrent

# Clean build artifacts
clean:
	dune clean

# Help
help:
	@echo "Available targets:"
	@echo "  make build         - Build the project"
	@echo "  make test          - Run all tests"
	@echo "  make test-manual   - Run manual concurrent tests"
	@echo "  make test-lin      - Run QCheck-Lin linearizability test"
	@echo "  make test-stm-seq  - Run QCheck-STM sequential test"
	@echo "  make test-stm-conc - Run QCheck-STM concurrent test"
	@echo "  make clean         - Remove build artifacts"
