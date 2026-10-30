#include "dsp_ffi_api.h"
#include "dsp_engine.h"

#ifdef _WIN32
#include "windows_audio_output.h"
#endif

using namespace neuro_dsp;

struct EngineContext {
    DspEngine dsp;
#ifdef _WIN32
    std::unique_ptr<WindowsAudioOutput> audio_out;
#endif

    EngineContext() {
#ifdef _WIN32
        audio_out = std::make_unique<WindowsAudioOutput>(&dsp);
#endif
    }
};

extern "C" {

FFI_EXPORT DspEngineHandle dsp_engine_create(void) {
    auto* ctx = new (std::nothrow) EngineContext();
    return static_cast<DspEngineHandle>(ctx);
}

FFI_EXPORT void dsp_engine_destroy(DspEngineHandle handle) {
    if (handle) {
        auto* ctx = static_cast<EngineContext*>(handle);
#ifdef _WIN32
        if (ctx->audio_out) {
            ctx->audio_out->stop();
        }
#endif
        delete ctx;
    }
}

FFI_EXPORT void dsp_engine_init(DspEngineHandle handle, float sample_rate) {
    if (handle) {
        auto* ctx = static_cast<EngineContext*>(handle);
        ctx->dsp.init(sample_rate);
    }
}

FFI_EXPORT void dsp_engine_reset(DspEngineHandle handle) {
    if (handle) {
        auto* ctx = static_cast<EngineContext*>(handle);
        ctx->dsp.reset();
    }
}

FFI_EXPORT void dsp_engine_process_interleaved(DspEngineHandle handle, float* buffer, int32_t frames) {
    if (handle && buffer && frames > 0) {
        auto* ctx = static_cast<EngineContext*>(handle);
        ctx->dsp.process(buffer, static_cast<size_t>(frames));
    }
}

FFI_EXPORT void dsp_engine_set_parameters(DspEngineHandle handle, const CDspParameters* params) {
    if (handle && params) {
        auto* ctx = static_cast<EngineContext*>(handle);
        DspParameterBlock p;
        p.pitch_shift_enabled          = (params->pitch_shift_enabled != 0);
        p.pitch_shift_ratio            = params->pitch_shift_ratio;

        p.delta_lpf_enabled            = (params->delta_lpf_enabled != 0);
        p.delta_lpf_cutoff             = params->delta_lpf_cutoff;
        p.delta_lpf_q                  = params->delta_lpf_q;

        p.alpha_binaural_enabled       = (params->alpha_binaural_enabled != 0);
        p.alpha_carrier_freq           = params->alpha_carrier_freq;
        p.alpha_beat_freq              = params->alpha_beat_freq;
        p.alpha_gain_db                = params->alpha_gain_db;

        p.gamma_isochronic_enabled     = (params->gamma_isochronic_enabled != 0);
        p.gamma_carrier_freq           = params->gamma_carrier_freq;
        p.gamma_pulse_freq             = params->gamma_pulse_freq;
        p.gamma_gain_db                = params->gamma_gain_db;

        p.solfeggio_enabled            = (params->solfeggio_enabled != 0);
        p.solfeggio_freq               = params->solfeggio_freq;
        p.solfeggio_ducking_threshold_db = params->solfeggio_ducking_threshold_db;
        p.solfeggio_gain_db            = params->solfeggio_gain_db;

        p.master_gain                  = params->master_gain;
        p.limiter_enabled              = (params->limiter_enabled != 0);

        ctx->dsp.update_parameters(p);
    }
}

FFI_EXPORT void dsp_engine_get_parameters(DspEngineHandle handle, CDspParameters* out_params) {
    if (handle && out_params) {
        auto* ctx = static_cast<EngineContext*>(handle);
        const auto p = ctx->dsp.get_parameters();

        out_params->pitch_shift_enabled          = p.pitch_shift_enabled ? 1 : 0;
        out_params->pitch_shift_ratio            = p.pitch_shift_ratio;

        out_params->delta_lpf_enabled            = p.delta_lpf_enabled ? 1 : 0;
        out_params->delta_lpf_cutoff             = p.delta_lpf_cutoff;
        out_params->delta_lpf_q                  = p.delta_lpf_q;

        out_params->alpha_binaural_enabled       = p.alpha_binaural_enabled ? 1 : 0;
        out_params->alpha_carrier_freq           = p.alpha_carrier_freq;
        out_params->alpha_beat_freq              = p.alpha_beat_freq;
        out_params->alpha_gain_db                = p.alpha_gain_db;

        out_params->gamma_isochronic_enabled     = p.gamma_isochronic_enabled ? 1 : 0;
        out_params->gamma_carrier_freq           = p.gamma_carrier_freq;
        out_params->gamma_pulse_freq             = p.gamma_pulse_freq;
        out_params->gamma_gain_db                = p.gamma_gain_db;

        out_params->solfeggio_enabled            = p.solfeggio_enabled ? 1 : 0;
        out_params->solfeggio_freq               = p.solfeggio_freq;
        out_params->solfeggio_ducking_threshold_db = p.solfeggio_ducking_threshold_db;
        out_params->solfeggio_gain_db            = p.solfeggio_gain_db;

        out_params->master_gain                  = p.master_gain;
        out_params->limiter_enabled              = p.limiter_enabled ? 1 : 0;
    }
}

FFI_EXPORT int32_t dsp_engine_start_live_audio(DspEngineHandle handle) {
#ifdef _WIN32
    if (handle) {
        auto* ctx = static_cast<EngineContext*>(handle);
        if (ctx->audio_out) {
            return ctx->audio_out->start() ? 1 : 0;
        }
    }
#endif
    return 0;
}

FFI_EXPORT void dsp_engine_stop_live_audio(DspEngineHandle handle) {
#ifdef _WIN32
    if (handle) {
        auto* ctx = static_cast<EngineContext*>(handle);
        if (ctx->audio_out) {
            ctx->audio_out->stop();
        }
    }
#endif
}

FFI_EXPORT int32_t dsp_engine_is_live_audio_running(DspEngineHandle handle) {
#ifdef _WIN32
    if (handle) {
        auto* ctx = static_cast<EngineContext*>(handle);
        if (ctx->audio_out) {
            return ctx->audio_out->is_running() ? 1 : 0;
        }
    }
#endif
    return 0;
}

FFI_EXPORT void dsp_engine_set_live_source_mode(DspEngineHandle handle, int32_t mode) {
#ifdef _WIN32
    if (handle) {
        auto* ctx = static_cast<EngineContext*>(handle);
        if (ctx->audio_out) {
            ctx->audio_out->set_source_mode(static_cast<HostAudioSourceMode>(mode));
        }
    }
#endif
}

FFI_EXPORT void dsp_engine_get_telemetry(DspEngineHandle handle, float* out_rms_l, float* out_rms_r, int64_t* out_total_frames) {
#ifdef _WIN32
    if (handle && out_rms_l && out_rms_r && out_total_frames) {
        auto* ctx = static_cast<EngineContext*>(handle);
        if (ctx->audio_out) {
            float rl = 0.0f, rr = 0.0f;
            int64_t tf = 0;
            ctx->audio_out->get_telemetry(rl, rr, tf);
            *out_rms_l = rl;
            *out_rms_r = rr;
            *out_total_frames = tf;
            return;
        }
    }
#endif
    if (out_rms_l) *out_rms_l = 0.0f;
    if (out_rms_r) *out_rms_r = 0.0f;
    if (out_total_frames) *out_total_frames = 0;
}

} // extern "C"
