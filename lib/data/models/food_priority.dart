import 'food_item.dart';
import 'expiry_status.dart';
import '../../core/utils/text_utils.dart';

/// Intelligent local prioritization of pantry foods.
///
/// Classifies active foods into human-readable urgency tiers so the user
/// knows what to consume first. The calculation is 100% offline and derived
/// exclusively from real stored data:
///
/// - Expiry date compared against today using normalized local calendar dates
///   (never marks an item expiring today as expired, regardless of clock time).
/// - Remaining quantity (items with nothing left are never prioritized).
/// - Lifecycle status (consumed, discarded and archived items are excluded).
/// - Foods without an expiry date are never treated as expired or urgent.
enum FoodPriority {
  /// Expiry date has already passed (negative remaining days).
  expired,

  /// Expiry date is today's calendar date (0 days remaining).
  consumeToday,

  /// Expires within the next 3 days (1..3 days remaining).
  highPriority,

  /// Expires within the next 7 days (4..7 days remaining).
  attention,

  /// Expires further in the future (more than 7 days).
  onTrack,

  /// No expiry date informed — never considered expired nor urgent.
  unknownExpiry;

  /// Classification ordering used when ranking by urgency.
  /// Lower values must be consumed first. Non-urgent tiers (onTrack,
  /// unknownExpiry) sort after all urgent tiers.
  int get urgencyRank {
    switch (this) {
      case FoodPriority.expired:
        return 0;
      case FoodPriority.consumeToday:
        return 1;
      case FoodPriority.highPriority:
        return 2;
      case FoodPriority.attention:
        return 3;
      case FoodPriority.onTrack:
        return 4;
      case FoodPriority.unknownExpiry:
        return 5;
    }
  }

  /// Whether this tier requires user attention ("Consume first" section).
  bool get isUrgent {
    return this == FoodPriority.expired ||
        this == FoodPriority.consumeToday ||
        this == FoodPriority.highPriority ||
        this == FoodPriority.attention;
  }

  /// Upper bound (in remaining days) of the tier, or null when unbounded.
  int? get maxDaysRemaining {
    switch (this) {
      case FoodPriority.expired:
        return null;
      case FoodPriority.consumeToday:
        return 0;
      case FoodPriority.highPriority:
        return 3;
      case FoodPriority.attention:
        return 7;
      case FoodPriority.onTrack:
      case FoodPriority.unknownExpiry:
        return null;
    }
  }
}

/// A food item paired with its calculated priority and remaining days.
class PrioritizedFood {
  final FoodItem item;
  final FoodPriority priority;
  final int? daysRemaining;

