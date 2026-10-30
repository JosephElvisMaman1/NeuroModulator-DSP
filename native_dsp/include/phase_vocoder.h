#pragma once

#include <cmath>
#include <cstddef>
#include <vector>
#include <array>
#include <algorithm>

/**
 * @file phase_vocoder.h
 * @brief Real-Time Phase Vocoder Pitch Shifter without Tempo Alteration.
 *
 * Implements Short-Time Fourier Transform (STFT) phase unwrapping and instantaneous frequency
 * synthesis to downshift harmonic spectra to 432.0 Hz (-1.818% ratio: 432/440)
 * while preserving rhythm and tempo perfectly.
 * 
 * Optimized for Ultra-Low Latency:
 * - FFT_SIZE: 512 samples (~10.66 ms at 48 kHz) for lip-sync and real-time streaming.
 * - HOP_SIZE: 128 samples (75% overlap) for smooth phase continuity.
 * - Pre-allocated static arrays ensuring ZERO dynamic memory allocation on the audio thread.
 */

namespace neuro_dsp {

class PhaseVocoderPitchShifter {
public:
    static constexpr size_t FFT_SIZE = 512;
    static constexpr size_t HALF_FFT = FFT_SIZE / 2; // 256
    static constexpr size_t HOP_SIZE = 128;          // 75% overlap for artifact-free phase reconstruction

    PhaseVocoderPitchShifter() noexcept;

    void init(float sample_rate) noexcept;
    void set_pitch_ratio(float ratio) noexcept; // Default: 432.0f / 440.0f = 0.981818f
    void set_enabled(bool enabled) noexcept { enabled_ = enabled; }
    [[nodiscard]] bool is_enabled() const noexcept { return enabled_; }

    /**
     * @brief Processes an interleaved stereo buffer in-place.
     * @param buffer Interleaved stereo float array [L, R, L, R, ...].
     * @param frames Number of frames to process.
     */
    void process_interleaved(float* buffer, size_t frames) noexcept;

    void reset() noexcept;

private:
    void process_channel(const float* in_channel, float* out_channel, size_t frames, size_t channel_idx) noexcept;
    void process_stft_frame(size_t channel_idx) noexcept;
    static void fft_radix2(float* real, float* imag, size_t n, bool inverse) noexcept;

    static constexpr float kPi = 3.14159265358979323846f;
    static constexpr float kTwoPi = 6.28318530717958647692f;

    float sample_rate_{48000.0f};
    float pitch_ratio_{432.0f / 440.0f};
    bool enabled_{true};

    // Precomputed Hann analysis and synthesis windows
    std::array<float, FFT_SIZE> window_{};

    // Circular FIFO buffers for streaming processing per channel (0: Left, 1: Right)
    struct ChannelBuffer {
        std::array<float, FFT_SIZE * 2> in_fifo{};
        std::array<float, FFT_SIZE * 2> out_fifo{};
        size_t in_fifo_pos{0};
        size_t out_fifo_pos{0};

        std::array<float, FFT_SIZE> fft_real{};
        std::array<float, FFT_SIZE> fft_imag{};

        std::array<float, HALF_FFT + 1> prev_phase{};
        std::array<float, HALF_FFT + 1> synth_phase{};
        std::array<float, HALF_FFT + 1> true_freq{};
        std::array<float, HALF_FFT + 1> magn{};
    };

    std::array<ChannelBuffer, 2> channels_{};
};

} // namespace neuro_dsp
