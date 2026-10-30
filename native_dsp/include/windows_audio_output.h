#pragma once

#ifdef _WIN32
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#include <windows.h>
#include <mmsystem.h>
#include <mmdeviceapi.h>
#include <audioclient.h>

#pragma comment(lib, "winmm.lib")
#pragma comment(lib, "ole32.lib")

#include <thread>
#include <atomic>
#include <vector>
#include <cmath>
#include <cstring>
#include <algorithm>
#include "dsp_engine.h"
#include "lockfree_ring_buffer.h"

namespace neuro_dsp {

enum HostAudioSourceMode : int32_t {
    SOURCE_WASAPI_LOOPBACK_SMART    = 0, // Real-time WASAPI System Loopback + Smart Sidechain Overlay (No Feedback)
    SOURCE_WASAPI_LOOPBACK_FULL_WET = 1, // Real-time WASAPI System Loopback + Full 432 Hz / DF2T Wet Pipeline
    SOURCE_AMBIENT_CHORD            = 2, // Internal 440 Hz Harmonic Pad (Test 432 Hz Vocoder & LPF)
    SOURCE_PINK_NOISE               = 3, // Internal Pink Noise Bed (Test Delta DF2T Filter Sweep)
};

class WindowsAudioOutput {
public:
    static constexpr size_t BUFFER_FRAMES = 512;
    static constexpr size_t NUM_BUFFERS = 4;
    static constexpr int32_t SAMPLE_RATE = 48000;

    explicit WindowsAudioOutput(DspEngine* dsp_engine) noexcept
        : dsp_engine_(dsp_engine), is_running_(false), h_wave_out_(nullptr) {}

    ~WindowsAudioOutput() {
        stop();
    }

    bool start() {
        if (is_running_.load()) return true;
        if (!dsp_engine_) return false;

        // Configure 16-bit stereo PCM at 48000 Hz for universal hardware compatibility
        WAVEFORMATEX wfx{};
        wfx.wFormatTag = WAVE_FORMAT_PCM;
        wfx.nChannels = 2;
        wfx.nSamplesPerSec = SAMPLE_RATE;
        wfx.wBitsPerSample = 16;
        wfx.nBlockAlign = (wfx.nChannels * wfx.wBitsPerSample) / 8; // 4 bytes
        wfx.nAvgBytesPerSec = wfx.nSamplesPerSec * wfx.nBlockAlign;
        wfx.cbSize = 0;

        h_event_ = CreateEvent(nullptr, FALSE, FALSE, nullptr);
        if (!h_event_) return false;

        MMRESULT res = waveOutOpen(&h_wave_out_, WAVE_MAPPER, &wfx,
                                  reinterpret_cast<DWORD_PTR>(h_event_), 0, CALLBACK_EVENT);
        if (res != MMSYSERR_NOERROR) {
            CloseHandle(h_event_);
            h_event_ = nullptr;
            return false;
        }

        // Allocate headers and PCM buffers
        for (size_t i = 0; i < NUM_BUFFERS; ++i) {
            pcm_buffers_[i].resize(BUFFER_FRAMES * 2);
            ZeroMemory(&wave_headers_[i], sizeof(WAVEHDR));
            wave_headers_[i].lpData = reinterpret_cast<LPSTR>(pcm_buffers_[i].data());
            wave_headers_[i].dwBufferLength = static_cast<DWORD>(BUFFER_FRAMES * 2 * sizeof(short));
            wave_headers_[i].dwFlags = 0;
            waveOutPrepareHeader(h_wave_out_, &wave_headers_[i], sizeof(WAVEHDR));
        }

        loopback_fifo_.reset();
        is_running_.store(true);

        // Start WASAPI Loopback Capture Thread and Hardware Render Thread
        capture_thread_ = std::thread(&WindowsAudioOutput::wasapi_loopback_capture_loop, this);
        audio_thread_   = std::thread(&WindowsAudioOutput::audio_loop, this);

        return true;
    }

