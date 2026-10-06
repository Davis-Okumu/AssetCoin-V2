import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.elevation = 0,
    this.color,
    this.border,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double elevation;
  final Color? color;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border:
            border ??
            Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.7),
            ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  blurRadius: elevation * 2,
                  offset: Offset(0, elevation),
                  color: Colors.black.withValues(alpha: 0.06),
                ),
              ]
            : null,
      ),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );
  }
}
