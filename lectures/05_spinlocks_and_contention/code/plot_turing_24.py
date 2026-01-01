#!/usr/bin/env python3
import matplotlib.pyplot as plt

# Data from benchmark - Turing 24 threads
threads = list(range(1, 25))
tas = [0.040, 0.189, 0.351, 0.718, 0.860, 0.987, 1.043, 1.287, 1.141, 1.225, 
       1.314, 1.431, 1.397, 1.559, 1.743, 2.015, 2.106, 2.267, 2.657, 2.879, 
       2.990, 3.013, 3.267, 3.531]
ttas = [0.041, 0.179, 0.387, 0.531, 0.570, 0.666, 0.564, 0.620, 0.508, 0.561,
        0.572, 0.617, 0.636, 0.637, 0.615, 0.787, 0.916, 1.002, 1.273, 1.268,
        1.182, 1.296, 1.364, 1.537]
backoff = [0.048, 0.219, 0.193, 0.425, 0.463, 0.574, 0.200, 0.275, 0.302, 0.343,
           0.396, 0.421, 0.437, 0.460, 0.509, 0.647, 0.774, 0.820, 1.042, 1.116,
           1.106, 1.249, 1.234, 1.344]
alock = [0.099, 0.638, 0.544, 0.529, 0.510, 0.509, 0.353, 0.366, 0.330, 0.351,
         0.357, 0.335, 0.337, 0.352, 0.380, 0.481, 0.391, 0.392, 0.396, 0.417,
         0.423, 0.423, 0.450, 0.424]
ideal = [0.057] * 24

# Create the plot
plt.figure(figsize=(12, 7))
plt.plot(threads, tas, 'o-', label='TAS', linewidth=2, markersize=6)
plt.plot(threads, ttas, 's-', label='TTAS', linewidth=2, markersize=6)
plt.plot(threads, backoff, '^-', label='Backoff', linewidth=2, markersize=6)
plt.plot(threads, alock, 'd-', label='ALock', linewidth=2, markersize=6)
plt.plot(threads, ideal, '--', label='Ideal', linewidth=2, color='gray', alpha=0.7)

plt.xlabel('Threads', fontsize=12)
plt.ylabel('Time (seconds)', fontsize=12)
plt.title('Shared Counter Benchmark: Time vs Threads (Turing - Intel Xeon)\n1M increments', fontsize=14)
plt.legend(fontsize=11)
plt.grid(True, alpha=0.3)
plt.xticks(range(0, 25, 2))

# Save the plot
plt.tight_layout()
plt.savefig('benchmark_time_turing_24threads.png', dpi=150)
print("Plot saved as benchmark_time_turing_24threads.png")
plt.show()