    void stop() {
        if (!is_running_.load()) return;
        is_running_.store(false);

        if (h_event_) {
            SetEvent(h_event_);
        }

        if (capture_thread_.joinable()) {
            capture_thread_.join();
        }

        if (audio_thread_.joinable()) {
            audio_thread_.join();
        }

        if (h_wave_out_) {
            waveOutReset(h_wave_out_);
            for (size_t i = 0; i < NUM_BUFFERS; ++i) {
                waveOutUnprepareHeader(h_wave_out_, &wave_headers_[i], sizeof(WAVEHDR));
            }
            waveOutClose(h_wave_out_);
            h_wave_out_ = nullptr;
        }

        if (h_event_) {
            CloseHandle(h_event_);
            h_event_ = nullptr;
        }

        rms_l_.store(0.0f);
        rms_r_.store(0.0f);
    }

    [[nodiscard]] bool is_running() const noexcept {
        return is_running_.load();
    }

    void set_source_mode(HostAudioSourceMode mode) noexcept {
        source_mode_.store(mode);
    }

    void get_telemetry(float& out_rms_l, float& out_rms_r, int64_t& out_frames) const noexcept {
        out_rms_l = rms_l_.load();
        out_rms_r = rms_r_.load();
        out_frames = total_frames_.load();
    }

private:
    /**
     * @brief Dedicated WASAPI Loopback Capture Thread.
     * Intercepts the Windows system audio mix (Spotify, YouTube, Browser) in real time
     * and pushes stereo float samples into the lock-free ring buffer.
     */
    void wasapi_loopback_capture_loop() {
        SetThreadPriority(GetCurrentThread(), THREAD_PRIORITY_HIGHEST);
        HRESULT hr_co = CoInitializeEx(nullptr, COINIT_MULTITHREADED);

        IMMDeviceEnumerator* p_enumerator = nullptr;
        IMMDevice* p_device = nullptr;
        IAudioClient* p_audio_client = nullptr;
        IAudioCaptureClient* p_capture_client = nullptr;
        WAVEFORMATEX* p_wfx = nullptr;

        HRESULT hr = CoCreateInstance(
            __uuidof(MMDeviceEnumerator), nullptr,
            CLSCTX_ALL, __uuidof(IMMDeviceEnumerator),
            reinterpret_cast<void**>(&p_enumerator));

        if (SUCCEEDED(hr) && p_enumerator) {
            hr = p_enumerator->GetDefaultAudioEndpoint(eRender, eConsole, &p_device);
        }
        if (SUCCEEDED(hr) && p_device) {
            hr = p_device->Activate(__uuidof(IAudioClient), CLSCTX_ALL, nullptr,
                                    reinterpret_cast<void**>(&p_audio_client));
        }
        if (SUCCEEDED(hr) && p_audio_client) {
            hr = p_audio_client->GetMixFormat(&p_wfx);
        }
        if (SUCCEEDED(hr) && p_wfx) {
            // Initialize shared loopback capture with 50ms buffer
            hr = p_audio_client->Initialize(
                AUDCLNT_SHAREMODE_SHARED,
                AUDCLNT_STREAMFLAGS_LOOPBACK,
                500000, // 50 ms in 100-ns units
                0,
                p_wfx,
                nullptr);
        }
        if (SUCCEEDED(hr) && p_audio_client) {
            hr = p_audio_client->GetService(__uuidof(IAudioCaptureClient),
                                             reinterpret_cast<void**>(&p_capture_client));
        }
        if (SUCCEEDED(hr) && p_audio_client) {
            hr = p_audio_client->Start();
        }

        if (SUCCEEDED(hr) && p_capture_client && p_wfx) {
            const uint16_t channels = p_wfx->nChannels;
            const uint16_t bits = p_wfx->wBitsPerSample;

            while (is_running_.load()) {
                UINT32 packet_length = 0;
                hr = p_capture_client->GetNextPacketSize(&packet_length);
                if (FAILED(hr)) break;

                if (packet_length == 0) {
                    Sleep(2);
                    continue;
                }

                while (packet_length != 0 && is_running_.load()) {
                    BYTE* p_data = nullptr;
                    UINT32 num_frames_available = 0;
                    DWORD flags = 0;

                    hr = p_capture_client->GetBuffer(&p_data, &num_frames_available, &flags, nullptr, nullptr);
                    if (FAILED(hr)) break;

                    const bool is_silent = (flags & AUDCLNT_BUFFERFLAGS_SILENT) != 0 || p_data == nullptr;

                    for (UINT32 f = 0; f < num_frames_available; ++f) {
                        float left = 0.0f;
                        float right = 0.0f;

                        if (!is_silent) {
                            if (bits == 32) {
                                const auto* flt_data = reinterpret_cast<const float*>(p_data);
                                left  = flt_data[f * channels];
                                right = (channels > 1) ? flt_data[f * channels + 1] : left;
                            } else if (bits == 16) {
                                const auto* pcm_data = reinterpret_cast<const short*>(p_data);
                                left  = static_cast<float>(pcm_data[f * channels]) / 32768.0f;
                                right = (channels > 1) ? static_cast<float>(pcm_data[f * channels + 1]) / 32768.0f : left;
                            }
                        }

                        // Push stereo pair to lock-free ring buffer
                        loopback_fifo_.push(left);
                        loopback_fifo_.push(right);
                    }

                    p_capture_client->ReleaseBuffer(num_frames_available);
                    hr = p_capture_client->GetNextPacketSize(&packet_length);
                    if (FAILED(hr)) break;
                }
            }
            p_audio_client->Stop();
        }

        if (p_wfx) CoTaskMemFree(p_wfx);
        if (p_capture_client) p_capture_client->Release();
        if (p_audio_client) p_audio_client->Release();
        if (p_device) p_device->Release();
        if (p_enumerator) p_enumerator->Release();
        if (SUCCEEDED(hr_co)) CoUninitialize();
    }

