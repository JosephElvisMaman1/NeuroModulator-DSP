#pragma once

#include <cmath>
#include <cstddef>
#include <algorithm>

/**
 * @file biquad_filter.h
 * @brief Dynamic IIR Biquad Filter in Direct Form II Transposed (DF2T).
 *
 * Implements Bilinear Transform with Frequency Pre-warping for real-time mobile audio.
 * DF2T minimizes floating-point truncation, round-off noise, and internal register overflow
 * on mobile ALUs (ARM Cortex-A / NEON) while requiring only 2 state variables per channel.
 */

namespace neuro_dsp {

struct BiquadCoefficients {
    float b0{1.0f};
    float b1{0.0f};
    float b2{0.0f};
    float a1{0.0f};
    float a2{0.0f};
};

class BiquadFilterDF2T {
public:
    BiquadFilterDF2T() noexcept {
        reset();
    }

    /**
     * @brief Configures filter sample rate and initial cutoff.
     * @param sample_rate Dynamic system sample rate (44100 or 48000 Hz).
     */
    void init(float sample_rate) noexcept {
        sample_rate_ = (sample_rate > 8000.0f) ? sample_rate : 48000.0f;
        reset();
        calculate_coefficients(current_cutoff_, current_q_);
        target_coeffs_ = current_coeffs_;
    }

    /**
     * @brief Computes Butterworth Low-Pass coefficients via Bilinear Transform with pre-warping.
     *
     * Pre-warping factor:
     *   k = tan(pi * Fc / Fs)
     * Normalization factor:
     *   alpha = 1 + (k / Q) + k^2
     * Coefficients:
     *   b0 = k^2 / alpha
     *   b1 = 2 * k^2 / alpha = 2 * b0
     *   b2 = b0
     *   a1 = 2 * (k^2 - 1) / alpha
     *   a2 = (1 - (k / Q) + k^2) / alpha
     *
     * @param cutoff_hz Target cutoff frequency (800 - 1200 Hz for Delta sleep entrainment).
     * @param q Quality factor (Butterworth standard Q = 1 / sqrt(2) ~ 0.70710678).
     */
    void calculate_coefficients(float cutoff_hz, float q = 0.70710678f) noexcept {
        // Clamp cutoff strictly below Nyquist to prevent unstable pole placement
        const float nyquist = sample_rate_ * 0.495f;
        const float fc = std::clamp(cutoff_hz, 10.0f, nyquist);
        const float q_val = (q > 0.01f) ? q : 0.70710678f;

        current_cutoff_ = fc;
        current_q_ = q_val;

        // Bilinear Transform with frequency pre-warping
        constexpr double kPi = 3.14159265358979323846;
        const double k = std::tan(kPi * static_cast<double>(fc) / static_cast<double>(sample_rate_));
        const double k2 = k * k;
        const double k_over_q = k / static_cast<double>(q_val);
        const double alpha = 1.0 + k_over_q + k2;

        if (std::abs(alpha) < 1e-12) {
            return;
        }

        const double inv_alpha = 1.0 / alpha;

        target_coeffs_.b0 = static_cast<float>(k2 * inv_alpha);
        target_coeffs_.b1 = static_cast<float>(2.0 * target_coeffs_.b0);
        target_coeffs_.b2 = target_coeffs_.b0;
        target_coeffs_.a1 = static_cast<float>(2.0 * (k2 - 1.0) * inv_alpha);
        target_coeffs_.a2 = static_cast<float>((1.0 - k_over_q + k2) * inv_alpha);
    }

    /**
     * @brief Processes a single sample in Transposed Direct Form II.
     *
     * Difference Equation:
     *   y[n]  = b0 * x[n] + w1[n-1]
     *   w1[n] = b1 * x[n] - a1 * y[n] + w2[n-1]
     *   w2[n] = b2 * x[n] - a2 * y[n]
     *
     * @param x Input sample.
     * @param channel Channel index (0: Left, 1: Right).
     * @return Filtered output sample y[n].
     */
    [[nodiscard]] inline float process_sample(float x, size_t channel) noexcept {
        // Channel state registers
        float& w1 = state_[channel].w1;
        float& w2 = state_[channel].w2;

        // DF2T Difference Equation
        const float y = current_coeffs_.b0 * x + w1;
        w1 = current_coeffs_.b1 * x - current_coeffs_.a1 * y + w2;
        w2 = current_coeffs_.b2 * x - current_coeffs_.a2 * y;

        // Denormal protection (flushes subnormal floating point numbers to zero)
        if (std::abs(w1) < 1.0e-25f) w1 = 0.0f;
        if (std::abs(w2) < 1.0e-25f) w2 = 0.0f;

        return y;
    }

    /**
     * @brief Processes an interleaved stereo buffer with coefficient interpolation.
     * Prevents audible clicks and zipper noise during cutoff parameter sweeps.
     *
     * @param buffer In/Out interleaved stereo float array [L, R, L, R, ...].
     * @param frames Number of audio frames (samples per channel).
     */
    void process_interleaved(float* buffer, size_t frames) noexcept {
        if (!buffer || frames == 0) return;

        // Smooth coefficient interpolation towards target_coeffs_
        constexpr float smoothing_factor = 0.05f;
        current_coeffs_.b0 += smoothing_factor * (target_coeffs_.b0 - current_coeffs_.b0);
        current_coeffs_.b1 += smoothing_factor * (target_coeffs_.b1 - current_coeffs_.b1);
        current_coeffs_.b2 += smoothing_factor * (target_coeffs_.b2 - current_coeffs_.b2);
        current_coeffs_.a1 += smoothing_factor * (target_coeffs_.a1 - current_coeffs_.a1);
        current_coeffs_.a2 += smoothing_factor * (target_coeffs_.a2 - current_coeffs_.a2);

        for (size_t i = 0; i < frames; ++i) {
            const size_t idx = i * 2;
            buffer[idx]     = process_sample(buffer[idx], 0);     // Left
            buffer[idx + 1] = process_sample(buffer[idx + 1], 1); // Right
        }
    }

    void reset() noexcept {
        for (auto& s : state_) {
            s.w1 = 0.0f;
            s.w2 = 0.0f;
        }
    }

    [[nodiscard]] const BiquadCoefficients& get_coefficients() const noexcept {
        return current_coeffs_;
    }

    [[nodiscard]] float get_cutoff() const noexcept { return current_cutoff_; }
    [[nodiscard]] float get_q() const noexcept { return current_q_; }

private:
    struct StateDF2T {
        float w1{0.0f};
        float w2{0.0f};
    };

    float sample_rate_{48000.0f};
    float current_cutoff_{950.0f};
    float current_q_{0.70710678f};

    BiquadCoefficients current_coeffs_;
    BiquadCoefficients target_coeffs_;

    // Dual channel state (0: Left, 1: Right)
    StateDF2T state_[2]{};
};

} // namespace neuro_dsp
