import 'package:flutter_test/flutter_test.dart';
import 'package:valora/data/models/expiry_status.dart';

void main() {
  group('ExpiryStatus Domain Logic & Date Boundaries', () {
    final referenceDate = DateTime(2026, 10, 8, 14, 30); // Reference: Oct 8, 2026 2:30 PM

    test('Unknown expiry returns ExpiryStatus.unknown and null remaining days', () {
      final status = ExpiryStatus.calculate(
        expiryDate: null,
        referenceDate: referenceDate,
      );
      final days = ExpiryStatus.daysRemaining(
        expiryDate: null,
        referenceDate: referenceDate,
      );

      expect(status, equals(ExpiryStatus.unknown));
      expect(days, isNull);
    });

    test('Item expiring today (same calendar date) is expiringToday, even late at night', () {
      // Midnight today
      final midnightToday = DateTime(2026, 10, 8, 0, 1);
      // Late night today
      final lateNightToday = DateTime(2026, 10, 8, 23, 59);

      final status1 = ExpiryStatus.calculate(
        expiryDate: midnightToday,
        referenceDate: referenceDate,
      );
      final status2 = ExpiryStatus.calculate(
        expiryDate: lateNightToday,
        referenceDate: referenceDate,
      );
      final days = ExpiryStatus.daysRemaining(
        expiryDate: midnightToday,
        referenceDate: referenceDate,
      );

      expect(status1, equals(ExpiryStatus.expiringToday));
      expect(status2, equals(ExpiryStatus.expiringToday));
      expect(days, equals(0));
    });

    test('Item expiring yesterday is expired with negative days', () {
      final yesterday = DateTime(2026, 10, 7, 18, 00);

      final status = ExpiryStatus.calculate(
        expiryDate: yesterday,
        referenceDate: referenceDate,
      );
      final days = ExpiryStatus.daysRemaining(
        expiryDate: yesterday,
        referenceDate: referenceDate,
      );

      expect(status, equals(ExpiryStatus.expired));
      expect(days, equals(-1));
    });

    test('Item expiring within warning threshold is expiringSoon', () {
      final in2Days = DateTime(2026, 10, 10, 10, 00);
      final in3Days = DateTime(2026, 10, 11, 10, 00);

      final status2 = ExpiryStatus.calculate(
        expiryDate: in2Days,
        referenceDate: referenceDate,
        warningThresholdDays: 3,
      );
      final status3 = ExpiryStatus.calculate(
        expiryDate: in3Days,
        referenceDate: referenceDate,
        warningThresholdDays: 3,
      );

      expect(status2, equals(ExpiryStatus.expiringSoon));
      expect(status3, equals(ExpiryStatus.expiringSoon));
      expect(ExpiryStatus.daysRemaining(expiryDate: in2Days, referenceDate: referenceDate), equals(2));
      expect(ExpiryStatus.daysRemaining(expiryDate: in3Days, referenceDate: referenceDate), equals(3));
    });

    test('Item beyond warning threshold is fresh', () {
      final in4Days = DateTime(2026, 10, 12, 10, 00);

      final status = ExpiryStatus.calculate(
        expiryDate: in4Days,
        referenceDate: referenceDate,
        warningThresholdDays: 3,
      );

      expect(status, equals(ExpiryStatus.fresh));
      expect(ExpiryStatus.daysRemaining(expiryDate: in4Days, referenceDate: referenceDate), equals(4));
    });

    test('Custom threshold of 7 days classifies 5-day item as expiringSoon', () {
      final in5Days = DateTime(2026, 10, 13);

      final defaultThreshold = ExpiryStatus.calculate(
        expiryDate: in5Days,
        referenceDate: referenceDate,
        warningThresholdDays: 3,
      );
      final customThreshold = ExpiryStatus.calculate(
        expiryDate: in5Days,
        referenceDate: referenceDate,
        warningThresholdDays: 7,
      );

      expect(defaultThreshold, equals(ExpiryStatus.fresh));
      expect(customThreshold, equals(ExpiryStatus.expiringSoon));
    });
  });
}
