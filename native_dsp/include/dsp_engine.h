#pragma once

#include "biquad_filter.h"
#include "binaural_generator.h"
#include "isochronic_generator.h"
#include "solfeggio_synthesizer.h"
#include "phase_vocoder.h"
#include "lockfree_ring_buffer.h"

#include <memory>
#include <atomic>

/**
 * @file dsp_engine.h
 * @brief Master Real-Time Neuroacoustic DSP Engine.
 *
 * Coordinates real-time audio pipeline:
 * 1. Pitch Shifter (432 Hz vocoder)
 * 2. Transposed Direct Form II Biquad LPF (Delta sleep mode)
 * 3. Additive Neuroacoustic Generators (Alpha binaural, Gamma 40Hz isochronic, 528Hz Solfeggio ducked)
 * 4. Transparent Soft-Knee Safety Peak Limiter (0 dBFS ceiling)
 */

namespace neuro_dsp {

class DspEngine {
public:
    DspEngine() noexcept;
    ~DspEngine() = default;

    void init(float sample_rate) noexcept;

    /**
     * @brief Real-time in-place audio processing callback (Full Wet Pass-Through).
     * Guaranteed ZERO dynamic memory allocations, ZERO mutexes, ZERO blocking syscalls.
     *
     * @param buffer Interleaved stereo float array [L, R, L, R, ...].
     * @param frames Number of stereo frames.
     */
    void process(float* buffer, size_t frames) noexcept;

    /**
     * @brief Smart Overlay Processing for WASAPI Loopback on shared single-endpoint systems.
     * Reads the captured host stream (Spotify/YouTube) for real-time RMS sidechain ducking
     * and outputs the synchronized neuroacoustic entrainment layer without feedback loops.
     *
     * @param captured_host Interleaved stereo host audio captured via WASAPI Loopback.
     * @param out_overlay Output stereo buffer containing the modulated neuroacoustic layer.
     * @param frames Number of stereo frames.
     */
    void process_smart_overlay(const float* captured_host, float* out_overlay, size_t frames) noexcept;

    /**
     * @brief Updates parameters asynchronously from UI/Dart thread via atomic snapshot.
     */
    void update_parameters(const DspParameterBlock& params) noexcept;

    /**
     * @brief Atomically gets current parameter snapshot.
     */
    [[nodiscard]] DspParameterBlock get_parameters() const noexcept;

    void reset() noexcept;

private:
    void sync_dirty_parameters() noexcept;
    void apply_soft_limiter(float* buffer, size_t frames) noexcept;

    float sample_rate_{48000.0f};

    // DSP Processing Modules
    PhaseVocoderPitchShifter pitch_shifter_;
    BiquadFilterDF2T         delta_lpf_;
    BinauralGenerator        alpha_binaural_;
    IsochronicGenerator      gamma_isochronic_;
    SolfeggioSynthesizer     solfeggio_synth_;

    // Lock-Free parameter synchronizer
    std::atomic<bool> params_dirty_{false};
    alignas(CACHE_LINE_SIZE) DspParameterBlock active_params_{};
    alignas(CACHE_LINE_SIZE) DspParameterBlock staged_params_{};
};

} // namespace neuro_dsp
