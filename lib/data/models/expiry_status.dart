import 'package:flutter/material.dart';
import 'package:valora/l10n/generated/app_localizations.dart';
import '../../core/theme/app_colors.dart';

enum ExpiryStatus {
  expired,
  expiringToday,
  expiringSoon,
  fresh,
  unknown;

  /// Determines the [ExpiryStatus] by comparing normalized local calendar dates.
  ///
  /// - An item expiring today ([diffDays] == 0) is never marked as expired,
  ///   even if the current clock time is late in the evening.
  /// - [warningThresholdDays] defaults to 3 days (configurable in settings).
  /// - An item with null [expiryDate] is always [ExpiryStatus.unknown].
  static ExpiryStatus calculate({
    required DateTime? expiryDate,
    DateTime? referenceDate,
    int warningThresholdDays = 3,
  }) {
    if (expiryDate == null) {
      return ExpiryStatus.unknown;
    }

    final ref = referenceDate ?? DateTime.now();
    final todayUtc = DateTime.utc(ref.year, ref.month, ref.day);
    final expiryUtc = DateTime.utc(expiryDate.year, expiryDate.month, expiryDate.day);

    final diffDays = expiryUtc.difference(todayUtc).inDays;

    if (diffDays < 0) {
      return ExpiryStatus.expired;
    } else if (diffDays == 0) {
      return ExpiryStatus.expiringToday;
    } else if (diffDays <= warningThresholdDays) {
      return ExpiryStatus.expiringSoon;
    } else {
      return ExpiryStatus.fresh;
    }
  }

  /// Calculates exact remaining calendar days from [referenceDate] (defaults to now).
  /// Returns null if [expiryDate] is unknown.
  static int? daysRemaining({
    required DateTime? expiryDate,
    DateTime? referenceDate,
  }) {
    if (expiryDate == null) return null;
    final ref = referenceDate ?? DateTime.now();
    final todayUtc = DateTime.utc(ref.year, ref.month, ref.day);
    final expiryUtc = DateTime.utc(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiryUtc.difference(todayUtc).inDays;
  }

  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case ExpiryStatus.expired:
        return l10n.statusExpired;
      case ExpiryStatus.expiringToday:
        return l10n.statusExpiringToday;
      case ExpiryStatus.expiringSoon:
        return l10n.statusExpiringSoon;
      case ExpiryStatus.fresh:
        return l10n.statusFresh;
      case ExpiryStatus.unknown:
        return l10n.statusUnknown;
    }
  }

  Color get badgeColor {
    switch (this) {
      case ExpiryStatus.expired:
        return AppColors.statusExpired;
      case ExpiryStatus.expiringToday:
        return AppColors.statusExpiringToday;
      case ExpiryStatus.expiringSoon:
        return AppColors.statusExpiringSoon;
      case ExpiryStatus.fresh:
        return AppColors.statusFresh;
      case ExpiryStatus.unknown:
        return AppColors.statusUnknown;
    }
  }

  Color badgeBackgroundColor(bool isDark) {
    if (isDark) {
      switch (this) {
        case ExpiryStatus.expired:
          return AppColors.statusExpiredBgDark;
        case ExpiryStatus.expiringToday:
          return AppColors.statusExpiringTodayBgDark;
        case ExpiryStatus.expiringSoon:
          return AppColors.statusExpiringSoonBgDark;
        case ExpiryStatus.fresh:
          return AppColors.statusFreshBgDark;
        case ExpiryStatus.unknown:
          return AppColors.statusUnknownBgDark;
      }
    } else {
      switch (this) {
        case ExpiryStatus.expired:
          return AppColors.statusExpiredBg;
        case ExpiryStatus.expiringToday:
          return AppColors.statusExpiringTodayBg;
        case ExpiryStatus.expiringSoon:
          return AppColors.statusExpiringSoonBg;
        case ExpiryStatus.fresh:
          return AppColors.statusFreshBg;
        case ExpiryStatus.unknown:
          return AppColors.statusUnknownBg;
      }
    }
  }

  IconData get icon {
    switch (this) {
      case ExpiryStatus.expired:
        return Icons.error_outline_rounded;
      case ExpiryStatus.expiringToday:
        return Icons.warning_amber_rounded;
      case ExpiryStatus.expiringSoon:
        return Icons.alarm_rounded;
      case ExpiryStatus.fresh:
        return Icons.check_circle_outline_rounded;
      case ExpiryStatus.unknown:
        return Icons.help_outline_rounded;
    }
  }
}
