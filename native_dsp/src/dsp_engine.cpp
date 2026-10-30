#include "dsp_engine.h"
#include <cmath>
#include <cstring>
#include <algorithm>

namespace neuro_dsp {

DspEngine::DspEngine() noexcept {
    init(48000.0f);
}

void DspEngine::init(float sample_rate) noexcept {
    sample_rate_ = (sample_rate > 8000.0f) ? sample_rate : 48000.0f;

    pitch_shifter_.init(sample_rate_);
    pitch_shifter_.set_pitch_ratio(432.0f / 440.0f);

    delta_lpf_.init(sample_rate_);
    delta_lpf_.calculate_coefficients(950.0f, 0.70710678f);

    alpha_binaural_.init(sample_rate_);
    alpha_binaural_.set_parameters(250.0f, 10.0f, -18.0f);

    gamma_isochronic_.init(sample_rate_);
    gamma_isochronic_.set_parameters(216.0f, 40.0f, -15.0f);

    solfeggio_synth_.init(sample_rate_);
    solfeggio_synth_.set_parameters(528.0f, -20.0f, -18.0f);

    reset();
}

void DspEngine::reset() noexcept {
    pitch_shifter_.reset();
    delta_lpf_.reset();
    alpha_binaural_.reset();
    gamma_isochronic_.reset();
    solfeggio_synth_.reset();
}

void DspEngine::update_parameters(const DspParameterBlock& params) noexcept {
    staged_params_ = params;
    params_dirty_.store(true, std::memory_order_release);
}

DspParameterBlock DspEngine::get_parameters() const noexcept {
    return active_params_;
}

void DspEngine::sync_dirty_parameters() noexcept {
    if (params_dirty_.load(std::memory_order_acquire)) {
        active_params_ = staged_params_;
        params_dirty_.store(false, std::memory_order_relaxed);

        // Apply configuration changes to DSP submodules
        pitch_shifter_.set_enabled(active_params_.pitch_shift_enabled);
        pitch_shifter_.set_pitch_ratio(active_params_.pitch_shift_ratio);

        if (active_params_.delta_lpf_enabled) {
            delta_lpf_.calculate_coefficients(active_params_.delta_lpf_cutoff, active_params_.delta_lpf_q);
        }

        if (active_params_.alpha_binaural_enabled) {
            alpha_binaural_.set_parameters(active_params_.alpha_carrier_freq,
                                           active_params_.alpha_beat_freq,
                                           active_params_.alpha_gain_db);
        }

        if (active_params_.gamma_isochronic_enabled) {
            gamma_isochronic_.set_parameters(active_params_.gamma_carrier_freq,
                                             active_params_.gamma_pulse_freq,
                                             active_params_.gamma_gain_db);
        }

        if (active_params_.solfeggio_enabled) {
            solfeggio_synth_.set_parameters(active_params_.solfeggio_freq,
                                            active_params_.solfeggio_ducking_threshold_db,
                                            active_params_.solfeggio_gain_db);
        }
    }
}

void DspEngine::apply_soft_limiter(float* buffer, size_t frames) noexcept {
    // Hyperbolic tangent soft saturation to eliminate harsh clipping at +/- 1.0f
    for (size_t i = 0; i < frames * 2; ++i) {
        const float val = buffer[i];
        if (val > 0.95f) {
            buffer[i] = 0.95f + 0.05f * std::tanh((val - 0.95f) / 0.05f);
        } else if (val < -0.95f) {
            buffer[i] = -0.95f + 0.05f * std::tanh((val + 0.95f) / 0.05f);
        }
    }
}

void DspEngine::process(float* buffer, size_t frames) noexcept {
    if (!buffer || frames == 0) return;

    // 1. Consume dirty parameters lock-free
    sync_dirty_parameters();

    // 2. Stage A: 432 Hz Pitch Shifting (Independent Phase Vocoder)
    if (active_params_.pitch_shift_enabled) {
        pitch_shifter_.process_interleaved(buffer, frames);
    }

    // 3. Stage B: Transposed Direct Form II Biquad Low-Pass Filter (Delta Mode)
    if (active_params_.delta_lpf_enabled) {
        delta_lpf_.process_interleaved(buffer, frames);
    }

    // 4. Stage C: Additive Synthesis Layer
    if (active_params_.alpha_binaural_enabled) {
        alpha_binaural_.process_add_interleaved(buffer, frames);
    }

    if (active_params_.gamma_isochronic_enabled) {
        gamma_isochronic_.process_add_interleaved(buffer, frames);
    }

    if (active_params_.solfeggio_enabled) {
        solfeggio_synth_.process_add_interleaved(buffer, frames);
    }

    // 5. Stage D: Master Gain & Soft-knee Peak Limiter
    if (std::abs(active_params_.master_gain - 1.0f) > 1e-4f) {
        const float mg = active_params_.master_gain;
        for (size_t i = 0; i < frames * 2; ++i) {
            buffer[i] *= mg;
        }
    }

    if (active_params_.limiter_enabled) {
        apply_soft_limiter(buffer, frames);
    }
}

void DspEngine::process_smart_overlay(const float* captured_host, float* out_overlay, size_t frames) noexcept {
    if (!captured_host || !out_overlay || frames == 0) return;

    sync_dirty_parameters();

    // Initialize overlay buffer to zero (prevents doubling the already-playing host stream on single endpoint)
    std::memset(out_overlay, 0, frames * 2 * sizeof(float));

    // Inject Alpha Binaural Beats (8 - 12 Hz)
    if (active_params_.alpha_binaural_enabled) {
        alpha_binaural_.process_add_interleaved(out_overlay, frames);
    }

    // Inject Gamma 40 Hz Isochronic Pulses (ASSR)
    if (active_params_.gamma_isochronic_enabled) {
        gamma_isochronic_.process_add_interleaved(out_overlay, frames);
    }

    // Inject 528 Hz Solfeggio dynamically ducked against the real-time captured WASAPI Loopback host RMS
    if (active_params_.solfeggio_enabled) {
        solfeggio_synth_.process_sidechain_interleaved(captured_host, out_overlay, frames);
    }

    // Master Gain & Soft Limiter
    if (std::abs(active_params_.master_gain - 1.0f) > 1e-4f) {
        const float mg = active_params_.master_gain;
        for (size_t i = 0; i < frames * 2; ++i) {
            out_overlay[i] *= mg;
        }
    }

    if (active_params_.limiter_enabled) {
        apply_soft_limiter(out_overlay, frames);
    }
}

} // namespace neuro_dsp
