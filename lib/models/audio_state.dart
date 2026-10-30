enum NeuroAcousticPreset {
  deepSleepDelta,
  alphaMeditation,
  gammaCognitiveBoost,
  solfeggioHarmonics,
  custom,
}

class NeuroDspState {
  // 432 Hz Pitch Shifting
  final bool pitchShift432Enabled;
  final double pitchShiftRatio;

  // Delta Filter (DF2T Biquad LPF)
  final bool deltaLpfEnabled;
  final double deltaLpfCutoff;

  // Alpha Binaural Beat (8 - 12 Hz)
  final bool alphaBinauralEnabled;
  final double alphaCarrierFreq;
  final double alphaBeatFreq;
  final double alphaGainDb;

  // Gamma Isochronic Pulses (40 Hz)
  final bool gammaIsochronicEnabled;
  final double gammaCarrierFreq;
  final double gammaPulseFreq;
  final double gammaGainDb;

  // 528 Hz Solfeggio + Dynamic Ducking
  final bool solfeggio528Enabled;
  final double solfeggioGainDb;
  final double solfeggioDuckingDb;

  // Master
  final double masterGain;
  final bool isCapturing;
  final NeuroAcousticPreset activePreset;

  const NeuroDspState({
    this.pitchShift432Enabled = true,
    this.pitchShiftRatio = 432.0 / 440.0,
    this.deltaLpfEnabled = false,
    this.deltaLpfCutoff = 950.0,
    this.alphaBinauralEnabled = true,
    this.alphaCarrierFreq = 250.0,
    this.alphaBeatFreq = 10.0,
    this.alphaGainDb = -18.0,
    this.gammaIsochronicEnabled = false,
    this.gammaCarrierFreq = 216.0,
    this.gammaPulseFreq = 40.0,
    this.gammaGainDb = -15.0,
    this.solfeggio528Enabled = false,
    this.solfeggioGainDb = -18.0,
    this.solfeggioDuckingDb = -20.0,
    this.masterGain = 1.0,
    this.isCapturing = true,
    this.activePreset = NeuroAcousticPreset.alphaMeditation,
  });

  NeuroDspState copyWith({
    bool? pitchShift432Enabled,
    double? pitchShiftRatio,
    bool? deltaLpfEnabled,
    double? deltaLpfCutoff,
    bool? alphaBinauralEnabled,
    double? alphaCarrierFreq,
    double? alphaBeatFreq,
    double? alphaGainDb,
    bool? gammaIsochronicEnabled,
    double? gammaCarrierFreq,
    double? gammaPulseFreq,
    double? gammaGainDb,
    bool? solfeggio528Enabled,
    double? solfeggioGainDb,
    double? solfeggioDuckingDb,
    double? masterGain,
    bool? isCapturing,
    NeuroAcousticPreset? activePreset,
  }) {
    return NeuroDspState(
      pitchShift432Enabled: pitchShift432Enabled ?? this.pitchShift432Enabled,
      pitchShiftRatio: pitchShiftRatio ?? this.pitchShiftRatio,
      deltaLpfEnabled: deltaLpfEnabled ?? this.deltaLpfEnabled,
      deltaLpfCutoff: deltaLpfCutoff ?? this.deltaLpfCutoff,
      alphaBinauralEnabled: alphaBinauralEnabled ?? this.alphaBinauralEnabled,
      alphaCarrierFreq: alphaCarrierFreq ?? this.alphaCarrierFreq,
      alphaBeatFreq: alphaBeatFreq ?? this.alphaBeatFreq,
      alphaGainDb: alphaGainDb ?? this.alphaGainDb,
      gammaIsochronicEnabled: gammaIsochronicEnabled ?? this.gammaIsochronicEnabled,
      gammaCarrierFreq: gammaCarrierFreq ?? this.gammaCarrierFreq,
      gammaPulseFreq: gammaPulseFreq ?? this.gammaPulseFreq,
      gammaGainDb: gammaGainDb ?? this.gammaGainDb,
      solfeggio528Enabled: solfeggio528Enabled ?? this.solfeggio528Enabled,
      solfeggioGainDb: solfeggioGainDb ?? this.solfeggioGainDb,
      solfeggioDuckingDb: solfeggioDuckingDb ?? this.solfeggioDuckingDb,
      masterGain: masterGain ?? this.masterGain,
      isCapturing: isCapturing ?? this.isCapturing,
      activePreset: activePreset ?? this.activePreset,
    );
  }
}
