#pragma once

#include <cmath>
#include <cstddef>
#include <algorithm>

/**
 * @file solfeggio_synthesizer.h
 * @brief Parametric 528.0 Hz Solfeggio Synthesizer with Dynamic Sidechain Gain Ducking.
 *
 * Tracks the RMS envelope of the host audio signal (Spotify/YouTube) and dynamically
 * modulates the 528 Hz tone to maintain it strictly beneath the conscious auditory threshold
 * (-18 dB to -24 dB relative to the host program material).
 * Features zero frequency drift and ultra-low Total Harmonic Distortion (THD).
 */

namespace neuro_dsp {

class SolfeggioSynthesizer {
public:
    SolfeggioSynthesizer() noexcept = default;

    void init(float sample_rate) noexcept {
        sample_rate_ = (sample_rate > 8000.0f) ? sample_rate : 48000.0f;
        reset();
        update_frequency();
        set_envelope_times(0.020f, 0.150f); // 20ms attack, 150ms release
    }

    void set_parameters(float freq_hz, float ducking_offset_db, float max_gain_db) noexcept {
        target_freq_ = (freq_hz > 10.0f && freq_hz < 2000.0f) ? freq_hz : 528.0f;
        ducking_offset_linear_ = std::pow(10.0f, ducking_offset_db / 20.0f); // e.g. -20 dB -> ~0.10
        max_gain_linear_       = std::pow(10.0f, max_gain_db / 20.0f);
        update_frequency();
    }

    /**
     * @brief Sets envelope follower attack and release time constants in seconds.
     */
    void set_envelope_times(float attack_sec, float release_sec) noexcept {
        attack_coeff_  = std::exp(-1.0f / (attack_sec * sample_rate_));
        release_coeff_ = std::exp(-1.0f / (release_sec * sample_rate_));
    }

    /**
     * @brief Computes dynamic ducking against an external sidechain host buffer and adds 528 Hz to out_buffer.
     * @param sidechain_host Interleaved stereo host audio (e.g., WASAPI Loopback from Spotify/YouTube).
     * @param out_buffer Interleaved stereo output buffer to inject the ducked 528 Hz wave.
     * @param frames Number of audio frames.
     */
    void process_sidechain_interleaved(const float* sidechain_host, float* out_buffer, size_t frames) noexcept {
        if (!sidechain_host || !out_buffer || frames == 0) return;

        for (size_t i = 0; i < frames; ++i) {
            const size_t idx = i * 2;
            const float left  = sidechain_host[idx];
            const float right = sidechain_host[idx + 1];

            // RMS power estimator on host signal
            const float host_power = 0.5f * (left * left + right * right);
            const float host_rms   = std::sqrt(host_power);

            // Asymmetric envelope follower (Attack vs Release)
            if (host_rms > env_follower_) {
                env_follower_ = attack_coeff_ * env_follower_ + (1.0f - attack_coeff_) * host_rms;
            } else {
                env_follower_ = release_coeff_ * env_follower_ + (1.0f - release_coeff_) * host_rms;
            }

            // Target ducked level: proportional to host RMS (with subtle baseline floor when in standalone mode)
            const float effective_env = std::max(env_follower_, 0.15f);
            const float target_ducked_gain = std::min(effective_env * ducking_offset_linear_, max_gain_linear_);

            // Smooth gain modulation
            constexpr float kGainSmooth = 0.002f;
            current_gain_ += kGainSmooth * (target_ducked_gain - current_gain_);

            // High-precision pure sine wave generation (528.0 Hz)
            const float tone = current_gain_ * std::sin(phase_);

            // Additive injection to both stereo channels
            out_buffer[idx]     += tone;
            out_buffer[idx + 1] += tone;

            // Increment phase
            phase_ += phase_inc_;
            if (phase_ >= kTwoPi) phase_ -= kTwoPi;
        }
    }

    /**
     * @brief Computes dynamic ducking in-place against the host audio and synthesizes the 528 Hz tone.
     */
    void process_add_interleaved(float* buffer, size_t frames) noexcept {
        process_sidechain_interleaved(buffer, buffer, frames);
    }

    void reset() noexcept {
        phase_ = 0.0f;
        env_follower_ = 0.0f;
        current_gain_ = 0.0f;
    }

private:
    void update_frequency() noexcept {
        phase_inc_ = (kTwoPi * target_freq_) / sample_rate_;
    }

    static constexpr float kTwoPi = 6.28318530717958647692f;

    float sample_rate_{48000.0f};
    float target_freq_{528.0f}; // 528.0 Hz Solfeggio
    float ducking_offset_linear_{0.10f}; // ~ -20 dB below host
    float max_gain_linear_{0.125f};      // Max ceiling ~ -18 dB

    float attack_coeff_{0.99f};
    float release_coeff_{0.999f};
    float env_follower_{0.0f};
    float current_gain_{0.0f};

    float phase_{0.0f};
    float phase_inc_{0.0f};
};

} // namespace neuro_dsp
