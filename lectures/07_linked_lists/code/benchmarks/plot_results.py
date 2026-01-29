#!/usr/bin/env python3
"""
Plot benchmark results for linked list implementations.
Generates three plots matching the slide format:
1. High Contains Ratio (90%)
2. Low Contains Ratio (50%)
3. Varying Contains Ratio (32 threads)
"""

import csv
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path

# Style configuration matching the slide aesthetics
IMPL_STYLES = {
    'lockfree': {'label': 'Lock-free', 'marker': 's', 'color': 'black', 'linestyle': '--'},
    'lazy': {'label': 'Lazy list', 'marker': '^', 'color': 'blue', 'linestyle': '-'},
    'lazy_racefree': {'label': 'Lazy (race-free)', 'marker': '^', 'color': 'cyan', 'linestyle': '--'},
    'optimistic': {'label': 'Optimistic', 'marker': 'v', 'color': 'green', 'linestyle': '-.'},
    'optimistic_racefree': {'label': 'Optimistic (race-free)', 'marker': 'v', 'color': 'lime', 'linestyle': ':'},
    'fine': {'label': 'Fine-grained', 'marker': 'o', 'color': 'red', 'linestyle': '-'},
    'coarse': {'label': 'Coarse-grained', 'marker': 'D', 'color': 'orange', 'linestyle': ':'},
}

def read_csv(filename):
    """Read CSV file and return data grouped by implementation."""
    data = {}
    with open(filename, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            impl = row['impl']
            if impl not in data:
                data[impl] = {'threads': [], 'contains_pct': [], 'median': [], 'avg': []}
            data[impl]['threads'].append(int(row['threads']))
            data[impl]['contains_pct'].append(int(row['contains_pct']))
            data[impl]['median'].append(float(row['median']))
            data[impl]['avg'].append(float(row['avg']))
    return data

def plot_thread_scaling(csv_file, title, output_file):
    """Plot throughput vs thread count."""
    data = read_csv(csv_file)

    fig, ax = plt.subplots(figsize=(8, 6))

    # Plot each implementation
    for impl in ['coarse', 'fine', 'optimistic', 'optimistic_racefree', 'lazy', 'lazy_racefree', 'lockfree']:
        if impl in data:
            style = IMPL_STYLES[impl]
            threads = data[impl]['threads']
            throughput = data[impl]['median']

            ax.plot(threads, throughput,
                   marker=style['marker'],
                   color=style['color'],
                   linestyle=style['linestyle'],
                   markersize=8,
                   linewidth=2,
                   label=style['label'])

    ax.set_xlabel('threads', fontsize=12)
    ax.set_ylabel('Ops/sec (90% reads/0 load)', fontsize=12)
    ax.set_title(title, fontsize=14, fontweight='bold')
    ax.legend(loc='upper left', fontsize=10)
    ax.grid(True, alpha=0.3)

    # Format y-axis with scientific notation
    ax.ticklabel_format(style='scientific', axis='y', scilimits=(0,0))

    plt.tight_layout()
    plt.savefig(output_file, dpi=150, bbox_inches='tight')
    print(f"Saved {output_file}")
    plt.close()

def plot_varying_contains(csv_file, output_file):
    """Plot throughput vs contains percentage (fixed 28 threads)."""
    data = read_csv(csv_file)

    fig, ax = plt.subplots(figsize=(8, 6))

    # Plot each implementation
    for impl in ['coarse', 'fine', 'optimistic', 'optimistic_racefree', 'lazy', 'lazy_racefree', 'lockfree']:
        if impl in data:
            style = IMPL_STYLES[impl]
            contains_pct = data[impl]['contains_pct']
            throughput = data[impl]['median']

            ax.plot(contains_pct, throughput,
                   marker=style['marker'],
                   color=style['color'],
                   linestyle=style['linestyle'],
                   markersize=8,
                   linewidth=2,
                   label=style['label'])

    ax.set_xlabel('% Contains()', fontsize=12)
    ax.set_ylabel('Ops/sec (28 threads/0 load)', fontsize=12)
    ax.set_title('As Contains Ratio Increases', fontsize=14, fontweight='bold')
    ax.legend(loc='upper left', fontsize=10)
    ax.grid(True, alpha=0.3)

    # Format y-axis with scientific notation
    ax.ticklabel_format(style='scientific', axis='y', scilimits=(0,0))

    plt.tight_layout()
    plt.savefig(output_file, dpi=150, bbox_inches='tight')
    print(f"Saved {output_file}")
    plt.close()

def main():
    # Get script directory and construct results path relative to it
    script_dir = Path(__file__).parent.absolute()
    results_dir = script_dir.parent / 'results'

    if not results_dir.exists():
        print(f"Error: Results directory not found: {results_dir}")
        return

    print("Generating plots...")

    # Plot 1: High Contains Ratio
    high_csv = results_dir / 'high_contains.csv'
    if high_csv.exists():
        plot_thread_scaling(
            high_csv,
            'High Contains Ratio',
            results_dir / 'plot_high_contains.png'
        )
    else:
        print(f"Warning: {high_csv} not found")

    # Plot 2: Low Contains Ratio
    low_csv = results_dir / 'low_contains.csv'
    if low_csv.exists():
        plot_thread_scaling(
            low_csv,
            'Low Contains Ratio',
            results_dir / 'plot_low_contains.png'
        )
    else:
        print(f"Warning: {low_csv} not found")

    # Plot 3: Varying Contains Ratio
    varying_csv = results_dir / 'varying_contains.csv'
    if varying_csv.exists():
        plot_varying_contains(
            varying_csv,
            results_dir / 'plot_varying_contains.png'
        )
    else:
        print(f"Warning: {varying_csv} not found")

    print("\nAll plots generated successfully!")

if __name__ == '__main__':
    main()
