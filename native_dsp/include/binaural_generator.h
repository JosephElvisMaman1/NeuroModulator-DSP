#pragma once

#include <cmath>
#include <cstddef>
#include <algorithm>

/**
 * @file binaural_generator.h
 * @brief Dichotic Binaural Beat Generator for Alpha (8 - 12 Hz) Brainwave Entrainment.
 *
 * Synthesizes two coherent pure sine waves with differential frequencies across left and right
 * audio channels. The human superior olivary complex perceives the beat frequency:
 *   f_beat = |f_right - f_left|
 * Uses smooth gain ramping to prevent audible discontinuities on parameter changes.
 */

namespace neuro_dsp {

class BinauralGenerator {
public:
    BinauralGenerator() noexcept = default;

    void init(float sample_rate) noexcept {
        sample_rate_ = (sample_rate > 8000.0f) ? sample_rate : 48000.0f;
        reset();
        update_phase_increments();
    }

    void set_parameters(float carrier_freq_hz, float beat_freq_hz, float gain_db) noexcept {
        // Clamp carrier to warm auditory range (200 - 400 Hz)
        carrier_freq_ = std::clamp(carrier_freq_hz, 100.0f, 600.0f);
        // Alpha spectrum range: 8 - 12 Hz
        beat_freq_ = std::clamp(beat_freq_hz, 0.5f, 30.0f);
        target_gain_linear_ = std::pow(10.0f, gain_db / 20.0f);
        update_phase_increments();
    }

    /**
     * @brief Mixes dichotic binaural tones additively into an interleaved stereo buffer.
     * @param buffer Interleaved stereo float array [L, R, L, R, ...].
     * @param frames Number of frames to process.
     */
    void process_add_interleaved(float* buffer, size_t frames) noexcept {
        if (!buffer || frames == 0) return;

        constexpr float kSmoothing = 0.005f;

        for (size_t i = 0; i < frames; ++i) {
            // Smooth gain towards target
            current_gain_linear_ += kSmoothing * (target_gain_linear_ - current_gain_linear_);

            const float sample_left  = current_gain_linear_ * std::sin(phase_left_);
            const float sample_right = current_gain_linear_ * std::sin(phase_right_);

            const size_t idx = i * 2;
            buffer[idx]     += sample_left;
            buffer[idx + 1] += sample_right;

            // Increment and wrap phases [0, 2*pi)
            phase_left_  += phase_inc_left_;
            phase_right_ += phase_inc_right_;

            if (phase_left_ >= kTwoPi)  phase_left_  -= kTwoPi;
            if (phase_right_ >= kTwoPi) phase_right_ -= kTwoPi;
        }
    }

    void reset() noexcept {
        phase_left_ = 0.0f;
        phase_right_ = 0.0f;
        current_gain_linear_ = 0.0f;
    }

private:
    void update_phase_increments() noexcept {
        const float f_left  = carrier_freq_ - (beat_freq_ * 0.5f);
        const float f_right = carrier_freq_ + (beat_freq_ * 0.5f);

        phase_inc_left_  = (kTwoPi * f_left) / sample_rate_;
        phase_inc_right_ = (kTwoPi * f_right) / sample_rate_;
    }

    static constexpr float kTwoPi = 6.28318530717958647692f;

    float sample_rate_{48000.0f};
    float carrier_freq_{250.0f}; // Warm carrier (200 - 400 Hz)
    float beat_freq_{10.0f};     // 10 Hz Alpha
    float current_gain_linear_{0.0f};
    float target_gain_linear_{0.125f}; // ~ -18 dB

    float phase_left_{0.0f};
    float phase_right_{0.0f};
    float phase_inc_left_{0.0f};
    float phase_inc_right_{0.0f};
};

} // namespace neuro_dsp
