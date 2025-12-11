# Makefile for mutual exclusion examples

DUNE = dune
TARGETS = LockOne LockTwo Peterson Bakery

.PHONY: all clean run-lockone run-locktwo run-peterson run-bakery run-all help

.DEFAULT_GOAL := help

help:  ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

all:  ## Build all examples
	$(DUNE) build

LockOne:  ## Build LockOne only
	$(DUNE) build LockOne.exe

LockTwo:  ## Build LockTwo only
	$(DUNE) build LockTwo.exe

Peterson:  ## Build Peterson only
	$(DUNE) build Peterson.exe

Bakery:  ## Build Bakery only
	$(DUNE) build Bakery.exe

run-lockone:  ## Run LockOne
	$(DUNE) exec ./LockOne.exe

run-locktwo:  ## Run LockTwo
	$(DUNE) exec ./LockTwo.exe

run-peterson:  ## Run Peterson
	$(DUNE) exec ./Peterson.exe

run-bakery:  ## Run Bakery
	$(DUNE) exec ./Bakery.exe

run-all: all  ## Run all examples
	@echo "=== Running LockOne ==="
	$(DUNE) exec ./LockOne.exe
	@echo ""
	@echo "=== Running LockTwo ==="
	$(DUNE) exec ./LockTwo.exe
	@echo ""
	@echo "=== Running Peterson ==="
	$(DUNE) exec ./Peterson.exe
	@echo ""
	@echo "=== Running Bakery ==="
	$(DUNE) exec ./Bakery.exe

clean:  ## Remove build artifacts
	$(DUNE) clean
