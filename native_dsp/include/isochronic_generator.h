#pragma once

#include <cmath>
#include <cstddef>
#include <algorithm>

/**
 * @file isochronic_generator.h
 * @brief High-Precision Isochronic Pulse Generator for Gamma (40.0 Hz) ASSR Entrainment.
 *
 * Implements smooth amplitude modulation (raised-cosine windowed pulses) on a carrier frequency
 * to stimulate Auditory Steady-State Responses (ASSR) at 40 Hz without causing audible clicks
 * or high-frequency spectral spray.
 */

namespace neuro_dsp {

class IsochronicGenerator {
public:
    IsochronicGenerator() noexcept = default;

    void init(float sample_rate) noexcept {
        sample_rate_ = (sample_rate > 8000.0f) ? sample_rate : 48000.0f;
        reset();
        update_parameters();
    }

    void set_parameters(float carrier_freq_hz, float pulse_freq_hz, float gain_db) noexcept {
        carrier_freq_ = std::clamp(carrier_freq_hz, 100.0f, 800.0f);
        pulse_freq_ = std::clamp(pulse_freq_hz, 1.0f, 100.0f); // Centered at 40.0 Hz
        target_gain_linear_ = std::pow(10.0f, gain_db / 20.0f);
        update_parameters();
    }

    /**
     * @brief Mixes isochronic pulses additively into an interleaved stereo buffer.
     * @param buffer Interleaved stereo float array [L, R, L, R, ...].
     * @param frames Number of audio frames.
     */
    void process_add_interleaved(float* buffer, size_t frames) noexcept {
        if (!buffer || frames == 0) return;

        constexpr float kSmoothing = 0.005f;

        for (size_t i = 0; i < frames; ++i) {
            current_gain_linear_ += kSmoothing * (target_gain_linear_ - current_gain_linear_);

            // Carrier synthesis
            const float carrier = std::sin(carrier_phase_);

            // Envelope modulation: smooth raised cosine pulse (duty cycle 50%)
            // Prevents high-frequency harmonic transient clicks
            float envelope = 0.0f;
            if (pulse_phase_ < 0.5f) {
                // Active pulse window: raised cosine over [0, 0.5]
                envelope = 0.5f * (1.0f - std::cos(kTwoPi * (pulse_phase_ / 0.5f)));
            } else {
                envelope = 0.0f; // Silence gap in duty cycle
            }

            const float sample = current_gain_linear_ * carrier * envelope;

            const size_t idx = i * 2;
            buffer[idx]     += sample; // Left
            buffer[idx + 1] += sample; // Right

            // Phase updates
            carrier_phase_ += carrier_phase_inc_;
            if (carrier_phase_ >= kTwoPi) carrier_phase_ -= kTwoPi;

            pulse_phase_ += pulse_phase_inc_;
            if (pulse_phase_ >= 1.0f) pulse_phase_ -= 1.0f;
        }
    }

    void reset() noexcept {
        carrier_phase_ = 0.0f;
        pulse_phase_ = 0.0f;
        current_gain_linear_ = 0.0f;
    }

private:
    void update_parameters() noexcept {
        carrier_phase_inc_ = (kTwoPi * carrier_freq_) / sample_rate_;
        pulse_phase_inc_   = pulse_freq_ / sample_rate_;
    }

    static constexpr float kTwoPi = 6.28318530717958647692f;

    float sample_rate_{48000.0f};
    float carrier_freq_{216.0f};
    float pulse_freq_{40.0f}; // Exactly 40 Hz
    float current_gain_linear_{0.0f};
    float target_gain_linear_{0.177f}; // ~ -15 dB

    float carrier_phase_{0.0f};
    float carrier_phase_inc_{0.0f};
    float pulse_phase_{0.0f};
    float pulse_phase_inc_{0.0f};
};

} // namespace neuro_dsp
