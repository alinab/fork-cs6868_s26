#!/usr/bin/env python3
import matplotlib.pyplot as plt

# Data from benchmark
threads = [1, 2, 3, 4, 5, 6, 7, 8]
tas = [0.012, 0.057, 0.093, 0.106, 0.216, 0.407, 0.479, 0.607]
ttas = [0.015, 0.050, 0.075, 0.085, 0.193, 0.229, 0.239, 0.259]
backoff = [0.016, 0.040, 0.051, 0.058, 0.080, 0.113, 0.130, 0.168]
ideal = [0.015] * 8

# Create the plot
plt.figure(figsize=(10, 6))
plt.plot(threads, tas, 'o-', label='TAS', linewidth=2, markersize=8)
plt.plot(threads, ttas, 's-', label='TTAS', linewidth=2, markersize=8)
plt.plot(threads, backoff, '^-', label='Backoff', linewidth=2, markersize=8)
plt.plot(threads, ideal, '--', label='Ideal', linewidth=2, color='gray', alpha=0.7)

plt.xlabel('Threads', fontsize=12)
plt.ylabel('Time (seconds)', fontsize=12)
plt.title('Shared Counter Benchmark: Time vs Threads\n1M increments', fontsize=14)
plt.legend(fontsize=11)
plt.grid(True, alpha=0.3)
plt.xticks(threads)

# Save the plot
plt.tight_layout()
plt.savefig('benchmark_time_plot.png', dpi=150)
print("Plot saved as benchmark_time_plot.png")
plt.show()
