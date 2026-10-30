import 'dart:async';
import 'package:flutter/material.dart';
import '../../ffi/native_audio_bridge.dart';
import '../../i18n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'neuromorphic_card.dart';

/// Real-Time WASAPI Loopback Telemetry HUD & Channel Source Selector.
class LiveTelemetryHud extends StatefulWidget {
  final AppStrings strings;
  final bool isMasterPowerOn;
  final ValueChanged<bool> onPowerChanged;

  const LiveTelemetryHud({
    super.key,
    required this.strings,
    required this.isMasterPowerOn,
    required this.onPowerChanged,
  });

  @override
  State<LiveTelemetryHud> createState() => _LiveTelemetryHudState();
}

class _LiveTelemetryHudState extends State<LiveTelemetryHud> {
  Timer? _telemetryTimer;
  double _rmsLeft = 0.0;
  double _rmsRight = 0.0;
  int _totalFrames = 0;
  int _sourceMode = 0; // 0: WASAPI Smart, 1: WASAPI Full Wet, 2: 440Hz Pad, 3: LPF Noise

  @override
  void initState() {
    super.initState();
    // 30 FPS visual telemetry polling via Zero-Allocation FFI pointers
    _telemetryTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      if (!mounted) return;
      final telem = NativeAudioBridge.instance.getTelemetry();
      setState(() {
        _rmsLeft = telem.rmsLeft;
        _rmsRight = telem.rmsRight;
        _totalFrames = telem.totalFrames;
      });
    });
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    super.dispose();
  }

  void _changeSourceMode(int mode) {
    setState(() => _sourceMode = mode);
    NativeAudioBridge.instance.setLiveSourceMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final isPlaying = widget.isMasterPowerOn;
    final double normL = (_rmsLeft * 3.2).clamp(0.0, 1.0);
    final double normR = (_rmsRight * 3.2).clamp(0.0, 1.0);
    final double elapsedSec = _totalFrames / 48000.0;

    return NeuromorphicCard(
      title: s.telemetryTitle,
      subtitle: s.telemetrySub,
      borderColor: isPlaying ? AppColors.emerald500 : AppColors.slate700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source Mode Selector (WASAPI Loopback vs Internal Calibration)
          Text(
            s.sourceSelectorLabel,
            style: const TextStyle(
              color: AppColors.slate400,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              _buildSourceChip(s.modeWasapiSmart, 0, Icons.surround_sound),
              const SizedBox(width: AppSpacing.sm),
              _buildSourceChip(s.modeWasapiFull, 1, Icons.cable),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              _buildSourceChip(s.modePad440, 2, Icons.piano),
              const SizedBox(width: AppSpacing.sm),
              _buildSourceChip(s.modePinkNoise, 3, Icons.air),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Real-time VU Meter Bar Display
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.slate950,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.slate800),
            ),
            child: Column(
              children: [
                _buildVuBar('CH-L', normL, _rmsLeft, AppColors.cyan400),
                const SizedBox(height: AppSpacing.sm),
                _buildVuBar('CH-R', normR, _rmsRight, AppColors.violet500),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Live Counter & Diagnostics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isPlaying ? AppColors.emerald500 : AppColors.slate600,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        isPlaying ? s.dacActive : s.dacBypass,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isPlaying ? AppColors.emerald500 : AppColors.slate400,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${s.samplesProcessed}: $_totalFrames (${elapsedSec.toStringAsFixed(1)}s)',
                style: const TextStyle(
                  color: AppColors.slate400,
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceChip(String label, int mode, IconData icon) {
    final isSelected = _sourceMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => _changeSourceMode(mode),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.cyan500.withValues(alpha: 0.2)
                : AppColors.slate800.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: isSelected ? AppColors.cyan500 : AppColors.slate700,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isSelected ? AppColors.cyan400 : AppColors.slate400),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.slate400,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVuBar(String channel, double normValue, double rawRms, Color barColor) {
    return Row(
      children: [
        SizedBox(
          width: 45,
          child: Text(
            channel,
            style: const TextStyle(color: AppColors.slate400, fontSize: 11, fontFamily: 'monospace'),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                Container(height: 10, color: AppColors.slate800),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 30),
                  widthFactor: normValue,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          barColor.withValues(alpha: 0.6),
                          barColor,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 45,
          child: Text(
            '${(rawRms * 100).toInt()}%',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: normValue > 0.03 ? barColor : AppColors.slate600,
              fontSize: 11,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
