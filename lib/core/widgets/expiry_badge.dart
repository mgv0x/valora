import 'package:flutter/material.dart';
import 'package:valora/l10n/generated/app_localizations.dart';
import '../../data/models/expiry_status.dart';

class ExpiryBadge extends StatelessWidget {
  final ExpiryStatus status;
  final int? daysRemaining;
  final bool compact;

  const ExpiryBadge({
    super.key,
    required this.status,
    this.daysRemaining,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = status.badgeColor;
    final bgColor = status.badgeBackgroundColor(isDark);

    String text;
    if (daysRemaining != null) {
      if (daysRemaining! < 0) {
        text = l10n != null ? l10n.daysAgo(daysRemaining!.abs()) : '${daysRemaining!.abs()}d ago';
      } else if (daysRemaining == 0) {
        text = l10n?.statusExpiringToday ?? 'Hoje';
      } else {
        text = l10n != null ? l10n.daysLeft(daysRemaining!) : '$daysRemaining d';
      }
    } else {
      text = l10n != null ? status.localizedLabel(l10n) : status.name;
    }

    return Semantics(
      label: 'Expiry status: $text',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 3 : 5,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: fgColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              status.icon,
              size: compact ? 12 : 14,
              color: fgColor,
            ),
            const SizedBox(width: 5),
            Text(
              text,
              style: TextStyle(
                color: fgColor,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
