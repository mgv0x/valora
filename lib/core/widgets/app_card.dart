import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderSide? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final defaultBorder = BorderSide(
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      width: 1,
    );

    return Material(
      color: backgroundColor ?? defaultBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: border ?? defaultBorder,
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              splashColor: AppColors.primarySage.withValues(alpha: 0.1),
              highlightColor: AppColors.primarySage.withValues(alpha: 0.05),
              child: Padding(
                padding: padding ?? EdgeInsets.zero,
                child: child,
              ),
            )
          : Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
    );
  }
}
