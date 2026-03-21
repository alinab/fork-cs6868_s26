#!/usr/bin/env python3
"""Plot fib benchmark results: cutoff sweep or domain scaling."""

import sys
import csv
import matplotlib.pyplot as plt


def parse_output(raw):
    """Parse benchmark output, return (header_info, mode, rows)."""
    lines = raw.strip().split('\n')
    info = {}
    for line in lines:
        # Match lines like "fib(42) = 267914296" or "qsort(10000000 elements)"
        if '(' in line and ')' in line and not line.startswith('#') and 'title' not in info:
            info['title'] = line.split('=')[0].strip() if '=' in line else line.strip()
        elif line.startswith('Sequential:'):
            info['t_seq'] = line.split()[1]
        elif line.startswith('Max domains:'):
            info['max_domains'] = line.split()[-1]

    mode = None
    csv_idx = 0
    for i, l in enumerate(lines):
        if l.startswith('cutoff,'):
            mode = 'cutoff'
            csv_idx = i
            break
        if l.startswith('domains,'):
            mode = 'domains'
            csv_idx = i
            break
    if mode is None:
        raise ValueError('No CSV header found')

    csv_lines = [lines[csv_idx]] + [l for l in lines[csv_idx+1:] if l and not l.startswith('#')]
    reader = csv.DictReader(csv_lines)

    return info, mode, list(reader)


def plot_cutoff(info, rows, out):
    cutoffs = [int(r['cutoff']) for r in rows]
    speedups = [float(r['speedup']) for r in rows]
    num_tasks = [int(r['num_tasks']) for r in rows]

    fig, ax1 = plt.subplots(figsize=(8, 5))
    color_speedup = '#2563eb'
    color_tasks = '#dc2626'

    ax1.plot(cutoffs, speedups, 'o-', color=color_speedup, linewidth=2,
             markersize=7, label='Speedup')
    ax1.set_xlabel('Cutoff (sequential threshold)', fontsize=12)
    ax1.set_ylabel('Speedup over sequential', fontsize=12, color=color_speedup)
    ax1.tick_params(axis='y', labelcolor=color_speedup)
    ax1.set_ylim(bottom=0)

    ax2 = ax1.twinx()
    ax2.plot(cutoffs, num_tasks, 's--', color=color_tasks, linewidth=1.5,
             markersize=6, label='# tasks spawned')
    ax2.set_ylabel('Tasks spawned (log scale)', fontsize=12, color=color_tasks)
    ax2.set_yscale('log')
    ax2.tick_params(axis='y', labelcolor=color_tasks)

    lines1, labels1 = ax1.get_legend_handles_labels()
    lines2, labels2 = ax2.get_legend_handles_labels()
    ax1.legend(lines1 + lines2, labels1 + labels2, loc='center right', fontsize=11)

    ax1.set_xticks(cutoffs)
    ax1.grid(axis='y', alpha=0.3)
    title = info.get('title', '?')
    d = info.get('max_domains', '?')
    fig.suptitle(f'Granularity Control: {title} on {d} domains',
                 fontsize=14, fontweight='bold')
    fig.tight_layout()
    fig.savefig(out, dpi=150)
    print(f'Saved plot to {out}')


def plot_domains(info, rows, out):
    domains = [int(r['domains']) for r in rows]
    speedups = [float(r['speedup']) for r in rows]

    fig, ax = plt.subplots(figsize=(8, 5))
    max_d = max(domains)

    ax.plot([1, max_d], [1, max_d], 'k--', alpha=0.3, label='Ideal (linear)')
    ax.plot(domains, speedups, 'o-', color='#2563eb', linewidth=2,
            markersize=7, label='Measured speedup')
    ax.set_xlabel('Number of domains', fontsize=12)
    ax.set_ylabel('Speedup over sequential', fontsize=12)
    ax.set_xticks(domains)
    ax.set_ylim(bottom=0)
    ax.grid(axis='both', alpha=0.3)
    ax.legend(fontsize=11)

    title = info.get('title', '?')
    fig.suptitle(f'Domain Scaling: {title}',
                 fontsize=14, fontweight='bold')
    fig.tight_layout()
    fig.savefig(out, dpi=150)
    print(f'Saved plot to {out}')


def main():
    if len(sys.argv) > 1:
        with open(sys.argv[1]) as f:
            raw = f.read()
    else:
        raw = sys.stdin.read()

    info, mode, rows = parse_output(raw)
    default_out = f'fib_{mode}.png'
    out = sys.argv[2] if len(sys.argv) > 2 else default_out

    if mode == 'cutoff':
        plot_cutoff(info, rows, out)
    elif mode == 'domains':
        plot_domains(info, rows, out)
    else:
        print(f'Unknown mode: {mode}', file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
