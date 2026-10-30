import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Precision parameter slider component with real-time value pill.
class ParameterSlider extends StatelessWidget {
  final String label;
  final String valueDisplay;
  final double value;
  final double min;
  final double max;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  const ParameterSlider({
    super.key,
    required this.label,
    required this.valueDisplay,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.activeColor = AppColors.cyan500,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.slate200,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: activeColor.withValues(alpha: 0.4),
                  width: 1.0,
                ),
              ),
              child: Text(
                valueDisplay,
                style: TextStyle(
                  color: activeColor,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4.0,
            activeTrackColor: activeColor,
            inactiveTrackColor: AppColors.slate700,
            thumbColor: AppColors.white,
            overlayColor: activeColor.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
