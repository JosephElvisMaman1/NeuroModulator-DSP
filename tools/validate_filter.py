#!/usr/bin/env python3
"""
validate_filter.py
Validation script for Transposed Direct Form II Biquad Low-Pass Filter
with Bilinear Transform and Frequency Pre-warping.

Compares analytical coefficients, pole-zero stability (|z| < 1),
magnitude and phase response (Bode plot) across 44.1 kHz and 48 kHz.
"""

import numpy as np
import scipy.signal as signal
import matplotlib.pyplot as plt
import os

def calculate_biquad_butterworth_lpf(fc: float, fs: float, q: float = 1.0 / np.sqrt(2.0)):
    """
    Computes 2nd order Butterworth LPF coefficients using Bilinear Transform
    with exact frequency pre-warping.
    """
    # Pre-warping factor
    k = np.tan(np.pi * fc / fs)
    k2 = k * k
    k_over_q = k / q
    alpha = 1.0 + k_over_q + k2

    b0 = k2 / alpha
    b1 = 2.0 * k2 / alpha
    b2 = b0
    a0 = 1.0
    a1 = 2.0 * (k2 - 1.0) / alpha
    a2 = (1.0 - k_over_q + k2) / alpha

    b = np.array([b0, b1, b2], dtype=np.float64)
    a = np.array([a0, a1, a2], dtype=np.float64)
    return b, a, k, alpha