    void audio_loop() {
        SetThreadPriority(GetCurrentThread(), THREAD_PRIORITY_TIME_CRITICAL);

        float host_buffer[BUFFER_FRAMES * 2];
        float out_buffer[BUFFER_FRAMES * 2];
        double synth_time = 0.0;
        constexpr double dt = 1.0 / static_cast<double>(SAMPLE_RATE);

        // Pre-fill and prime buffers
        for (size_t i = 0; i < NUM_BUFFERS; ++i) {
            std::memset(out_buffer, 0, sizeof(out_buffer));
            convert_and_copy(out_buffer, pcm_buffers_[i].data());
            waveOutWrite(h_wave_out_, &wave_headers_[i], sizeof(WAVEHDR));
        }

        while (is_running_.load()) {
            WaitForSingleObject(h_event_, 50);
            if (!is_running_.load()) break;

            for (size_t i = 0; i < NUM_BUFFERS; ++i) {
                if (wave_headers_[i].dwFlags & WHDR_DONE) {
                    const auto mode = source_mode_.load();

                    if (mode == SOURCE_WASAPI_LOOPBACK_SMART) {
                        // Pop captured system audio from WASAPI Loopback FIFO
                        pop_loopback_frames(host_buffer);
                        // Compute synchronized BWE + Ducked 528 Hz without echoing host audio
                        dsp_engine_->process_smart_overlay(host_buffer, out_buffer, BUFFER_FRAMES);

                        // Compute combined telemetry (Host Music + Neuroacoustic Layer)
                        update_telemetry(host_buffer, out_buffer);
                    } else if (mode == SOURCE_WASAPI_LOOPBACK_FULL_WET) {
                        pop_loopback_frames(out_buffer);
                        dsp_engine_->process(out_buffer, BUFFER_FRAMES);
                        update_telemetry_single(out_buffer);
                    } else {
                        // Internal calibration source (Ambient 440Hz Chord or Pink Noise)
                        fill_internal_source(out_buffer, synth_time, dt, mode);
                        dsp_engine_->process(out_buffer, BUFFER_FRAMES);
                        update_telemetry_single(out_buffer);
                    }

                    convert_and_copy(out_buffer, pcm_buffers_[i].data());
                    wave_headers_[i].dwFlags &= ~WHDR_DONE;
                    waveOutWrite(h_wave_out_, &wave_headers_[i], sizeof(WAVEHDR));
                }
            }
        }
    }

