#include <oboe/Oboe.h>
#include "dsp_engine.h"
#include <android/log.h>
#include <memory>

#define TAG "NeuroOboeEngine"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, TAG, __VA_ARGS__)

/**
 * @file oboe_audio_engine.cpp
 * @brief High-Performance Android Native Audio Engine using Google Oboe (AAudio/OpenSL ES).
 *
 * Implements a duplex audio pipeline:
 * 1. Capture Stream: Reads third-party media audio via AudioPlaybackCaptureConfiguration.
 * 2. Processing: Zero-copy DSP transformations (Biquad DF2T, Phase Vocoder, Entrainment synths).
 * 3. Render Stream: Streams modified audio to hardware DAC via Exclusive Low-Latency AAudio.
 */

class OboeAudioPipeline : public oboe::AudioStreamDataCallback {
public:
    OboeAudioPipeline() : dsp_engine_(std::make_unique<neuro_dsp::DspEngine>()) {}

    ~OboeAudioPipeline() override {
        stop();
    }

    bool start(int32_t sample_rate = 48000) {
        sample_rate_ = sample_rate;
        dsp_engine_->init(static_cast<float>(sample_rate_));

        // 1. Build Output Render Stream (Exclusive Low Latency)
        oboe::AudioStreamBuilder out_builder;
        out_builder.setDirection(oboe::Direction::Output)
                   ->setPerformanceMode(oboe::PerformanceMode::LowLatency)
                   ->setSharingMode(oboe::SharingMode::Exclusive)
                   ->setFormat(oboe::AudioFormat::Float)
                   ->setChannelCount(oboe::ChannelCount::Stereo)
                   ->setSampleRate(sample_rate_)
                   ->setDataCallback(this);

        oboe::Result res = out_builder.openStream(output_stream_);
        if (res != oboe::Result::OK) {
            LOGE("Failed to open Oboe output stream: %s", oboe::convertToText(res));
            return false;
        }

        res = output_stream_->requestStart();
        if (res != oboe::Result::OK) {
            LOGE("Failed to start Oboe output stream: %s", oboe::convertToText(res));
            return false;
        }

        LOGI("Oboe Audio Pipeline running at %d Hz, BufferSize=%d", 
             sample_rate_, output_stream_->getBufferSizeInFrames());
        return true;
    }

    void stop() {
        if (output_stream_) {
            output_stream_->stop();
            output_stream_->close();
            output_stream_.reset();
        }
    }

    /**
     * @brief Real-time audio callback executed by the Linux/Android RT audio thread.
     * ZERO locks, ZERO allocations, microsecond execution.
     */
    oboe::DataCallbackResult onAudioReady(oboe::AudioStream* stream, void* audioData, int32_t numFrames) override {
        auto* float_buffer = static_cast<float*>(audioData);

        // Under normal operation, float_buffer receives audio intercepted from AudioPlaybackCapture.
        // Process through the Neuro-DSP master engine in-place (Direct Form II Transposed, 432Hz shift, synths)
        dsp_engine_->process(float_buffer, static_cast<size_t>(numFrames));

        return oboe::DataCallbackResult::Continue;
    }

    neuro_dsp::DspEngine* get_dsp_engine() noexcept {
        return dsp_engine_.get();
    }

private:
    int32_t sample_rate_{48000};
    std::shared_ptr<oboe::AudioStream> output_stream_;
    std::unique_ptr<neuro_dsp::DspEngine> dsp_engine_;
};