def validate_filter(fc: float = 950.0, fs: float = 48000.0, q: float = 1.0 / np.sqrt(2.0), save_plot_path: str = None):
    print(f"==================================================")
    print(f"BIQUAD LPF VALIDATION (DF2T): Fc={fc} Hz, Fs={fs} Hz, Q={q:.4f}")
    print(f"==================================================")

    b, a, k, alpha = calculate_biquad_butterworth_lpf(fc, fs, q)

    print(f"Pre-warping factor k   : {k:.8f}")
    print(f"Normalization alpha     : {alpha:.8f}")
    print(f"Numerator   [b0, b1, b2]: [{b[0]:.8f}, {b[1]:.8f}, {b[2]:.8f}]")
    print(f"Denominator [a0, a1, a2]: [{a[0]:.8f}, {a[1]:.8f}, {a[2]:.8f}]")

    # Scipy reference butterworth calculation with bilinear transform
    w_discrete = 2.0 * np.pi * fc / fs
    # Analog prototype
    w_prewarped = 2.0 * fs * np.tan(w_discrete / 2.0)
    b_analog, a_analog = signal.butter(2, w_prewarped, btype='low', analog=True)
    b_scipy, a_scipy = signal.bilinear(b_analog, a_analog, fs=fs)

    print("\nVerification against Scipy Bilinear Reference:")
    print(f"Max abs diff numerator   : {np.max(np.abs(b - b_scipy)):.2e}")
    print(f"Max abs diff denominator : {np.max(np.abs(a - a_scipy)):.2e}")
    assert np.allclose(b, b_scipy, atol=1e-6), "Numerator coefficients mismatch!"
    assert np.allclose(a, a_scipy, atol=1e-6), "Denominator coefficients mismatch!"
    print(">>> MATCH SUCCESSFUL: Analytical pre-warping matches scipy.bilinear exactly.")

    # Pole-Zero and Stability analysis
    zeros = np.roots(b)
    poles = np.roots(a)
    pole_magnitudes = np.abs(poles)

    print("\nPole-Zero Analysis:")
    print(f"Zeros : {zeros}")
    print(f"Poles : {poles}")
    print(f"Pole Magnitudes (|z|): {pole_magnitudes}")

    is_stable = np.all(pole_magnitudes < 1.0)
    print(f"System Stability Axiom Check: {'PASSED (All poles inside unit circle)' if is_stable else 'FAILED'}")
    assert is_stable, "Instability detected: poles outside unit circle!"

    # Frequency response evaluation
    w, h = signal.freqz(b, a, worN=4096, fs=fs)
    mag_db = 20.0 * np.log10(np.maximum(np.abs(h), 1e-12))
    phase_deg = np.unwrap(np.angle(h)) * 180.0 / np.pi

    # Check cut-off attenuation (should be ~ -3.01 dB at Fc)
    idx_fc = np.argmin(np.abs(w - fc))
    print(f"\nMagnitude at Cutoff ({w[idx_fc]:.1f} Hz): {mag_db[idx_fc]:.2f} dB (Expected: -3.01 dB)")
    # Check stop-band attenuation at 4000 Hz
    idx_stop = np.argmin(np.abs(w - 4000.0))
    print(f"Magnitude at Stopband (4000 Hz): {mag_db[idx_stop]:.2f} dB (High attenuation)")

    if save_plot_path:
        fig, axs = plt.subplots(2, 2, figsize=(12, 8))
        fig.suptitle(f"Biquad LPF (DF2T) Response: Fc={fc} Hz, Fs={fs} Hz, Q={q:.3f}", fontsize=14)

        # Magnitude response
        axs[0, 0].semilogx(w, mag_db, 'b-', linewidth=2)
        axs[0, 0].axvline(fc, color='r', linestyle='--', label=f'Cutoff Fc={fc} Hz')
        axs[0, 0].axhline(-3.01, color='gray', linestyle=':', label='-3 dB point')
        axs[0, 0].set_title("Magnitude Response (Bode Plot)")
        axs[0, 0].set_xlabel("Frequency (Hz)")
        axs[0, 0].set_ylabel("Gain (dB)")
        axs[0, 0].set_ylim([-60, 5])
        axs[0, 0].set_xlim([20, fs / 2])
        axs[0, 0].grid(True, which="both", ls="-", alpha=0.5)
        axs[0, 0].legend()

        # Phase response
        axs[0, 1].semilogx(w, phase_deg, 'g-', linewidth=2)
        axs[0, 1].axvline(fc, color='r', linestyle='--', label=f'Cutoff Fc={fc} Hz')
        axs[0, 1].set_title("Phase Response")
        axs[0, 1].set_xlabel("Frequency (Hz)")
        axs[0, 1].set_ylabel("Phase (degrees)")
        axs[0, 1].set_xlim([20, fs / 2])
        axs[0, 1].grid(True, which="both", ls="-", alpha=0.5)
        axs[0, 1].legend()

        # Pole-Zero constellation
        theta = np.linspace(0, 2 * np.pi, 200)
        axs[1, 0].plot(np.cos(theta), np.sin(theta), 'k--', label='Unit Circle (|z|=1)')
        axs[1, 0].scatter(np.real(poles), np.imag(poles), color='red', marker='x', s=80, label='Poles')
        axs[1, 0].scatter(np.real(zeros), np.imag(zeros), color='blue', marker='o', s=80, facecolors='none', label='Zeros')
        axs[1, 0].set_title("Pole-Zero Constellation (Z-Domain)")
        axs[1, 0].set_xlabel("Re(z)")
        axs[1, 0].set_ylabel("Im(z)")
        axs[1, 0].axis('equal')
        axs[1, 0].grid(True, ls="-", alpha=0.5)
        axs[1, 0].legend()

        # Direct Form II Transposed simulation with Delta wave test
        # Generate composite signal: Low frequency Delta (2 Hz) + High frequency noise (3000 Hz)
        t = np.linspace(0, 0.05, int(fs * 0.05), endpoint=False)
        test_in = np.sin(2 * np.pi * 2.0 * t) + 0.5 * np.sin(2 * np.pi * 3000.0 * t)
        
        # DF2T sample-by-sample difference equation
        y_df2t = np.zeros_like(test_in)
        w1, w2 = 0.0, 0.0
        for n in range(len(test_in)):
            x_n = test_in[n]
            y_n = b[0] * x_n + w1
            w1 = b[1] * x_n - a[1] * y_n + w2
            w2 = b[2] * x_n - a[2] * y_n
            y_df2t[n] = y_n

        axs[1, 1].plot(t * 1000, test_in, 'gray', alpha=0.5, label='Input (2Hz + 3kHz)')
        axs[1, 1].plot(t * 1000, y_df2t, 'purple', linewidth=2, label='Filtered Output (DF2T)')
        axs[1, 1].set_title("Time Domain DF2T Execution")
        axs[1, 1].set_xlabel("Time (ms)")
        axs[1, 1].set_ylabel("Amplitude")
        axs[1, 1].grid(True, ls="-", alpha=0.5)
        axs[1, 1].legend()

        plt.tight_layout()
        plt.savefig(save_plot_path, dpi=150)
        print(f"\n[+] Validation plot successfully saved to: {save_plot_path}")

if __name__ == "__main__":
    os.makedirs("tools", exist_ok=True)
    plot_path = os.path.join("tools", "biquad_df2t_validation.png")
    # Validate for standard mobile sample rates
    validate_filter(fc=950.0, fs=48000.0, save_plot_path=plot_path)
    validate_filter(fc=1000.0, fs=44100.0)
