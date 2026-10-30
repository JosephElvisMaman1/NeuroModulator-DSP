#include "phase_vocoder.h"
#include <cstring>
#include <cmath>

namespace neuro_dsp {

PhaseVocoderPitchShifter::PhaseVocoderPitchShifter() noexcept {
    // Generate Hann window with WOLA normalization
    for (size_t i = 0; i < FFT_SIZE; ++i) {
        window_[i] = 0.5f * (1.0f - std::cos(kTwoPi * static_cast<float>(i) / static_cast<float>(FFT_SIZE - 1)));
    }
    reset();
}

void PhaseVocoderPitchShifter::init(float sample_rate) noexcept {
    sample_rate_ = (sample_rate > 8000.0f) ? sample_rate : 48000.0f;
    reset();
}

void PhaseVocoderPitchShifter::set_pitch_ratio(float ratio) noexcept {
    pitch_ratio_ = std::clamp(ratio, 0.5f, 2.0f);
}

void PhaseVocoderPitchShifter::reset() noexcept {
    for (auto& ch : channels_) {
        ch.in_fifo.fill(0.0f);
        ch.out_fifo.fill(0.0f);
        ch.in_fifo_pos = 0;
        ch.out_fifo_pos = 0;
        ch.fft_real.fill(0.0f);
        ch.fft_imag.fill(0.0f);
        ch.prev_phase.fill(0.0f);
        ch.synth_phase.fill(0.0f);
        ch.true_freq.fill(0.0f);
        ch.magn.fill(0.0f);
    }
}

void PhaseVocoderPitchShifter::fft_radix2(float* real, float* imag, size_t n, bool inverse) noexcept {
    // In-place Radix-2 Decimation-in-Time FFT
    size_t j = 0;
    for (size_t i = 0; i < n - 1; ++i) {
        if (i < j) {
            std::swap(real[i], real[j]);
            std::swap(imag[i], imag[j]);
        }
        size_t k = n >> 1;
        while (k <= j) {
            j -= k;
            k >>= 1;
        }
        j += k;
    }

    const float sign = inverse ? 1.0f : -1.0f;
    for (size_t len = 2; len <= n; len <<= 1) {
        const float angle = sign * kTwoPi / static_cast<float>(len);
        const float wlen_r = std::cos(angle);
        const float wlen_i = std::sin(angle);

        for (size_t i = 0; i < n; i += len) {
            float w_r = 1.0f;
            float w_i = 0.0f;
            const size_t half_len = len >> 1;
            for (size_t m = 0; m < half_len; ++m) {
                const size_t u_idx = i + m;
                const size_t v_idx = i + m + half_len;

                const float u_r = real[u_idx];
                const float u_i = imag[u_idx];
                const float v_r = real[v_idx] * w_r - imag[v_idx] * w_i;
                const float v_i = real[v_idx] * w_i + imag[v_idx] * w_r;

                real[u_idx] = u_r + v_r;
                imag[u_idx] = u_i + v_i;
                real[v_idx] = u_r - v_r;
                imag[v_idx] = u_i - v_i;

                const float next_w_r = w_r * wlen_r - w_i * wlen_i;
                w_i = w_r * wlen_i + w_i * wlen_r;
                w_r = next_w_r;
            }
        }
    }

    if (inverse) {
        const float inv_n = 1.0f / static_cast<float>(n);
        for (size_t i = 0; i < n; ++i) {
            real[i] *= inv_n;
            imag[i] *= inv_n;
        }
    }
}

void PhaseVocoderPitchShifter::process_stft_frame(size_t channel_idx) noexcept {
    auto& ch = channels_[channel_idx];
    const float expected_phase_advance = kTwoPi * static_cast<float>(HOP_SIZE) / static_cast<float>(FFT_SIZE);
    const float freq_per_bin = sample_rate_ / static_cast<float>(FFT_SIZE);

    // 1. Windowing & FFT
    for (size_t k = 0; k < FFT_SIZE; ++k) {
        const size_t buf_idx = (ch.in_fifo_pos + k) % (FFT_SIZE * 2);
        ch.fft_real[k] = ch.in_fifo[buf_idx] * window_[k];
        ch.fft_imag[k] = 0.0f;
    }

    fft_radix2(ch.fft_real.data(), ch.fft_imag.data(), FFT_SIZE, false);

    // 2. Analysis: Magnitude & True Instantaneous Frequency Calculation
    for (size_t k = 0; k <= HALF_FFT; ++k) {
        const float r = ch.fft_real[k];
        const float im = ch.fft_imag[k];
        const float mag = 2.0f * std::sqrt(r * r + im * im);
        const float phase = std::atan2(im, r);

        // Phase difference and unwrapping
        float phase_diff = phase - ch.prev_phase[k];
        ch.prev_phase[k] = phase;

        phase_diff -= static_cast<float>(k) * expected_phase_advance;

        // Wrap to [-pi, pi]
        long qpd = static_cast<long>(phase_diff / kPi);
        if (qpd >= 0) qpd += qpd & 1;
        else qpd -= qpd & 1;
        phase_diff -= kPi * static_cast<float>(qpd);

        // True frequency calculation
        const float bin_offset = phase_diff / expected_phase_advance;
        ch.true_freq[k] = (static_cast<float>(k) + bin_offset) * freq_per_bin;
        ch.magn[k] = mag;
    }

    // 3. Pitch shifting synthesis bins
    std::array<float, HALF_FFT + 1> syn_magn{};
    std::array<float, HALF_FFT + 1> syn_freq{};

    for (size_t k = 0; k <= HALF_FFT; ++k) {
        const auto new_bin = static_cast<size_t>(std::round(static_cast<float>(k) * pitch_ratio_));
        if (new_bin <= HALF_FFT) {
            syn_magn[new_bin] += ch.magn[k];
            syn_freq[new_bin]  = ch.true_freq[k] * pitch_ratio_;
        }
    }

    // 4. Phase accumulation & Complex spectrum reconstitution
    ch.fft_real.fill(0.0f);
    ch.fft_imag.fill(0.0f);

    for (size_t k = 0; k <= HALF_FFT; ++k) {
        const float mag = syn_magn[k];
        const float freq = syn_freq[k];

        // Synthesize phase
        const float phase_delta = kTwoPi * freq * static_cast<float>(HOP_SIZE) / sample_rate_;
        ch.synth_phase[k] += phase_delta;
        if (ch.synth_phase[k] >= kPi)  ch.synth_phase[k] -= kTwoPi;
        if (ch.synth_phase[k] < -kPi) ch.synth_phase[k] += kTwoPi;

        const float syn_phase = ch.synth_phase[k];
        ch.fft_real[k] = mag * std::cos(syn_phase);
        ch.fft_imag[k] = mag * std::sin(syn_phase);

        // Conjugate symmetry for real IFFT
        if (k > 0 && k < HALF_FFT) {
            ch.fft_real[FFT_SIZE - k] = ch.fft_real[k];
            ch.fft_imag[FFT_SIZE - k] = -ch.fft_imag[k];
        }
    }

    // 5. IFFT & Windowing
    fft_radix2(ch.fft_real.data(), ch.fft_imag.data(), FFT_SIZE, true);

    // 6. Overlap-Add into output FIFO
    for (size_t k = 0; k < FFT_SIZE; ++k) {
        const size_t out_idx = (ch.out_fifo_pos + k) % (FFT_SIZE * 2);
        ch.out_fifo[out_idx] += ch.fft_real[k] * window_[k] * (2.0f / 3.0f); // Window overlap scaling
    }

    ch.in_fifo_pos = (ch.in_fifo_pos + HOP_SIZE) % (FFT_SIZE * 2);
    ch.out_fifo_pos = (ch.out_fifo_pos + HOP_SIZE) % (FFT_SIZE * 2);
}

void PhaseVocoderPitchShifter::process_interleaved(float* buffer, size_t frames) noexcept {
    if (!enabled_ || !buffer || frames == 0) return;

    for (size_t i = 0; i < frames; ++i) {
        const size_t idx = i * 2;
        // Process each channel via streaming fifo
        for (size_t ch = 0; ch < 2; ++ch) {
            auto& c = channels_[ch];
            const size_t in_write = (c.in_fifo_pos + FFT_SIZE) % (FFT_SIZE * 2);
            c.in_fifo[in_write] = buffer[idx + ch];

            // Read from output overlap-add buffer
            const size_t out_read = c.out_fifo_pos % (FFT_SIZE * 2);
            buffer[idx + ch] = c.out_fifo[out_read];
            c.out_fifo[out_read] = 0.0f; // Clear after consume
        }

        // Trigger STFT frame processing at hop intervals
        if ((i % HOP_SIZE) == 0) {
            process_stft_frame(0);
            process_stft_frame(1);
        }
    }
}

} // namespace neuro_dsp
