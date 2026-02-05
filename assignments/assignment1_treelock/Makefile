# Makefile for TreeLock Assignment (Student Version)

.PHONY: build test clean run help

build:
	dune build

test: build
	dune exec ./test.exe

run: test

clean:
	dune clean

help:
	@echo "Available targets:"
	@echo "  build  - Build the project"
	@echo "  test   - Build and run tests"
	@echo "  run    - Same as test"
	@echo "  clean  - Remove build artifacts"
	@echo "  help   - Show this help message"
