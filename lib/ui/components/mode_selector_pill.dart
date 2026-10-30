import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Interactive Pill Button for Mode Selection (Preset Chips)
class ModeSelectorPill extends StatelessWidget {
  final String label;
  final String frequencyTag;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const ModeSelectorPill({
    super.key,
    required this.label,
    required this.frequencyTag,
    required this.isSelected,
    required this.onTap,
    this.accentColor = AppColors.cyan500,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.18)
              : AppColors.slate800.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? accentColor : AppColors.slate700,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.25),
                    blurRadius: 10.0,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.slate400,
                fontSize: 13.0,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              frequencyTag,
              style: TextStyle(
                color: isSelected ? accentColor : AppColors.slate600,
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
