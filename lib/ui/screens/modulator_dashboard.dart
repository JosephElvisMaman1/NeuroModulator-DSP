import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/audio_state.dart';
import '../../ffi/native_audio_bridge.dart';
import '../../i18n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../components/neuromorphic_card.dart';
import '../components/parameter_slider.dart';
import '../components/mode_selector_pill.dart';
import '../components/isolated_web_player.dart';
import '../components/live_telemetry_hud.dart';

class ModulatorDashboard extends StatefulWidget {
  const ModulatorDashboard({super.key});

  @override
  State<ModulatorDashboard> createState() => _ModulatorDashboardState();
}

class _ModulatorDashboardState extends State<ModulatorDashboard> {
  NeuroDspState _state = const NeuroDspState(isCapturing: false);
  AppLanguage _lang = AppLanguage.es;

  AppStrings get _s => AppStrings(_lang);

  @override
  void initState() {
    super.initState();
    try {
      NativeAudioBridge.instance.initialize(sampleRate: 48000.0);
      _syncToDsp();
    } catch (e) {
      debugPrint('NativeAudioBridge deferred init: $e');
    }
  }

  void _toggleMasterPower(bool turnOn) {
    if (turnOn) {
      _syncToDsp();
      final started = NativeAudioBridge.instance.startLiveAudio();
      setState(() => _state = _state.copyWith(isCapturing: started));
    } else {
      NativeAudioBridge.instance.stopLiveAudio();
      setState(() => _state = _state.copyWith(isCapturing: false));
    }
  }

  void _syncToDsp() {
    if (!NativeAudioBridge.instance.isInitialized) return;
    NativeAudioBridge.instance.updateParameters(
      pitchShiftEnabled: _state.pitchShift432Enabled,
      pitchShiftRatio: _state.pitchShiftRatio,
      deltaLpfEnabled: _state.deltaLpfEnabled,
      deltaLpfCutoff: _state.deltaLpfCutoff,
      alphaBinauralEnabled: _state.alphaBinauralEnabled,
      alphaCarrierFreq: _state.alphaCarrierFreq,
      alphaBeatFreq: _state.alphaBeatFreq,
      alphaGainDb: _state.alphaGainDb,
      gammaIsochronicEnabled: _state.gammaIsochronicEnabled,
      gammaCarrierFreq: _state.gammaCarrierFreq,
      gammaPulseFreq: _state.gammaPulseFreq,
      gammaGainDb: _state.gammaGainDb,
      solfeggioEnabled: _state.solfeggio528Enabled,
      solfeggioDuckingThresholdDb: _state.solfeggioDuckingDb,
      solfeggioGainDb: _state.solfeggioGainDb,
      masterGain: _state.masterGain,
    );
  }