    void pop_loopback_frames(float* dst_stereo) noexcept {
        for (size_t i = 0; i < BUFFER_FRAMES; ++i) {
            float l = 0.0f;
            float r = 0.0f;
            if (!loopback_fifo_.pop(l)) l = 0.0f;
            if (!loopback_fifo_.pop(r)) r = 0.0f;
            dst_stereo[i * 2]     = l;
            dst_stereo[i * 2 + 1] = r;
        }
    }

    void update_telemetry(const float* host, const float* overlay) noexcept {
        float sum_sq_l = 0.0f;
        float sum_sq_r = 0.0f;
        for (size_t f = 0; f < BUFFER_FRAMES; ++f) {
            const float l = host[f * 2] + overlay[f * 2];
            const float r = host[f * 2 + 1] + overlay[f * 2 + 1];
            sum_sq_l += l * l;
            sum_sq_r += r * r;
        }
        rms_l_.store(std::sqrt(sum_sq_l / BUFFER_FRAMES));
        rms_r_.store(std::sqrt(sum_sq_r / BUFFER_FRAMES));
        total_frames_.fetch_add(BUFFER_FRAMES);
    }

    void update_telemetry_single(const float* buf) noexcept {
        float sum_sq_l = 0.0f;
        float sum_sq_r = 0.0f;
        for (size_t f = 0; f < BUFFER_FRAMES; ++f) {
            const float l = buf[f * 2];
            const float r = buf[f * 2 + 1];
            sum_sq_l += l * l;
            sum_sq_r += r * r;
        }
        rms_l_.store(std::sqrt(sum_sq_l / BUFFER_FRAMES));
        rms_r_.store(std::sqrt(sum_sq_r / BUFFER_FRAMES));
        total_frames_.fetch_add(BUFFER_FRAMES);
    }

    static void fill_internal_source(float* buffer, double& synth_time, double dt, HostAudioSourceMode mode) noexcept {
        constexpr double kTwoPi = 6.28318530717958647692;

        for (size_t i = 0; i < BUFFER_FRAMES; ++i) {
            float left = 0.0f;
            float right = 0.0f;

            if (mode == SOURCE_AMBIENT_CHORD) {
                // A4 (440 Hz) + C#5 (554.37 Hz) + E5 (659.25 Hz) harmonic ambient pad
                const double s1 = std::sin(kTwoPi * 440.0 * synth_time);
                const double s2 = std::sin(kTwoPi * 554.37 * synth_time);
                const double s3 = std::sin(kTwoPi * 659.25 * synth_time);
                const float chord = static_cast<float>((s1 * 0.4 + s2 * 0.3 + s3 * 0.3) * 0.35);
                left = chord;
                right = chord;
            } else if (mode == SOURCE_PINK_NOISE) {
                const float white = (static_cast<float>(rand()) / static_cast<float>(RAND_MAX) * 2.0f - 1.0f) * 0.25f;
                left = white;
                right = white;
            }

            buffer[i * 2]     = left;
            buffer[i * 2 + 1] = right;
            synth_time += dt;
        }

        if (synth_time > 1000.0) {
            synth_time = std::fmod(synth_time, 1.0);
        }
    }

    static void convert_and_copy(const float* src, short* dst) noexcept {
        for (size_t i = 0; i < BUFFER_FRAMES * 2; ++i) {
            const float sample = std::clamp(src[i], -1.0f, 1.0f);
            dst[i] = static_cast<short>(sample * 32767.0f);
        }
    }

    DspEngine* dsp_engine_;
    std::atomic<bool> is_running_{false};
    std::atomic<HostAudioSourceMode> source_mode_{SOURCE_WASAPI_LOOPBACK_SMART};

    std::atomic<float> rms_l_{0.0f};
    std::atomic<float> rms_r_{0.0f};
    std::atomic<int64_t> total_frames_{0};

    // Lock-free circular buffer for WASAPI Loopback samples (power of 2 capacity: 32768 floats)
    LockFreeRingBuffer<float, 32768> loopback_fifo_{};

    HWAVEOUT h_wave_out_{nullptr};
    HANDLE h_event_{nullptr};
    WAVEHDR wave_headers_[NUM_BUFFERS]{};
    std::vector<short> pcm_buffers_[NUM_BUFFERS];
    std::thread capture_thread_;
    std::thread audio_thread_;
};

} // namespace neuro_dsp
#endif // _WIN32