  const PrioritizedFood({
    required this.item,
    required this.priority,
    required this.daysRemaining,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrioritizedFood &&
          runtimeType == other.runtimeType &&
          item == other.item &&
          priority == other.priority &&
          daysRemaining == other.daysRemaining;

  @override
  int get hashCode => item.hashCode ^ priority.hashCode ^ daysRemaining.hashCode;

  @override
  String toString() =>
      'PrioritizedFood(item: ${item.name}, priority: ${priority.name}, daysRemaining: $daysRemaining)';
}

/// Kinds of insight messages derived from real pantry data.
///
/// The UI maps each kind to a localized message; counts always come from the
/// actual item list, never fabricated.
enum PriorityInsightKind {
  /// No food needs urgent attention.
  noneUrgent,

  /// At least one item is already expired.
  expired,

  /// At least one item expires today.
  expiringToday,

  /// At least one item expires tomorrow (and nothing is expired/today).
  expiringTomorrow,

  /// Urgent items exist but none is expired/today/tomorrow.
  generalPriority,
}

/// Aggregated insight for the "Consume first" section.
class PriorityInsight {
  final PriorityInsightKind kind;
  final int expiredCount;
  final int expiringTodayCount;
  final int expiringTomorrowCount;
  final int urgentCount;

  const PriorityInsight({
    required this.kind,
    required this.expiredCount,
    required this.expiringTodayCount,
    required this.expiringTomorrowCount,
    required this.urgentCount,
  });

  static const PriorityInsight empty = PriorityInsight(
    kind: PriorityInsightKind.noneUrgent,
    expiredCount: 0,
    expiringTodayCount: 0,
    expiringTomorrowCount: 0,
    urgentCount: 0,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriorityInsight &&
          runtimeType == other.runtimeType &&
          kind == other.kind &&
          expiredCount == other.expiredCount &&
          expiringTodayCount == other.expiringTodayCount &&
          expiringTomorrowCount == other.expiringTomorrowCount &&
          urgentCount == other.urgentCount;

  @override
  int get hashCode =>
      kind.hashCode ^
      expiredCount.hashCode ^
      expiringTodayCount.hashCode ^
      expiringTomorrowCount.hashCode ^
      urgentCount.hashCode;

  @override
  String toString() =>
      'PriorityInsight(kind: ${kind.name}, expired: $expiredCount, today: $expiringTodayCount, tomorrow: $expiringTomorrowCount, urgent: $urgentCount)';
}

/// Pure, offline calculator for food prioritization.
abstract class FoodPriorityCalculator {
  /// High priority upper bound: items expiring within 3 days.
  static const int highPriorityDays = 3;

  /// Attention upper bound: items expiring within 7 days.
  static const int attentionDays = 7;

  /// Classifies a single food item relative to [referenceDate]
  /// (defaults to the current local date).
  ///
  /// Date comparison uses normalized local calendar dates so time-of-day and
  /// timezone offsets never shift the result by a day. Items without an expiry
  /// date are classified as [FoodPriority.unknownExpiry], never as expired.
  static FoodPriority classify(
    FoodItem item, {
    DateTime? referenceDate,
  }) {
    if (item.expiryDate == null) {
      return FoodPriority.unknownExpiry;
    }
    final days = ExpiryStatus.daysRemaining(
      expiryDate: item.expiryDate,
      referenceDate: referenceDate,
    );
    return classifyFromDays(days);
  }

  /// Maps a remaining-days value to its priority tier.
  static FoodPriority classifyFromDays(int? daysRemaining) {
    if (daysRemaining == null) {
      return FoodPriority.unknownExpiry;
    }
    if (daysRemaining < 0) {
      return FoodPriority.expired;
    }
    if (daysRemaining == 0) {
      return FoodPriority.consumeToday;
    }
    if (daysRemaining <= highPriorityDays) {
      return FoodPriority.highPriority;
    }
    if (daysRemaining <= attentionDays) {
      return FoodPriority.attention;
    }
    return FoodPriority.onTrack;
  }

  /// Filters active items that require attention and ranks them by urgency:
  ///
  /// 1. Priority tier (expired → today → high priority → attention).
  /// 2. Fewer days remaining first (expired items: most overdue first).
  /// 3. Larger remaining quantity first (more food at stake).
  /// 4. Alphabetical name as a deterministic final tie-break.
  ///
  /// Consumed, discarded, archived and fully depleted items are excluded,
  /// as are items without urgency (on track / unknown expiry).
  static List<PrioritizedFood> consumeFirst(
    List<FoodItem> items, {
    DateTime? referenceDate,
  }) {
    final result = <PrioritizedFood>[];
    for (final item in items) {
      if (!item.isActive) continue;
      final priority = classify(item, referenceDate: referenceDate);
      if (!priority.isUrgent) continue;
      result.add(PrioritizedFood(
        item: item,
        priority: priority,
        daysRemaining: ExpiryStatus.daysRemaining(
          expiryDate: item.expiryDate,
          referenceDate: referenceDate,
        ),
      ));
    }
    result.sort(_compareByUrgency);
    return result;
  }

  /// Builds an insight summary from a ranked "consume first" list.
  ///
  /// The most severe situation wins: expired → expiring today → expiring
  /// tomorrow → general priority. An empty list yields [PriorityInsightKind.noneUrgent].
  static PriorityInsight buildInsight(List<PrioritizedFood> ranked) {
    if (ranked.isEmpty) {
      return PriorityInsight.empty;
    }

    var expired = 0;
    var today = 0;
    var tomorrow = 0;
    for (final pf in ranked) {
      switch (pf.priority) {
        case FoodPriority.expired:
          expired++;
          break;
        case FoodPriority.consumeToday:
          today++;
          break;
        case FoodPriority.highPriority:
          if (pf.daysRemaining == 1) tomorrow++;
          break;
        default:
          break;
      }
    }

    PriorityInsightKind kind;
    if (expired > 0) {
      kind = PriorityInsightKind.expired;
    } else if (today > 0) {
      kind = PriorityInsightKind.expiringToday;
    } else if (tomorrow > 0) {
      kind = PriorityInsightKind.expiringTomorrow;
    } else {
      kind = PriorityInsightKind.generalPriority;
    }

    return PriorityInsight(
      kind: kind,
      expiredCount: expired,
      expiringTodayCount: today,
      expiringTomorrowCount: tomorrow,
      urgentCount: ranked.length,
    );
  }

  static int _compareByUrgency(PrioritizedFood a, PrioritizedFood b) {
    final rankCompare = a.priority.urgencyRank.compareTo(b.priority.urgencyRank);
    if (rankCompare != 0) return rankCompare;

    // Within a tier: fewer days remaining first. For expired items days are
    // negative, so this places the most overdue item first.
    const maxDaysFallback = 999999999;
    final aDays = a.daysRemaining ?? maxDaysFallback;
    final bDays = b.daysRemaining ?? maxDaysFallback;
    final daysCompare = aDays.compareTo(bDays);
    if (daysCompare != 0) return daysCompare;

    // More remaining quantity first (greater amount of food at risk).
    final qtyCompare = b.item.remainingQuantity.compareTo(a.item.remainingQuantity);
    if (qtyCompare != 0) return qtyCompare;

    final nameCompare = TextUtils.normalize(a.item.name).compareTo(TextUtils.normalize(b.item.name));
    if (nameCompare != 0) return nameCompare;
    return a.item.id.compareTo(b.item.id);
  }
}