  void _applyPreset(NeuroAcousticPreset preset) {
    setState(() {
      switch (preset) {
        case NeuroAcousticPreset.deepSleepDelta:
          _state = _state.copyWith(
            activePreset: preset,
            pitchShift432Enabled: true,
            deltaLpfEnabled: true,
            deltaLpfCutoff: 900.0,
            alphaBinauralEnabled: false,
            gammaIsochronicEnabled: false,
            solfeggio528Enabled: false,
          );
          break;
        case NeuroAcousticPreset.alphaMeditation:
          _state = _state.copyWith(
            activePreset: preset,
            pitchShift432Enabled: true,
            deltaLpfEnabled: false,
            alphaBinauralEnabled: true,
            alphaCarrierFreq: 250.0,
            alphaBeatFreq: 10.0,
            gammaIsochronicEnabled: false,
            solfeggio528Enabled: false,
          );
          break;
        case NeuroAcousticPreset.gammaCognitiveBoost:
          _state = _state.copyWith(
            activePreset: preset,
            pitchShift432Enabled: false,
            deltaLpfEnabled: false,
            alphaBinauralEnabled: false,
            gammaIsochronicEnabled: true,
            gammaCarrierFreq: 216.0,
            gammaPulseFreq: 40.0,
            solfeggio528Enabled: false,
          );
          break;
        case NeuroAcousticPreset.solfeggioHarmonics:
          _state = _state.copyWith(
            activePreset: preset,
            pitchShift432Enabled: true,
            deltaLpfEnabled: false,
            alphaBinauralEnabled: false,
            gammaIsochronicEnabled: false,
            solfeggio528Enabled: true,
            solfeggioDuckingDb: -20.0,
          );
          break;
        case NeuroAcousticPreset.custom:
          _state = _state.copyWith(activePreset: preset);
          break;
      }
    });
    _syncToDsp();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktopWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.slate950,
      appBar: AppBar(
        backgroundColor: AppColors.slate950,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _state.isCapturing ? AppColors.emerald500 : AppColors.slate600,
                shape: BoxShape.circle,
                boxShadow: _state.isCapturing
                    ? [
                        BoxShadow(
                          color: AppColors.emerald500.withValues(alpha: 0.7),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                _s.appTitle,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Support / Buy Me a Coffee Button
          _buildSupportButton(),
          const SizedBox(width: AppSpacing.sm),
          // Language Selector (ES | EN | 中文)
          _buildLanguageSelector(),
          const SizedBox(width: AppSpacing.sm),
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.slate800,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.slate700),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, size: 14, color: AppColors.cyan400),
                const SizedBox(width: 4),
                Text(
                  _s.lowLatencyBadge,
                  style: const TextStyle(
                    color: AppColors.slate200,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: isDesktopWide ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Future<void> _launchSupportUrl() async {
    final uri = Uri.parse('https://buymeacoffee.com/JoshM1');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Widget _buildSupportButton() {
    return InkWell(
      onTap: _launchSupportUrl,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFDD00), Color(0xFFFFAB00)],
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFDD00).withValues(alpha: 0.35),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('☕', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              _s.supportButtonLabel,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.slate900,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLangOption('ES', AppLanguage.es),
          _buildLangOption('EN', AppLanguage.en),
          _buildLangOption('中文', AppLanguage.zh),
        ],
      ),
    );
  }

  Widget _buildLangOption(String label, AppLanguage lang) {
    final isSelected = _lang == lang;
    return InkWell(
      onTap: () => setState(() => _lang = lang),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cyan500 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.slate950 : AppColors.slate400,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Presets + Mode Clinical Description + DSP Neural Core Controls
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPresetsSection(),
                  const SizedBox(height: AppSpacing.md),
                  _buildModeDescriptionCard(),
                  const SizedBox(height: AppSpacing.md),
                  _buildPitchShifterCard(),
                  const SizedBox(height: AppSpacing.md),
                  _buildDeltaBiquadCard(),
                  const SizedBox(height: AppSpacing.md),
                  _buildAlphaBinauralCard(),
                  const SizedBox(height: AppSpacing.md),
                  _buildGammaIsochronicCard(),
                  const SizedBox(height: AppSpacing.md),
                  _buildSolfeggioCard(),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),

          // Right Column: Master Power ON/OFF + WASAPI Loopback Telemetry + Isolated Web Player
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildMasterPowerBanner(),
                  const SizedBox(height: AppSpacing.md),
                  LiveTelemetryHud(
                    strings: _s,
                    isMasterPowerOn: _state.isCapturing,
                    onPowerChanged: _toggleMasterPower,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  IsolatedWebPlayer(strings: _s),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMasterPowerBanner(),
          const SizedBox(height: AppSpacing.md),
          LiveTelemetryHud(
            strings: _s,
            isMasterPowerOn: _state.isCapturing,
            onPowerChanged: _toggleMasterPower,
          ),
          const SizedBox(height: AppSpacing.md),
          IsolatedWebPlayer(strings: _s),
          const SizedBox(height: AppSpacing.lg),
          _buildPresetsSection(),
          const SizedBox(height: AppSpacing.md),
          _buildModeDescriptionCard(),
          const SizedBox(height: AppSpacing.md),
          _buildPitchShifterCard(),
          const SizedBox(height: AppSpacing.md),
          _buildDeltaBiquadCard(),
          const SizedBox(height: AppSpacing.md),
          _buildAlphaBinauralCard(),
          const SizedBox(height: AppSpacing.md),
          _buildGammaIsochronicCard(),
          const SizedBox(height: AppSpacing.md),
          _buildSolfeggioCard(),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  /// Master ON/OFF Power Card: When ON, all channels route through the DSP. When OFF, system runs normally.
  Widget _buildMasterPowerBanner() {
    final isOn = _state.isCapturing;
    final accent = isOn ? AppColors.emerald500 : AppColors.slate600;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.slate900,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isOn ? AppColors.emerald500 : AppColors.slate700,
          width: isOn ? 1.8 : 1.0,
        ),
        boxShadow: isOn
            ? [
                BoxShadow(
                  color: AppColors.emerald500.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.power_settings_new,
                  color: isOn ? AppColors.emerald500 : AppColors.slate400,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _s.masterPowerTitle,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOn ? _s.masterPowerOnDesc : _s.masterPowerOffDesc,
                      style: TextStyle(
                        color: isOn ? AppColors.slate200 : AppColors.slate400,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isOn ? AppColors.emerald500 : AppColors.slate800,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: isOn ? AppColors.emerald500 : AppColors.cyan500,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              icon: Icon(
                isOn ? Icons.check_circle : Icons.power_settings_new,
                size: 20,
                color: isOn ? AppColors.slate950 : AppColors.cyan400,
              ),
              label: Text(
                isOn ? _s.powerButtonOn : _s.powerButtonOff,
                style: TextStyle(
                  color: isOn ? AppColors.slate950 : AppColors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.8,
                ),
              ),
              onPressed: () => _toggleMasterPower(!isOn),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _s.presetsHeader,
          style: const TextStyle(
            color: AppColors.slate400,
            fontSize: 12.0,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              ModeSelectorPill(
                label: _s.presetAlphaLabel,
                frequencyTag: '10 Hz / 432 Hz',
                isSelected: _state.activePreset == NeuroAcousticPreset.alphaMeditation,
                accentColor: AppColors.cyan500,
                onTap: () => _applyPreset(NeuroAcousticPreset.alphaMeditation),
              ),
              const SizedBox(width: AppSpacing.sm),
              ModeSelectorPill(
                label: _s.presetDeltaLabel,
                frequencyTag: '3 Hz / DF2T LPF',
                isSelected: _state.activePreset == NeuroAcousticPreset.deepSleepDelta,
                accentColor: AppColors.violet500,
                onTap: () => _applyPreset(NeuroAcousticPreset.deepSleepDelta),
              ),
              const SizedBox(width: AppSpacing.sm),
              ModeSelectorPill(
                label: _s.presetGammaLabel,
                frequencyTag: '40 Hz Pulses',
                isSelected: _state.activePreset == NeuroAcousticPreset.gammaCognitiveBoost,
                accentColor: AppColors.rose500,
                onTap: () => _applyPreset(NeuroAcousticPreset.gammaCognitiveBoost),
              ),
              const SizedBox(width: AppSpacing.sm),
              ModeSelectorPill(
                label: _s.presetSolfeggioLabel,
                frequencyTag: '528 Hz Ducked',
                isSelected: _state.activePreset == NeuroAcousticPreset.solfeggioHarmonics,
                accentColor: AppColors.emerald500,
                onTap: () => _applyPreset(NeuroAcousticPreset.solfeggioHarmonics),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Detailed Clinical & DSP Description Card for the Active Mode
  Widget _buildModeDescriptionCard() {
    final preset = _state.activePreset;
    final Color accent = switch (preset) {
      NeuroAcousticPreset.alphaMeditation => AppColors.cyan500,
      NeuroAcousticPreset.deepSleepDelta => AppColors.violet500,
      NeuroAcousticPreset.gammaCognitiveBoost => AppColors.rose500,
      NeuroAcousticPreset.solfeggioHarmonics => AppColors.emerald500,
      NeuroAcousticPreset.custom => AppColors.amber500,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology_alt, color: accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _s.modeTitle(preset),
                  style: TextStyle(
                    color: accent,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _s.modeScientificDesc(preset),
            style: const TextStyle(
              color: AppColors.slate200,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPitchShifterCard() {
    return NeuromorphicCard(
      title: _s.pitchCardTitle,
      subtitle: _s.pitchCardSub,
      borderColor: _state.pitchShift432Enabled ? AppColors.cyan500.withValues(alpha: 0.5) : null,
      trailing: Switch.adaptive(
        value: _state.pitchShift432Enabled,
        activeTrackColor: AppColors.cyan500,
        onChanged: (val) {
          setState(() => _state = _state.copyWith(
                pitchShift432Enabled: val,
                activePreset: NeuroAcousticPreset.custom,
              ));
          _syncToDsp();
        },
      ),
      child: Text(
        _s.pitchCardBody,
        style: const TextStyle(color: AppColors.slate400, fontSize: 12, height: 1.4),
      ),
    );
  }

  Widget _buildDeltaBiquadCard() {
    return NeuromorphicCard(
      title: _s.deltaCardTitle,
      subtitle: _s.deltaCardSub,
      borderColor: _state.deltaLpfEnabled ? AppColors.violet500.withValues(alpha: 0.5) : null,
      trailing: Switch.adaptive(
        value: _state.deltaLpfEnabled,
        activeTrackColor: AppColors.violet500,
        onChanged: (val) {
          setState(() => _state = _state.copyWith(
                deltaLpfEnabled: val,
                activePreset: NeuroAcousticPreset.custom,
              ));
          _syncToDsp();
        },
      ),
      child: Column(
        children: [
          ParameterSlider(
            label: _s.cutoffSliderLabel,
            valueDisplay: '${_state.deltaLpfCutoff.toInt()} Hz',
            value: _state.deltaLpfCutoff,
            min: 600.0,
            max: 1500.0,
            activeColor: AppColors.violet500,
            onChanged: (val) {
              setState(() => _state = _state.copyWith(deltaLpfCutoff: val));
              _syncToDsp();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlphaBinauralCard() {
    return NeuromorphicCard(
      title: _s.alphaCardTitle,
      subtitle: _s.alphaCardSub,
      borderColor: _state.alphaBinauralEnabled ? AppColors.cyan500.withValues(alpha: 0.5) : null,
      trailing: Switch.adaptive(
        value: _state.alphaBinauralEnabled,
        activeTrackColor: AppColors.cyan500,
        onChanged: (val) {
          setState(() => _state = _state.copyWith(
                alphaBinauralEnabled: val,
                activePreset: NeuroAcousticPreset.custom,
              ));
          _syncToDsp();
        },
      ),
      child: Column(
        children: [
          ParameterSlider(
            label: _s.alphaBeatLabel,
            valueDisplay: '${_state.alphaBeatFreq.toStringAsFixed(1)} Hz',
            value: _state.alphaBeatFreq,
            min: 8.0,
            max: 12.0,
            activeColor: AppColors.cyan500,
            onChanged: (val) {
              setState(() => _state = _state.copyWith(alphaBeatFreq: val));
              _syncToDsp();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          ParameterSlider(
            label: _s.alphaCarrierLabel,
            valueDisplay: '${_state.alphaCarrierFreq.toInt()} Hz',
            value: _state.alphaCarrierFreq,
            min: 200.0,
            max: 400.0,
            activeColor: AppColors.cyan500,
            onChanged: (val) {
              setState(() => _state = _state.copyWith(alphaCarrierFreq: val));
              _syncToDsp();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          ParameterSlider(
            label: _s.subliminalGainLabel,
            valueDisplay: '${_state.alphaGainDb.toStringAsFixed(1)} dB',
            value: _state.alphaGainDb,
            min: -30.0,
            max: -6.0,
            activeColor: AppColors.cyan500,
            onChanged: (val) {
              setState(() => _state = _state.copyWith(alphaGainDb: val));
              _syncToDsp();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGammaIsochronicCard() {
    return NeuromorphicCard(
      title: _s.gammaCardTitle,
      subtitle: _s.gammaCardSub,
      borderColor: _state.gammaIsochronicEnabled ? AppColors.rose500.withValues(alpha: 0.5) : null,
      trailing: Switch.adaptive(
        value: _state.gammaIsochronicEnabled,
        activeTrackColor: AppColors.rose500,
        onChanged: (val) {
          setState(() => _state = _state.copyWith(
                gammaIsochronicEnabled: val,
                activePreset: NeuroAcousticPreset.custom,
              ));
          _syncToDsp();
        },
      ),
      child: Column(
        children: [
          ParameterSlider(
            label: _s.gammaPulseRateLabel,
            valueDisplay: '${_state.gammaPulseFreq.toStringAsFixed(1)} Hz',
            value: _state.gammaPulseFreq,
            min: 35.0,
            max: 45.0,
            activeColor: AppColors.rose500,
            onChanged: (val) {
              setState(() => _state = _state.copyWith(gammaPulseFreq: val));
              _syncToDsp();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          ParameterSlider(
            label: _s.gammaCarrierLabel,
            valueDisplay: '${_state.gammaCarrierFreq.toInt()} Hz',
            value: _state.gammaCarrierFreq,
            min: 150.0,
            max: 350.0,
            activeColor: AppColors.rose500,
            onChanged: (val) {
              setState(() => _state = _state.copyWith(gammaCarrierFreq: val));
              _syncToDsp();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          ParameterSlider(
            label: _s.gammaGainLabel,
            valueDisplay: '${_state.gammaGainDb.toStringAsFixed(1)} dB',
            value: _state.gammaGainDb,
            min: -26.0,
            max: -6.0,
            activeColor: AppColors.rose500,
            onChanged: (val) {
              setState(() => _state = _state.copyWith(gammaGainDb: val));
              _syncToDsp();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSolfeggioCard() {
    return NeuromorphicCard(
      title: _s.solfeggioCardTitle,
      subtitle: _s.solfeggioCardSub,
      borderColor: _state.solfeggio528Enabled ? AppColors.emerald500.withValues(alpha: 0.5) : null,
      trailing: Switch.adaptive(
        value: _state.solfeggio528Enabled,
        activeTrackColor: AppColors.emerald500,
        onChanged: (val) {
          setState(() => _state = _state.copyWith(
                solfeggio528Enabled: val,
                activePreset: NeuroAcousticPreset.custom,
              ));
          _syncToDsp();
        },
      ),
      child: Column(
        children: [
          ParameterSlider(
            label: _s.solfeggioDuckingLabel,
            valueDisplay: '${_state.solfeggioDuckingDb.toStringAsFixed(1)} dB',
            value: _state.solfeggioDuckingDb,
            min: -28.0,
            max: -12.0,
            activeColor: AppColors.emerald500,
            onChanged: (val) {
              setState(() => _state = _state.copyWith(solfeggioDuckingDb: val));
              _syncToDsp();
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.slate800.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_moon_outlined, size: 16, color: AppColors.emerald500),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _s.solfeggioNote,
                    style: const TextStyle(color: AppColors.slate400, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
