#pragma once

#include <stdint.h>
#include <stdbool.h>

#if defined(_WIN32)
    #define FFI_EXPORT __declspec(dllexport)
#else
    #define FFI_EXPORT __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief C ABI Compatible Parameter Struct for Zero-Copy Dart FFI Binding.
 */
typedef struct {
    // 432 Hz Pitch Shift
    int32_t pitch_shift_enabled;
    float   pitch_shift_ratio;

    // Delta Filter (DF2T Biquad LPF)
    int32_t delta_lpf_enabled;
    float   delta_lpf_cutoff;
    float   delta_lpf_q;

    // Alpha Binaural Beat (8 - 12 Hz)
    int32_t alpha_binaural_enabled;
    float   alpha_carrier_freq;
    float   alpha_beat_freq;
    float   alpha_gain_db;

    // Gamma Isochronic Pulses (40 Hz)
    int32_t gamma_isochronic_enabled;
    float   gamma_carrier_freq;
    float   gamma_pulse_freq;
    float   gamma_gain_db;

    // Solfeggio 528 Hz Synthesizer + Ducking
    int32_t solfeggio_enabled;
    float   solfeggio_freq;
    float   solfeggio_ducking_threshold_db;
    float   solfeggio_gain_db;

    // Master bus
    float   master_gain;
    int32_t limiter_enabled;
} CDspParameters;

typedef void* DspEngineHandle;

FFI_EXPORT DspEngineHandle dsp_engine_create(void);
FFI_EXPORT void            dsp_engine_destroy(DspEngineHandle handle);
FFI_EXPORT void            dsp_engine_init(DspEngineHandle handle, float sample_rate);
FFI_EXPORT void            dsp_engine_reset(DspEngineHandle handle);
FFI_EXPORT void            dsp_engine_process_interleaved(DspEngineHandle handle, float* buffer, int32_t frames);
FFI_EXPORT void            dsp_engine_set_parameters(DspEngineHandle handle, const CDspParameters* params);
FFI_EXPORT void            dsp_engine_get_parameters(DspEngineHandle handle, CDspParameters* out_params);

// Live Hardware Audio Playback & Telemetry (Windows & Desktop)
FFI_EXPORT int32_t         dsp_engine_start_live_audio(DspEngineHandle handle);
FFI_EXPORT void            dsp_engine_stop_live_audio(DspEngineHandle handle);
FFI_EXPORT int32_t         dsp_engine_is_live_audio_running(DspEngineHandle handle);
FFI_EXPORT void            dsp_engine_set_live_source_mode(DspEngineHandle handle, int32_t mode);
FFI_EXPORT void            dsp_engine_get_telemetry(DspEngineHandle handle, float* out_rms_l, float* out_rms_r, int64_t* out_total_frames);

#ifdef __cplusplus
}
#endif
