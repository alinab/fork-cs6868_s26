import re
import numpy as np
import matplotlib.pyplot as plt

# ---------------------------------------------------------------------------
# Parse the results file
# ---------------------------------------------------------------------------

def parse_results(filename):
    rows = []
    with open(filename) as f:
        for line in f:
            line = line.strip()
            m = re.match(
                r'(ws|naive)\s+'
                r'(\S+)\s+'
                r'(\d+)\s+'
                r'(\d+)\s+'
                r'(\S+)\s+'
                r'(\d+\.\d+)\s+'
                r'(\d+\.\d+)\s+'
                r'(\d+\.\d+)',
                line
            )
            if m:
                sched, policy, workers, threshold, steal_ratio, avg, sd, speedup = m.groups()
                sr_match  = re.search(r'\((\d+\.\d+)%\)', steal_ratio)
                tc_match  = re.search(r'(\d+)/(\d+)',     steal_ratio)
                sr_pct    = float(sr_match.group(1))  if sr_match  else 0.0
                task_count = int(tc_match.group(2))   if tc_match  else 0
                rows.append({
                    'scheduler':  sched,
                    'policy':     policy,
                    'workers':    int(workers),
                    'threshold':  int(threshold),
                    'steal_pct':  sr_pct,
                    'task_count': task_count,
                    'avg':        float(avg),
                    'sd':         float(sd),
                    'speedup':    float(speedup),
                    'throughput': task_count / float(avg) if float(avg) > 0 else 0.0,
                })
    return rows

def add_naive_throughput(rows):
    # naive rows have task_count=0 — fill from ws-random at same workers/threshold
    for r in rows:
        if r['scheduler'] == 'naive' and r['task_count'] == 0:
            # find matching ws row for task count
            for ref in rows:
                if (ref['scheduler'] == 'ws'
                        and ref['policy'] == 'random'
                        and ref['workers'] == r['workers']
                        and ref['threshold'] == r['threshold']):
                    r['task_count'] = ref['task_count']
                    r['throughput'] = ref['task_count'] / r['avg'] if r['avg'] > 0 else 0.0
                    break
    return rows

rows = parse_results('result-fibonacci.txt')
rows = add_naive_throughput(rows)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

workers_list    = sorted(set(r['workers']   for r in rows))
thresholds_list = sorted(set(r['threshold'] for r in rows))
policies        = ['random', 'round-robin']

colors  = {'random': '#2563eb', 'round-robin': '#16a34a', '-': '#dc2626'}
markers = {'random': 'o',       'round-robin': 's',       '-': '^'}
thresh_colors = {20: '#7c3aed', 25: '#0891b2', 30: '#ea580c'}

def get(sched, policy, workers, threshold, field):
    for r in rows:
        if (r['scheduler'] == sched and r['policy'] == policy
                and r['workers'] == workers and r['threshold'] == threshold):
            return r[field]
    return None

def errbars(sched, policy, workers_list, threshold):
    ys   = [get(sched, policy, w, threshold, 'speedup') for w in workers_list]
    sds  = [get(sched, policy, w, threshold, 'sd')      for w in workers_list]
    avgs = [get(sched, policy, w, threshold, 'avg')     for w in workers_list]
    err  = [sd / avg * sp if avg else 0
            for sd, avg, sp in zip(sds, avgs, ys)]
    return ys, err

# ---------------------------------------------------------------------------
# Combined figure  (3 rows x 2 cols)
#
#  [A] speedup vs workers (random)      [B] speedup vs workers (round-robin)
#  [C] steal ratio vs workers (random)  [D] steal ratio vs workers (rr)
#  [E] throughput vs workers (random)   [F] throughput vs workers (rr)
# ---------------------------------------------------------------------------

fig, axes = plt.subplots(3, 2, figsize=(13, 13))
fig.suptitle('Parallel Fibonacci  fib(38) — Benchmark Summary',
             fontsize=14, fontweight='bold', y=1.01)

# --- Row 0: speedup vs workers --------------------------------------------
for col, policy in enumerate(policies):
    ax = axes[0, col]
    for thresh in thresholds_list:
        ys, err = errbars('ws', policy, workers_list, thresh)
        ax.errorbar(workers_list, ys, yerr=err,
                    label=f'ws threshold={thresh}',
                    color=thresh_colors[thresh], marker='o',
                    linewidth=1.8, capsize=3)
    ys_n, err_n = errbars('naive', '-', workers_list, thresholds_list[0])
    ax.errorbar(workers_list, ys_n, yerr=err_n,
                label='naive',
                color=colors['-'], marker=markers['-'],
                linewidth=1.8, linestyle='--', capsize=3)
    ax.plot(workers_list, workers_list,
            color='gray', linestyle=':', linewidth=1.2, label='ideal')
    ax.set_title(f'Speedup vs Workers  ({policy})', fontsize=10)
    ax.set_xlabel('Workers')
    ax.set_xticks(workers_list)
    ax.set_ylabel('Speedup')
    ax.legend(fontsize=7.5)
    ax.grid(True, alpha=0.3)

# --- Row 1: steal ratio vs workers ----------------------------------------
for col, policy in enumerate(policies):
    ax = axes[1, col]
    for thresh in thresholds_list:
        ys = [get('ws', policy, w, thresh, 'steal_pct') for w in workers_list]
        ax.plot(workers_list, ys,
                label=f'threshold={thresh}',
                color=thresh_colors[thresh], marker='o', linewidth=1.8)
    ax.set_title(f'Steal Ratio vs Workers  ({policy})', fontsize=10)
    ax.set_xlabel('Workers')
    ax.set_xticks(workers_list)
    ax.set_ylabel('Steal ratio (%)')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

# --- Row 2: throughput vs workers -----------------------------------------
for col, policy in enumerate(policies):
    ax = axes[2, col]
    for thresh in thresholds_list:
        ys = [get('ws', policy, w, thresh, 'throughput') for w in workers_list]
        ax.plot(workers_list, ys,
                label=f'ws threshold={thresh}',
                color=thresh_colors[thresh], marker='o', linewidth=1.8)
    # naive throughput
    ys_n = [get('naive', '-', w, thresholds_list[1], 'throughput')
            for w in workers_list]
    ax.plot(workers_list, ys_n,
            label='naive',
            color=colors['-'], marker=markers['-'],
            linewidth=1.8, linestyle='--')
    ax.set_title(f'Throughput vs Workers  ({policy})', fontsize=10)
    ax.set_xlabel('Workers')
    ax.set_xticks(workers_list)
    ax.set_ylabel('Tasks / second')
    ax.legend(fontsize=7.5)
    ax.grid(True, alpha=0.3)

# ---------------------------------------------------------------------------
plt.tight_layout()
plt.savefig('fib_combined_throughput.png',
            dpi=150, bbox_inches='tight')
plt.close()
print('Saved fib_combined_throughput.png')
