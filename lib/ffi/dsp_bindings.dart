import 'dart:ffi';
import 'dart:io';

/// C-compatible representation of DSP parameters for Zero-Copy Dart FFI.
final class CDspParameters extends Struct {
  @Int32()
  external int pitchShiftEnabled;

  @Float()
  external double pitchShiftRatio;

  @Int32()
  external int deltaLpfEnabled;

  @Float()
  external double deltaLpfCutoff;

  @Float()
  external double deltaLpfQ;

  @Int32()
  external int alphaBinauralEnabled;

  @Float()
  external double alphaCarrierFreq;

  @Float()
  external double alphaBeatFreq;

  @Float()
  external double alphaGainDb;

  @Int32()
  external int gammaIsochronicEnabled;

  @Float()
  external double gammaCarrierFreq;

  @Float()
  external double gammaPulseFreq;

  @Float()
  external double gammaGainDb;

  @Int32()
  external int solfeggioEnabled;

  @Float()
  external double solfeggioFreq;

  @Float()
  external double solfeggioDuckingThresholdDb;

  @Float()
  external double solfeggioGainDb;

  @Float()
  external double masterGain;

  @Int32()
  external int limiterEnabled;
}

// C API Function Signatures
typedef DspEngineCreateNative = Pointer<Void> Function();
typedef DspEngineCreateDart = Pointer<Void> Function();

typedef DspEngineDestroyNative = Void Function(Pointer<Void> handle);
typedef DspEngineDestroyDart = void Function(Pointer<Void> handle);

typedef DspEngineInitNative = Void Function(Pointer<Void> handle, Float sampleRate);
typedef DspEngineInitDart = void Function(Pointer<Void> handle, double sampleRate);

typedef DspEngineResetNative = Void Function(Pointer<Void> handle);
typedef DspEngineResetDart = void Function(Pointer<Void> handle);

typedef DspEngineProcessNative = Void Function(Pointer<Void> handle, Pointer<Float> buffer, Int32 frames);
typedef DspEngineProcessDart = void Function(Pointer<Void> handle, Pointer<Float> buffer, int frames);

typedef DspEngineSetParametersNative = Void Function(Pointer<Void> handle, Pointer<CDspParameters> params);
typedef DspEngineSetParametersDart = void Function(Pointer<Void> handle, Pointer<CDspParameters> params);

typedef DspEngineGetParametersNative = Void Function(Pointer<Void> handle, Pointer<CDspParameters> outParams);
typedef DspEngineGetParametersDart = void Function(Pointer<Void> handle, Pointer<CDspParameters> outParams);

typedef DspEngineStartLiveAudioNative = Int32 Function(Pointer<Void> handle);
typedef DspEngineStartLiveAudioDart = int Function(Pointer<Void> handle);

typedef DspEngineStopLiveAudioNative = Void Function(Pointer<Void> handle);
typedef DspEngineStopLiveAudioDart = void Function(Pointer<Void> handle);

typedef DspEngineIsLiveAudioRunningNative = Int32 Function(Pointer<Void> handle);
typedef DspEngineIsLiveAudioRunningDart = int Function(Pointer<Void> handle);

typedef DspEngineSetLiveSourceModeNative = Void Function(Pointer<Void> handle, Int32 mode);
typedef DspEngineSetLiveSourceModeDart = void Function(Pointer<Void> handle, int mode);

typedef DspEngineGetTelemetryNative = Void Function(
    Pointer<Void> handle, Pointer<Float> outRmsL, Pointer<Float> outRmsR, Pointer<Int64> outTotalFrames);
typedef DspEngineGetTelemetryDart = void Function(
    Pointer<Void> handle, Pointer<Float> outRmsL, Pointer<Float> outRmsR, Pointer<Int64> outTotalFrames);

/// Low-Level Dynamic Library Binding for the C++ DSP Core
class DspNativeBindings {
  late final DynamicLibrary _dylib;

  late final DspEngineCreateDart dspEngineCreate;
  late final DspEngineDestroyDart dspEngineDestroy;
  late final DspEngineInitDart dspEngineInit;
  late final DspEngineResetDart dspEngineReset;
  late final DspEngineProcessDart dspEngineProcessInterleaved;
  late final DspEngineSetParametersDart dspEngineSetParameters;
  late final DspEngineGetParametersDart dspEngineGetParameters;

  late final DspEngineStartLiveAudioDart dspEngineStartLiveAudio;
  late final DspEngineStopLiveAudioDart dspEngineStopLiveAudio;
  late final DspEngineIsLiveAudioRunningDart dspEngineIsLiveAudioRunning;
  late final DspEngineSetLiveSourceModeDart dspEngineSetLiveSourceMode;
  late final DspEngineGetTelemetryDart dspEngineGetTelemetry;

  DspNativeBindings() {
    _dylib = _loadLibrary();

    dspEngineCreate = _dylib
        .lookupFunction<DspEngineCreateNative, DspEngineCreateDart>('dsp_engine_create');
    dspEngineDestroy = _dylib
        .lookupFunction<DspEngineDestroyNative, DspEngineDestroyDart>('dsp_engine_destroy');
    dspEngineInit = _dylib
        .lookupFunction<DspEngineInitNative, DspEngineInitDart>('dsp_engine_init');
    dspEngineReset = _dylib
        .lookupFunction<DspEngineResetNative, DspEngineResetDart>('dsp_engine_reset');
    dspEngineProcessInterleaved = _dylib
        .lookupFunction<DspEngineProcessNative, DspEngineProcessDart>('dsp_engine_process_interleaved');
    dspEngineSetParameters = _dylib
        .lookupFunction<DspEngineSetParametersNative, DspEngineSetParametersDart>('dsp_engine_set_parameters');
    dspEngineGetParameters = _dylib
        .lookupFunction<DspEngineGetParametersNative, DspEngineGetParametersDart>('dsp_engine_get_parameters');

    dspEngineStartLiveAudio = _dylib
        .lookupFunction<DspEngineStartLiveAudioNative, DspEngineStartLiveAudioDart>('dsp_engine_start_live_audio');
    dspEngineStopLiveAudio = _dylib
        .lookupFunction<DspEngineStopLiveAudioNative, DspEngineStopLiveAudioDart>('dsp_engine_stop_live_audio');
    dspEngineIsLiveAudioRunning = _dylib
        .lookupFunction<DspEngineIsLiveAudioRunningNative, DspEngineIsLiveAudioRunningDart>('dsp_engine_is_live_audio_running');
    dspEngineSetLiveSourceMode = _dylib
        .lookupFunction<DspEngineSetLiveSourceModeNative, DspEngineSetLiveSourceModeDart>('dsp_engine_set_live_source_mode');
    dspEngineGetTelemetry = _dylib
        .lookupFunction<DspEngineGetTelemetryNative, DspEngineGetTelemetryDart>('dsp_engine_get_telemetry');
  }

  static DynamicLibrary _loadLibrary() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libneuro_dsp_native.so');
    } else if (Platform.isWindows) {
      try {
        return DynamicLibrary.open('neuro_dsp_native.dll');
      } catch (_) {
        final exeDir = File(Platform.resolvedExecutable).parent.path;
        return DynamicLibrary.open('$exeDir\\neuro_dsp_native.dll');
      }
    } else if (Platform.isLinux) {
      return DynamicLibrary.open('libneuro_dsp_native.so');
    }
    throw UnsupportedError('Unsupported operating system for NeuroDSP');
  }
}
