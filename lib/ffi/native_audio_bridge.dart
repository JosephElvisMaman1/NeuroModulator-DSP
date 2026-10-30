import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dsp_bindings.dart';

/// Telemetry snapshot from C++ real-time audio thread
class DspTelemetry {
  final double rmsLeft;
  final double rmsRight;
  final int totalFrames;
  final bool isLiveAudioRunning;

  const DspTelemetry({
    required this.rmsLeft,
    required this.rmsRight,
    required this.totalFrames,
    required this.isLiveAudioRunning,
  });
}

/// High-Level Dart Bridge to Native C++ DSP Engine.
/// Provides microsecond zero-copy execution using pre-allocated native memory pools.
class NativeAudioBridge {
  static final NativeAudioBridge instance = NativeAudioBridge._internal();

  NativeAudioBridge._internal();

  DspNativeBindings? _bindings;
  Pointer<Void>? _engineHandle;
  Pointer<CDspParameters>? _paramBuffer;

  Pointer<Float>? _telemetryRmsL;
  Pointer<Float>? _telemetryRmsR;
  Pointer<Int64>? _telemetryTotalFrames;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Initializes the C++ audio engine with the hardware sample rate.
  void initialize({double sampleRate = 48000.0}) {
    if (_initialized) return;

    _bindings = DspNativeBindings();
    _engineHandle = _bindings!.dspEngineCreate();
    _bindings!.dspEngineInit(_engineHandle!, sampleRate);

    // Pre-allocate persistent parameter struct in native memory (Zero GC pause)
    _paramBuffer = calloc<CDspParameters>();

    // Pre-allocate telemetry buffers
    _telemetryRmsL = calloc<Float>();
    _telemetryRmsR = calloc<Float>();
    _telemetryTotalFrames = calloc<Int64>();

    _initialized = true;
  }

  /// Dispatches parameter updates to the C++ core lock-free atomic block.
  void updateParameters({
    required bool pitchShiftEnabled,
    double pitchShiftRatio = 432.0 / 440.0,
    required bool deltaLpfEnabled,
    double deltaLpfCutoff = 950.0,
    double deltaLpfQ = 0.70710678,
    required bool alphaBinauralEnabled,
    double alphaCarrierFreq = 250.0,
    double alphaBeatFreq = 10.0,
    double alphaGainDb = -18.0,
    required bool gammaIsochronicEnabled,
    double gammaCarrierFreq = 216.0,
    double gammaPulseFreq = 40.0,
    double gammaGainDb = -15.0,
    required bool solfeggioEnabled,
    double solfeggioFreq = 528.0,
    double solfeggioDuckingThresholdDb = -20.0,
    double solfeggioGainDb = -18.0,
    double masterGain = 1.0,
    bool limiterEnabled = true,
  }) {
    if (!_initialized || _engineHandle == null || _paramBuffer == null) return;

    final p = _paramBuffer!.ref;
    p.pitchShiftEnabled = pitchShiftEnabled ? 1 : 0;
    p.pitchShiftRatio = pitchShiftRatio;

    p.deltaLpfEnabled = deltaLpfEnabled ? 1 : 0;
    p.deltaLpfCutoff = deltaLpfCutoff;
    p.deltaLpfQ = deltaLpfQ;

    p.alphaBinauralEnabled = alphaBinauralEnabled ? 1 : 0;
    p.alphaCarrierFreq = alphaCarrierFreq;
    p.alphaBeatFreq = alphaBeatFreq;
    p.alphaGainDb = alphaGainDb;

    p.gammaIsochronicEnabled = gammaIsochronicEnabled ? 1 : 0;
    p.gammaCarrierFreq = gammaCarrierFreq;
    p.gammaPulseFreq = gammaPulseFreq;
    p.gammaGainDb = gammaGainDb;

    p.solfeggioEnabled = solfeggioEnabled ? 1 : 0;
    p.solfeggioFreq = solfeggioFreq;
    p.solfeggioDuckingThresholdDb = solfeggioDuckingThresholdDb;
    p.solfeggioGainDb = solfeggioGainDb;

    p.masterGain = masterGain;
    p.limiterEnabled = limiterEnabled ? 1 : 0;

    // Send atomically to C++ (no mutex, no Dart-thread stalling)
    _bindings!.dspEngineSetParameters(_engineHandle!, _paramBuffer!);
  }

  /// Starts live physical audio streaming to default sound device (speakers/headphones).
  bool startLiveAudio() {
    if (!_initialized || _engineHandle == null) return false;
    return _bindings!.dspEngineStartLiveAudio(_engineHandle!) != 0;
  }

  /// Stops live physical audio streaming.
  void stopLiveAudio() {
    if (!_initialized || _engineHandle == null) return;
    _bindings!.dspEngineStopLiveAudio(_engineHandle!);
  }

  /// Checks if live hardware sound streaming is active.
  bool get isLiveAudioRunning {
    if (!_initialized || _engineHandle == null) return false;
    return _bindings!.dspEngineIsLiveAudioRunning(_engineHandle!) != 0;
  }

  /// Sets audio source mode (0: Ambient Chord, 1: Pink Noise, 2: BWE Tones Only).
  void setLiveSourceMode(int mode) {
    if (!_initialized || _engineHandle == null) return;
    _bindings!.dspEngineSetLiveSourceMode(_engineHandle!, mode);
  }

  /// Retrieves high-frequency RMS & frame telemetry from the C++ audio thread (Zero allocation).
  DspTelemetry getTelemetry() {
    if (!_initialized || _engineHandle == null || _telemetryRmsL == null) {
      return const DspTelemetry(rmsLeft: 0, rmsRight: 0, totalFrames: 0, isLiveAudioRunning: false);
    }

    _bindings!.dspEngineGetTelemetry(
      _engineHandle!,
      _telemetryRmsL!,
      _telemetryRmsR!,
      _telemetryTotalFrames!,
    );

    return DspTelemetry(
      rmsLeft: _telemetryRmsL!.value,
      rmsRight: _telemetryRmsR!.value,
      totalFrames: _telemetryTotalFrames!.value,
      isLiveAudioRunning: isLiveAudioRunning,
    );
  }

  /// Processes interleaved audio buffer directly via pointer in the same memory space.
  /// Zero copy, Zero MethodChannel, Zero serialization.
  void processInterleaved(Pointer<Float> audioBuffer, int frames) {
    if (!_initialized || _engineHandle == null) return;
    _bindings!.dspEngineProcessInterleaved(_engineHandle!, audioBuffer, frames);
  }

  /// Frees native memory and destroys C++ engine.
  void dispose() {
    if (!_initialized) return;

    if (_engineHandle != null) {
      _bindings!.dspEngineStopLiveAudio(_engineHandle!);
      _bindings!.dspEngineDestroy(_engineHandle!);
      _engineHandle = null;
    }

    if (_paramBuffer != null) {
      calloc.free(_paramBuffer!);
      _paramBuffer = null;
    }
    if (_telemetryRmsL != null) {
      calloc.free(_telemetryRmsL!);
      _telemetryRmsL = null;
    }
    if (_telemetryRmsR != null) {
      calloc.free(_telemetryRmsR!);
      _telemetryRmsR = null;
    }
    if (_telemetryTotalFrames != null) {
      calloc.free(_telemetryTotalFrames!);
      _telemetryTotalFrames = null;
    }

    _initialized = false;
  }
}
