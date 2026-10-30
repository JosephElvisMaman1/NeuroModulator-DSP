import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable modular container card with frosted glass & sleek border styling.
class NeuromorphicCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  const NeuromorphicCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.borderColor,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.slate900.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: borderColor ?? AppColors.slate700.withValues(alpha: 0.5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2.0),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: AppColors.slate400,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          child,
        ],
      ),
    );
  }
}
