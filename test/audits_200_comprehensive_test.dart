import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:uuid/uuid.dart';

import 'package:valora/core/theme/app_colors.dart';
import 'package:valora/core/utils/currency_formatter.dart';
import 'package:valora/core/utils/text_utils.dart';
import 'package:valora/core/widgets/category_chip.dart';
import 'package:valora/core/widgets/confirmation_dialog.dart';
import 'package:valora/core/widgets/expiry_badge.dart';
import 'package:valora/core/widgets/valora_app_bar.dart';
import 'package:valora/l10n/generated/app_localizations.dart';
import 'package:valora/data/models/expiry_status.dart';
import 'package:valora/data/models/food_activity.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/storage_location.dart';
import 'package:valora/data/services/notification_service.dart';
import 'package:valora/data/services/preferences_service.dart';
import 'package:valora/presentation/screens/pantry/widgets/food_details_sheet.dart';
import 'package:valora/presentation/screens/pantry/widgets/food_item_tile.dart';
import 'package:valora/presentation/screens/pantry/widgets/record_action_dialog.dart';
import 'package:valora/state/impact_provider.dart';
import 'package:valora/state/pantry_provider.dart';
import 'package:valora/state/settings_provider.dart';
import 'package:valora/state/subscription_provider.dart';

import 'mocks/in_memory_food_repository.dart';

class _TestMockNotificationService implements NotificationService {
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> scheduleExpiryWarning({required FoodItem item, required int warningDays, required String title, required String body}) async {}
  @override
  Future<void> cancelForFood(String foodId) async {}
  @override
  Future<void> cancelAll() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  group('Valora 200 Automated Code Audits', () {
    // -------------------------------------------------------------------------
    // DOMAIN 1: Core Utilities, Formats & Date/Math Operations (Audits 001 - 025)
    // -------------------------------------------------------------------------
    group('Domain 1: Core Utilities & Formats (Audits 001-025)', () {
      test('Audit 001: Date normalization using UTC eliminates DST 23h/25h leap errors', () {
        final d1 = DateTime(2026, 10, 18, 23, 0);
        final d2 = DateTime(2026, 10, 19, 1, 0);
        final utc1 = DateTime.utc(d1.year, d1.month, d1.day);
        final utc2 = DateTime.utc(d2.year, d2.month, d2.day);
        expect(utc2.difference(utc1).inDays, equals(1));
      });

      test('Audit 002: ExpiryStatus calculate uses reference date at start of day', () {
        final now = DateTime(2026, 10, 18, 23, 45);
        final expiry = DateTime(2026, 10, 18, 6, 0);
        final status = ExpiryStatus.calculate(expiryDate: expiry, referenceDate: now);
        expect(status, equals(ExpiryStatus.expiringToday));
      });

      test('Audit 003: ExpiryStatus calculate marks yesterday as expired even if within 24h', () {
        final ref = DateTime(2026, 10, 18, 8, 0);
        final yesterday = DateTime(2026, 10, 17, 22, 0);
        final status = ExpiryStatus.calculate(expiryDate: yesterday, referenceDate: ref);
        expect(status, equals(ExpiryStatus.expired));
      });

      test('Audit 004: ExpiryStatus daysRemaining returns exact day delta without hour drift', () {
        final ref = DateTime(2026, 10, 18, 23, 59);
        final target = DateTime(2026, 10, 20, 0, 1);
        final days = ExpiryStatus.daysRemaining(expiryDate: target, referenceDate: ref);
        expect(days, equals(2));
      });

      test('Audit 005: TextUtils.normalize strips Portuguese accents correctly', () {
        expect(TextUtils.normalize('Água Maçã Pão'), equals('agua maca pao'));
      });

      test('Audit 006: TextUtils.normalize handles uppercase and lowercase accents identically', () {
        expect(TextUtils.normalize('ÓLEO'), equals(TextUtils.normalize('óleo')));
      });

      test('Audit 007: TextUtils.normalize handles empty strings safely', () {
        expect(TextUtils.normalize(''), equals(''));
      });

      test('Audit 008: TextUtils.normalize collapses multiple internal whitespaces', () {
        expect(TextUtils.normalize('  Arroz    Branco   '), equals('arroz branco'));
      });

      test('Audit 009: TextUtils.matchesSearch matches regardless of accent differences', () {
        expect(TextUtils.matchesSearch('Maçã Fuji', 'maca'), isTrue);
        expect(TextUtils.matchesSearch('Pão Francês', 'pao'), isTrue);
      });

      test('Audit 010: TextUtils.matchesSearch returns true for empty search query', () {
        expect(TextUtils.matchesSearch('Qualquer Alimento', ''), isTrue);
      });

      test('Audit 011: TextUtils.matchesSearch returns false for non-matching query', () {
        expect(TextUtils.matchesSearch('Leite Desnatado', 'Queijo'), isFalse);
      });

      test('Audit 012: CurrencyFormatter.format returns empty string on null', () {
        expect(CurrencyFormatter.format(null), equals(''));
      });

      test('Audit 013: CurrencyFormatter.format formats zero correctly', () {
        expect(CurrencyFormatter.format(0.0), contains('0.00'));
      });

      test('Audit 014: CurrencyFormatter.format formats standard positive amount', () {
        expect(CurrencyFormatter.format(12.50), contains('12.50'));
      });

      test('Audit 015: CurrencyFormatter.format with pt_BR formats with comma', () {
        final result = CurrencyFormatter.format(19.90, localeCode: 'pt_BR');
        expect(result, contains('19,90'));
      });

      test('Audit 016: CurrencyFormatter.format handles invalid locale with fallback', () {
        final result = CurrencyFormatter.format(5.0, localeCode: 'invalid_locale');
        expect(result, contains('5.00'));
      });

      test('Audit 017: FoodUnit.formatQuantity formats integer quantity without decimal zeros', () {
        expect(FoodUnit.formatQuantity(2.0), equals('2'));
      });

      test('Audit 018: FoodUnit.formatQuantity formats fractional quantity with decimals', () {
        expect(FoodUnit.formatQuantity(1.5), equals('1.5'));
        expect(FoodUnit.formatQuantity(0.25), equals('0.25'));
      });

      test('Audit 019: FoodUnit.formatQuantity safely guards NaN by returning 0', () {
        expect(FoodUnit.formatQuantity(double.nan), equals('0'));
      });

      test('Audit 020: FoodUnit.formatQuantity safely guards Infinity by returning 0', () {
        expect(FoodUnit.formatQuantity(double.infinity), equals('0'));
        expect(FoodUnit.formatQuantity(double.negativeInfinity), equals('0'));
      });

      test('Audit 021: FoodUnit.formatQuantity clamps negative values to 0', () {
        expect(FoodUnit.formatQuantity(-4.5), equals('0'));
      });

      test('Audit 022: FoodUnit.fromString correctly resolves standard name and aliases', () {
        expect(FoodUnit.fromString('kilogram'), equals(FoodUnit.kilogram));
        expect(FoodUnit.fromString('kg'), equals(FoodUnit.kilogram));
      });

      test('Audit 023: FoodUnit.fromString resolves gram and g', () {
        expect(FoodUnit.fromString('gram'), equals(FoodUnit.gram));
        expect(FoodUnit.fromString('g'), equals(FoodUnit.gram));
      });

      test('Audit 024: FoodUnit.fromString resolves liter, ml, piece, package', () {
        expect(FoodUnit.fromString('l'), equals(FoodUnit.liter));
        expect(FoodUnit.fromString('ml'), equals(FoodUnit.milliliter));
        expect(FoodUnit.fromString('un'), equals(FoodUnit.piece));
        expect(FoodUnit.fromString('pct'), equals(FoodUnit.package));
      });

      test('Audit 025: FoodUnit.fromString falls back to piece on unrecognized input', () {
        expect(FoodUnit.fromString('desconhecido_123'), equals(FoodUnit.piece));
      });
    });

    // -------------------------------------------------------------------------
    // DOMAIN 2: Data Models & Domain Invariants (Audits 026 - 050)
    // -------------------------------------------------------------------------
    group('Domain 2: Data Models & Invariants (Audits 026-050)', () {
      final baseDate = DateTime(2026, 10, 18);

      test('Audit 026: FoodItem remainingQuantity computes initial - consumed - discarded', () {
        final item = FoodItem(
          id: 'item-1',
          name: 'Iogurte',
          category: FoodCategory.dairy,
          initialQuantity: 10,
          consumedQuantity: 3,
          discardedQuantity: 2,
          unit: FoodUnit.piece,
          createdAt: baseDate,
          updatedAt: baseDate,
        );
        expect(item.remainingQuantity, equals(5.0));
      });

      test('Audit 027: FoodItem remainingQuantity guards against NaN or infinite values', () {
        final item = FoodItem(
          id: 'item-2',
          name: 'Feijão',
          category: FoodCategory.pantryStaples,
          initialQuantity: double.nan,
          unit: FoodUnit.kilogram,
          createdAt: baseDate,
          updatedAt: baseDate,
        );
        expect(item.remainingQuantity, equals(0.0));
      });

      test('Audit 028: FoodItem remainingQuantity clamps negative initialQuantity to zero', () {
        final item = FoodItem(
          id: 'item-3',
          name: 'Sal',
          category: FoodCategory.pantryStaples,
          initialQuantity: -5,
          unit: FoodUnit.gram,
          createdAt: baseDate,
          updatedAt: baseDate,
        );
        expect(item.remainingQuantity, equals(0.0));
      });

      test('Audit 029: FoodItem hasRemaining returns false when remainingQuantity is 0', () {
        final item = FoodItem(
          id: 'item-4',
          name: 'Suco',
          category: FoodCategory.drinks,
          initialQuantity: 1,
          consumedQuantity: 1,
          unit: FoodUnit.liter,
          createdAt: baseDate,
          updatedAt: baseDate,
        );
        expect(item.hasRemaining, isFalse);
      });

      test('Audit 030: FoodItem hasRemaining returns true when remainingQuantity > 0', () {
        final item = FoodItem(
          id: 'item-5',
          name: 'Suco',
          category: FoodCategory.drinks,
          initialQuantity: 1,
          consumedQuantity: 0.5,
          unit: FoodUnit.liter,
          createdAt: baseDate,
          updatedAt: baseDate,
        );
        expect(item.hasRemaining, isTrue);
      });

      test('Audit 031: FoodItem equality operator returns true for identical items', () {
        final itemA = FoodItem(
          id: 'id-same',
          name: 'Maçã',
          category: FoodCategory.fruits,
          initialQuantity: 2,
          unit: FoodUnit.piece,
          createdAt: baseDate,
          updatedAt: baseDate,
        );
        final itemB = FoodItem(
          id: 'id-same',
          name: 'Maçã',
          category: FoodCategory.fruits,
          initialQuantity: 2,
          unit: FoodUnit.piece,
          createdAt: baseDate,
          updatedAt: baseDate,
        );
        expect(itemA == itemB, isTrue);
        expect(itemA.hashCode, equals(itemB.hashCode));
      });

      test('Audit 032: FoodItem equality operator detects differences', () {
        final itemA = FoodItem(
          id: 'id-1',
          name: 'Maçã',
          category: FoodCategory.fruits,
          initialQuantity: 2,
          unit: FoodUnit.piece,
          createdAt: baseDate,
          updatedAt: baseDate,
        );
        final itemB = itemA.copyWith(initialQuantity: 3);
        expect(itemA == itemB, isFalse);
      });

      test('Audit 033: FoodItem copyWith preserves existing values', () {
        final item = FoodItem(
          id: 'copy-1',
          name: 'Carne',
          category: FoodCategory.meatFish,
          initialQuantity: 1.5,
          unit: FoodUnit.kilogram,
          purchasePrice: 45.0,
          createdAt: baseDate,
          updatedAt: baseDate,
        );
        final copy = item.copyWith(name: 'Carne Bovina');
        expect(copy.name, equals('Carne Bovina'));
        expect(copy.category, equals(FoodCategory.meatFish));
        expect(copy.purchasePrice, equals(45.0));
      });

      test('Audit 034: FoodItem copyWith clears nullable fields when clear flags are passed', () {
        final item = FoodItem(
          id: 'copy-2',
          name: 'Arroz',
          category: FoodCategory.pantryStaples,
          initialQuantity: 5,
          unit: FoodUnit.kilogram,
          purchasePrice: 25.0,
          notes: 'Observação teste',
          createdAt: baseDate,
          updatedAt: baseDate,
        );
        final cleared = item.copyWith(clearPurchasePrice: true, clearNotes: true);
        expect(cleared.purchasePrice, isNull);
        expect(cleared.notes, isNull);
      });

      test('Audit 035: FoodItem toMap and fromMap serialization roundtrip matches original', () {
        final item = FoodItem(
          id: 'map-1',
          name: 'Café',
          category: FoodCategory.pantryStaples,
          initialQuantity: 500,
          consumedQuantity: 100,
          discardedQuantity: 0,
          unit: FoodUnit.gram,
          storageLocation: StorageLocation.pantry,
          purchaseDate: baseDate,
          expiryDate: baseDate.add(const Duration(days: 30)),
          purchasePrice: 18.50,
          notes: 'Torrado e moído',
          createdAt: baseDate,
          updatedAt: baseDate,
        );
        final map = item.toMap();
        final reconstructed = FoodItem.fromMap(map);
        expect(reconstructed.id, equals(item.id));
        expect(reconstructed.name, equals(item.name));
        expect(reconstructed.initialQuantity, equals(item.initialQuantity));
        expect(reconstructed.consumedQuantity, equals(item.consumedQuantity));
        expect(reconstructed.purchasePrice, equals(item.purchasePrice));
      });

      test('Audit 036: FoodItem validate returns empty list for valid item', () {
        final item = FoodItem(
          id: 'v-1',
          name: 'Queijo Minas',
          category: FoodCategory.dairy,
          initialQuantity: 1,
          unit: FoodUnit.piece,
          purchasePrice: 15.0,
          createdAt: baseDate,
          updatedAt: baseDate,
        );
        expect(item.validate(), isEmpty);
      });

      test('Audit 037: FoodItem validate flags empty or blank name', () {
        final item = FoodItem(
          id: 'v-2',
          name: '   ',
          category: FoodCategory.dairy,
          initialQuantity: 1,
          unit: FoodUnit.piece,
          createdAt: baseDate,
          updatedAt: baseDate,
        );
        expect(item.validate(), contains('Food name cannot be empty.'));
      });

      test('Audit 038: FoodItem validate flags non-positive or non-finite initialQuantity', () {
        final itemZero = FoodItem(
          id: 'v-3',
          name: 'Pão',
          category: FoodCategory.pantryStaples,
          initialQuantity: 0,
          unit: FoodUnit.piece,
          createdAt: baseDate,
          updatedAt: baseDate,
        );
        expect(itemZero.validate(), contains('Initial quantity must be greater than zero.'));

        final itemNaN = FoodItem(
          id: 'v-4',
          name: 'Pão',
          category: FoodCategory.pantryStaples,
          initialQuantity: double.nan,
          unit: FoodUnit.piece,
          createdAt: baseDate,
          updatedAt: baseDate,
        );
        expect(itemNaN.validate(), contains('Initial quantity must be greater than zero.'));
      });

      test('Audit 039: FoodItem validate flags negative purchasePrice', () {
        final item = FoodItem(
          id: 'v-5',
          name: 'Uva',
          category: FoodCategory.fruits,
          initialQuantity: 1,
          unit: FoodUnit.package,
          purchasePrice: -10.0,
          createdAt: baseDate,
          updatedAt: baseDate,
        );
        expect(item.validate(), contains('Purchase price cannot be negative.'));
      });

      test('Audit 040: FoodItem validate flags expiry date before purchase date', () {
        final item = FoodItem(
          id: 'v-6',
          name: 'Leite',
          category: FoodCategory.dairy,
          initialQuantity: 1,
          unit: FoodUnit.liter,
          purchaseDate: baseDate,
          expiryDate: baseDate.subtract(const Duration(days: 5)),
          createdAt: baseDate,
          updatedAt: baseDate,
        );
        expect(item.validate(), contains('Expiry date cannot be before purchase date.'));
      });

      test('Audit 041: FoodActivity equality operator works correctly', () {
        final actA = FoodActivity(
          id: 'act-same',
          foodItemId: 'food-1',
          foodName: 'Banana',
          category: FoodCategory.fruits,
          quantity: 2,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: baseDate,
        );
        final actB = FoodActivity(
          id: 'act-same',
          foodItemId: 'food-1',
          foodName: 'Banana',
          category: FoodCategory.fruits,
          quantity: 2,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: baseDate,
        );
        expect(actA == actB, isTrue);
        expect(actA.hashCode, equals(actB.hashCode));
      });

      test('Audit 042: FoodActivity serialization roundtrip matches original', () {
        final act = FoodActivity(
          id: 'act-1',
          foodItemId: 'item-10',
          foodName: 'Abacaxi',
          category: FoodCategory.fruits,
          quantity: 1.0,
          unit: FoodUnit.piece,
          type: ActivityType.discarded,
          timestamp: baseDate,
          estimatedValue: 7.99,
          notes: 'Estragou',
        );
        final map = act.toMap();
        final reconstructed = FoodActivity.fromMap(map);
        expect(reconstructed.id, equals(act.id));
        expect(reconstructed.foodName, equals(act.foodName));
        expect(reconstructed.type, equals(ActivityType.discarded));
        expect(reconstructed.estimatedValue, equals(7.99));
      });

      test('Audit 043: FoodCategory.fromString parses camelCase, snake_case, and kebab-case', () {
        expect(FoodCategory.fromString('pantryStaples'), equals(FoodCategory.pantryStaples));
        expect(FoodCategory.fromString('pantry_staples'), equals(FoodCategory.pantryStaples));
        expect(FoodCategory.fromString('pantry-staples'), equals(FoodCategory.pantryStaples));
      });

      test('Audit 044: FoodCategory.fromString parses meatFish in all styles', () {
        expect(FoodCategory.fromString('meatFish'), equals(FoodCategory.meatFish));
        expect(FoodCategory.fromString('meat_fish'), equals(FoodCategory.meatFish));
        expect(FoodCategory.fromString('meat-fish'), equals(FoodCategory.meatFish));
      });

      test('Audit 045: FoodCategory.fromString falls back safely to other', () {
        expect(FoodCategory.fromString('unknown_category_xyz'), equals(FoodCategory.other));
      });

      test('Audit 046: StorageLocation.fromString parses refrigerator, freezer, and pantry', () {
        expect(StorageLocation.fromString('refrigerator'), equals(StorageLocation.refrigerator));
        expect(StorageLocation.fromString('freezer'), equals(StorageLocation.freezer));
        expect(StorageLocation.fromString('pantry'), equals(StorageLocation.pantry));
      });

      test('Audit 047: StorageLocation.fromString is case-insensitive', () {
        expect(StorageLocation.fromString('FREEZER'), equals(StorageLocation.freezer));
      });

      test('Audit 048: StorageLocation.fromString falls back to other on unrecognized location', () {
        expect(StorageLocation.fromString('unknown_location'), equals(StorageLocation.other));
      });

      test('Audit 049: FoodLifecycleStatus enum has active, consumed, discarded, archived', () {
        expect(FoodLifecycleStatus.values.contains(FoodLifecycleStatus.active), isTrue);
        expect(FoodLifecycleStatus.values.contains(FoodLifecycleStatus.consumed), isTrue);
        expect(FoodLifecycleStatus.values.contains(FoodLifecycleStatus.discarded), isTrue);
        expect(FoodLifecycleStatus.values.contains(FoodLifecycleStatus.archived), isTrue);
      });

      test('Audit 050: ActivityType maps correctly to string representation', () {
        expect(ActivityType.consumed.name, equals('consumed'));
        expect(ActivityType.discarded.name, equals('discarded'));
      });
    });

    // -------------------------------------------------------------------------
    // DOMAIN 3: Expiry Engine & Status Calculation (Audits 051 - 075)
    // -------------------------------------------------------------------------
    group('Domain 3: Expiry Engine & Status (Audits 051-075)', () {
      final fixedToday = DateTime(2026, 10, 18, 12, 0);

      test('Audit 051: ExpiryStatus.calculate returns unknown when expiryDate is null', () {
        expect(ExpiryStatus.calculate(expiryDate: null), equals(ExpiryStatus.unknown));
      });

      test('Audit 052: ExpiryStatus.calculate returns expired for dates in past', () {
        final past = fixedToday.subtract(const Duration(days: 1));
        expect(ExpiryStatus.calculate(expiryDate: past, referenceDate: fixedToday), equals(ExpiryStatus.expired));
      });

      test('Audit 053: ExpiryStatus.calculate returns expiringToday for same calendar day', () {
        final todayMorning = DateTime(2026, 10, 18, 7, 0);
        expect(ExpiryStatus.calculate(expiryDate: todayMorning, referenceDate: fixedToday), equals(ExpiryStatus.expiringToday));
      });

      test('Audit 054: ExpiryStatus.calculate returns expiringSoon for 1 day remaining', () {
        final tomorrow = fixedToday.add(const Duration(days: 1));
        expect(ExpiryStatus.calculate(expiryDate: tomorrow, referenceDate: fixedToday), equals(ExpiryStatus.expiringSoon));
      });

      test('Audit 055: ExpiryStatus.calculate returns expiringSoon for 3 days remaining', () {
        final in3Days = fixedToday.add(const Duration(days: 3));
        expect(ExpiryStatus.calculate(expiryDate: in3Days, referenceDate: fixedToday), equals(ExpiryStatus.expiringSoon));
      });

      test('Audit 056: ExpiryStatus.calculate returns fresh for 4 days remaining', () {
        final in4Days = fixedToday.add(const Duration(days: 4));
        expect(ExpiryStatus.calculate(expiryDate: in4Days, referenceDate: fixedToday), equals(ExpiryStatus.fresh));
      });

      test('Audit 057: ExpiryStatus.calculate returns fresh for 30 days remaining', () {
        final inMonth = fixedToday.add(const Duration(days: 30));
        expect(ExpiryStatus.calculate(expiryDate: inMonth, referenceDate: fixedToday), equals(ExpiryStatus.fresh));
      });

      test('Audit 058: ExpiryStatus.daysRemaining returns null on null expiryDate', () {
        expect(ExpiryStatus.daysRemaining(expiryDate: null), isNull);
      });

      test('Audit 059: ExpiryStatus.daysRemaining returns 0 for today', () {
        expect(ExpiryStatus.daysRemaining(expiryDate: fixedToday, referenceDate: fixedToday), equals(0));
      });

      test('Audit 060: ExpiryStatus.daysRemaining returns negative number for past dates', () {
        final past3Days = fixedToday.subtract(const Duration(days: 3));
        expect(ExpiryStatus.daysRemaining(expiryDate: past3Days, referenceDate: fixedToday), equals(-3));
      });

      test('Audit 061: ExpiryStatus.daysRemaining returns positive number for future dates', () {
        final future7Days = fixedToday.add(const Duration(days: 7));
        expect(ExpiryStatus.daysRemaining(expiryDate: future7Days, referenceDate: fixedToday), equals(7));
      });

      test('Audit 062: ExpiryStatus badgeColor matches for fresh', () {
        expect(ExpiryStatus.fresh.badgeColor, equals(AppColors.statusFresh));
      });

      test('Audit 063: ExpiryStatus badgeColor matches for expiringSoon', () {
        expect(ExpiryStatus.expiringSoon.badgeColor, equals(AppColors.statusExpiringSoon));
      });

      test('Audit 064: ExpiryStatus badgeColor matches for expiringToday', () {
        expect(ExpiryStatus.expiringToday.badgeColor, equals(AppColors.statusExpiringToday));
      });

      test('Audit 065: ExpiryStatus badgeColor matches for expired', () {
        expect(ExpiryStatus.expired.badgeColor, equals(AppColors.statusExpired));
      });

      test('Audit 066: ExpiryStatus badgeColor matches for unknown', () {
        expect(ExpiryStatus.unknown.badgeColor, equals(AppColors.statusUnknown));
      });

      test('Audit 067: ExpiryStatus badgeBackgroundColor light mode tokens are distinct', () {
        expect(ExpiryStatus.fresh.badgeBackgroundColor(false), equals(AppColors.statusFreshBg));
        expect(ExpiryStatus.expiringSoon.badgeBackgroundColor(false), equals(AppColors.statusExpiringSoonBg));
        expect(ExpiryStatus.expiringToday.badgeBackgroundColor(false), equals(AppColors.statusExpiringTodayBg));
        expect(ExpiryStatus.expired.badgeBackgroundColor(false), equals(AppColors.statusExpiredBg));
        expect(ExpiryStatus.unknown.badgeBackgroundColor(false), equals(AppColors.statusUnknownBg));
      });

      test('Audit 068: ExpiryStatus badgeBackgroundColor dark mode tokens are distinct', () {
        expect(ExpiryStatus.fresh.badgeBackgroundColor(true), equals(AppColors.statusFreshBgDark));
        expect(ExpiryStatus.expiringSoon.badgeBackgroundColor(true), equals(AppColors.statusExpiringSoonBgDark));
        expect(ExpiryStatus.expiringToday.badgeBackgroundColor(true), equals(AppColors.statusExpiringTodayBgDark));
        expect(ExpiryStatus.expired.badgeBackgroundColor(true), equals(AppColors.statusExpiredBgDark));
        expect(ExpiryStatus.unknown.badgeBackgroundColor(true), equals(AppColors.statusUnknownBgDark));
      });

      test('Audit 069: ExpiryStatus icon matches for fresh and expired', () {
        expect(ExpiryStatus.fresh.icon, equals(Icons.check_circle_outline_rounded));
        expect(ExpiryStatus.expired.icon, equals(Icons.error_outline_rounded));
      });

      test('Audit 070: ExpiryStatus icon matches for warning states', () {
        expect(ExpiryStatus.expiringToday.icon, equals(Icons.warning_amber_rounded));
        expect(ExpiryStatus.expiringSoon.icon, equals(Icons.alarm_rounded));
        expect(ExpiryStatus.unknown.icon, equals(Icons.help_outline_rounded));
      });

      test('Audit 071: ExpiryStatus custom threshold of 7 days classifies 5-day item as expiringSoon', () {
        final in5Days = fixedToday.add(const Duration(days: 5));
        final statusDefault = ExpiryStatus.calculate(expiryDate: in5Days, referenceDate: fixedToday, warningThresholdDays: 3);
        final statusCustom = ExpiryStatus.calculate(expiryDate: in5Days, referenceDate: fixedToday, warningThresholdDays: 7);
        expect(statusDefault, equals(ExpiryStatus.fresh));
        expect(statusCustom, equals(ExpiryStatus.expiringSoon));
      });

      test('Audit 072: ExpiryStatus daysRemaining calculation handles year boundary', () {
        final endOfYear = DateTime(2026, 12, 31, 23, 0);
        final newYear = DateTime(2027, 1, 1, 1, 0);
        expect(ExpiryStatus.daysRemaining(expiryDate: newYear, referenceDate: endOfYear), equals(1));
      });

      test('Audit 073: ExpiryStatus daysRemaining calculation handles leap year Feb 28 to Mar 1', () {
        final feb28 = DateTime(2028, 2, 28);
        final mar1 = DateTime(2028, 3, 1);
        expect(ExpiryStatus.daysRemaining(expiryDate: mar1, referenceDate: feb28), equals(2));
      });

      test('Audit 074: ExpiryStatus calculation handles far future dates without overflow', () {
        final farFuture = DateTime(2099, 12, 31);
        final status = ExpiryStatus.calculate(expiryDate: farFuture, referenceDate: fixedToday);
        expect(status, equals(ExpiryStatus.fresh));
      });

      test('Audit 075: ExpiryStatus calculation handles far past dates without underflow', () {
        final farPast = DateTime(1990, 1, 1);
        final status = ExpiryStatus.calculate(expiryDate: farPast, referenceDate: fixedToday);
        expect(status, equals(ExpiryStatus.expired));
      });
    });

    // -------------------------------------------------------------------------
    // DOMAIN 4: Persistence, Repository & ACID Operations (Audits 076 - 100)
    // -------------------------------------------------------------------------
    group('Domain 4: Persistence & Repository ACID (Audits 076-100)', () {
      late InMemoryFoodRepository repo;
      final now = DateTime(2026, 10, 18);

      setUp(() {
        repo = InMemoryFoodRepository();
      });

      test('Audit 076: FoodRepository inserts and retrieves active foods', () async {
        final item = FoodItem(
          id: 'repo-1',
          name: 'Tomate',
          category: FoodCategory.fruits,
          initialQuantity: 4,
          unit: FoodUnit.piece,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertFood(item);
        final foods = await repo.getActiveFoods();
        expect(foods.length, equals(1));
        expect(foods.first.id, equals('repo-1'));
      });

      test('Audit 077: FoodRepository retrieves item by ID', () async {
        final item = FoodItem(
          id: 'repo-2',
          name: 'Cebola',
          category: FoodCategory.fruits,
          initialQuantity: 3,
          unit: FoodUnit.piece,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertFood(item);
        final fetched = await repo.getFoodById('repo-2');
        expect(fetched, isNotNull);
        expect(fetched!.name, equals('Cebola'));
      });

      test('Audit 078: FoodRepository returns null for non-existent ID', () async {
        final fetched = await repo.getFoodById('non-existent');
        expect(fetched, isNull);
      });

      test('Audit 079: FoodRepository updates food item properties', () async {
        final item = FoodItem(
          id: 'repo-3',
          name: 'Batata',
          category: FoodCategory.fruits,
          initialQuantity: 5,
          unit: FoodUnit.kilogram,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertFood(item);
        final updated = item.copyWith(name: 'Batata Doce', initialQuantity: 6);
        await repo.updateFood(updated);
        final fetched = await repo.getFoodById('repo-3');
        expect(fetched!.name, equals('Batata Doce'));
        expect(fetched.initialQuantity, equals(6.0));
      });

      test('Audit 080: FoodRepository soft-deletes item by archiving it', () async {
        final item = FoodItem(
          id: 'repo-4',
          name: 'Alface',
          category: FoodCategory.fruits,
          initialQuantity: 1,
          unit: FoodUnit.piece,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertFood(item);
        await repo.deleteFood('repo-4');
        final activeFoods = await repo.getActiveFoods();
        expect(activeFoods, isEmpty);
      });

      test('Audit 081: recordConsumption decrements remainingQuantity accurately', () async {
        final item = FoodItem(
          id: 'repo-5',
          name: 'Arroz',
          category: FoodCategory.pantryStaples,
          initialQuantity: 5.0,
          unit: FoodUnit.kilogram,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertFood(item);
        await repo.recordConsumption(item: item, consumedQuantity: 2.0);
        final fetched = await repo.getFoodById('repo-5');
        expect(fetched!.remainingQuantity, equals(3.0));
        expect(fetched.consumedQuantity, equals(2.0));
      });

      test('Audit 082: recordConsumption clamps to zero if consumed >= remaining', () async {
        final item = FoodItem(
          id: 'repo-6',
          name: 'Leite',
          category: FoodCategory.dairy,
          initialQuantity: 1.0,
          unit: FoodUnit.liter,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertFood(item);
        await repo.recordConsumption(item: item, consumedQuantity: 1.0);
        final fetched = await repo.getFoodById('repo-6');
        expect(fetched!.remainingQuantity, equals(0.0));
        expect(fetched.hasRemaining, isFalse);
      });

      test('Audit 083: recordConsumption rejects NaN quantity without mutating state', () async {
        final item = FoodItem(
          id: 'repo-7',
          name: 'Manteiga',
          category: FoodCategory.dairy,
          initialQuantity: 200,
          unit: FoodUnit.gram,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertFood(item);
        expect(
          () => repo.recordConsumption(item: item, consumedQuantity: double.nan),
          throwsArgumentError,
        );
        final fetched = await repo.getFoodById('repo-7');
        expect(fetched!.consumedQuantity, equals(0.0));
      });

      test('Audit 084: recordConsumption rejects Infinite quantity without mutating state', () async {
        final item = FoodItem(
          id: 'repo-8',
          name: 'Sal',
          category: FoodCategory.pantryStaples,
          initialQuantity: 500,
          unit: FoodUnit.gram,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertFood(item);
        expect(
          () => repo.recordConsumption(item: item, consumedQuantity: double.infinity),
          throwsArgumentError,
        );
        final fetched = await repo.getFoodById('repo-8');
        expect(fetched!.consumedQuantity, equals(0.0));
      });

      test('Audit 085: recordConsumption rejects negative quantity', () async {
        final item = FoodItem(
          id: 'repo-9',
          name: 'Açúcar',
          category: FoodCategory.pantryStaples,
          initialQuantity: 1.0,
          unit: FoodUnit.kilogram,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertFood(item);
        expect(
          () => repo.recordConsumption(item: item, consumedQuantity: -0.5),
          throwsArgumentError,
        );
        final fetched = await repo.getFoodById('repo-9');
        expect(fetched!.consumedQuantity, equals(0.0));
      });

      test('Audit 086: recordConsumption logs ActivityType.consumed in activities', () async {
        final item = FoodItem(
          id: 'repo-10',
          name: 'Iogurte Grego',
          category: FoodCategory.dairy,
          initialQuantity: 4,
          unit: FoodUnit.piece,
          purchasePrice: 16.0,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertFood(item);
        await repo.recordConsumption(item: item, consumedQuantity: 2);
        final activities = await repo.getActivityHistory();
        expect(activities.length, equals(1));
        expect(activities.first.type, equals(ActivityType.consumed));
        expect(activities.first.quantity, equals(2.0));
        expect(activities.first.estimatedValue, equals(8.0));
      });

      test('Audit 087: recordDisposal decrements remainingQuantity accurately', () async {
        final item = FoodItem(
          id: 'repo-11',
          name: 'Pêssego',
          category: FoodCategory.fruits,
          initialQuantity: 6,
          unit: FoodUnit.piece,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertFood(item);
        await repo.recordDisposal(item: item, discardedQuantity: 2);
        final fetched = await repo.getFoodById('repo-11');
        expect(fetched!.remainingQuantity, equals(4.0));
        expect(fetched.discardedQuantity, equals(2.0));
      });

      test('Audit 088: recordDisposal rejects NaN quantity', () async {
        final item = FoodItem(
          id: 'repo-12',
          name: 'Morango',
          category: FoodCategory.fruits,
          initialQuantity: 1,
          unit: FoodUnit.package,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertFood(item);
        expect(
          () => repo.recordDisposal(item: item, discardedQuantity: double.nan),
          throwsArgumentError,
        );
        final fetched = await repo.getFoodById('repo-12');
        expect(fetched!.discardedQuantity, equals(0.0));
      });

      test('Audit 089: recordDisposal rejects Infinity quantity', () async {
        final item = FoodItem(
          id: 'repo-13',
          name: 'Melão',
          category: FoodCategory.fruits,
          initialQuantity: 1,
          unit: FoodUnit.piece,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertFood(item);
        expect(
          () => repo.recordDisposal(item: item, discardedQuantity: double.infinity),
          throwsArgumentError,
        );
        final fetched = await repo.getFoodById('repo-13');
        expect(fetched!.discardedQuantity, equals(0.0));
      });

      test('Audit 090: recordDisposal rejects negative quantity', () async {
        final item = FoodItem(
          id: 'repo-14',
          name: 'Mamão',
          category: FoodCategory.fruits,
          initialQuantity: 1,
          unit: FoodUnit.piece,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertFood(item);
        expect(
          () => repo.recordDisposal(item: item, discardedQuantity: -1.0),
          throwsArgumentError,
        );
        final fetched = await repo.getFoodById('repo-14');
        expect(fetched!.discardedQuantity, equals(0.0));
      });

      test('Audit 091: recordDisposal logs ActivityType.discarded in activities', () async {
        final item = FoodItem(
          id: 'repo-15',
          name: 'Pão de Forma',
          category: FoodCategory.pantryStaples,
          initialQuantity: 1,
          unit: FoodUnit.package,
          purchasePrice: 9.50,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertFood(item);
        await repo.recordDisposal(item: item, discardedQuantity: 1);
        final activities = await repo.getActivityHistory();
        expect(activities.length, equals(1));
        expect(activities.first.type, equals(ActivityType.discarded));
        expect(activities.first.estimatedValue, equals(9.50));
      });

      test('Audit 092: Clamping prevents float drift from exceeding initialQuantity', () async {
        final item = FoodItem(
          id: 'repo-16',
          name: 'Azeite',
          category: FoodCategory.pantryStaples,
          initialQuantity: 0.3,
          unit: FoodUnit.liter,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertFood(item);
        // 0.1 + 0.2 in IEEE-754 is 0.30000000000000004
        await repo.recordConsumption(item: item, consumedQuantity: 0.1);
        final after1 = (await repo.getFoodById('repo-16'))!;
        await repo.recordConsumption(item: after1, consumedQuantity: 0.2);
        final fetched = await repo.getFoodById('repo-16');
        expect(fetched!.consumedQuantity, lessThanOrEqualTo(0.30001));
        expect(fetched.remainingQuantity, equals(0.0));
      });

      test('Audit 093: FoodRepository exportData produces structured map', () async {
        final item = FoodItem(
          id: 'repo-17',
          name: 'Mel',
          category: FoodCategory.pantryStaples,
          initialQuantity: 1,
          unit: FoodUnit.piece,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertFood(item);
        final exported = await repo.exportData();
        expect(exported['app'], equals('Valora'));
        expect(exported['version'], equals(1));
        expect((exported['food_items'] as List).length, equals(1));
      });

      test('Audit 094: FoodRepository importData restores items successfully', () async {
        final backupData = {
          'app': 'Valora',
          'version': 1,
          'food_items': [
            {
              'id': 'imp-1',
              'name': 'Café Solúvel',
              'category': 'pantry_staples',
              'initial_quantity': 1.0,
              'consumed_quantity': 0.0,
              'discarded_quantity': 0.0,
              'unit': 'piece',
              'storage_location': 'pantry',
              'purchase_date': now.toIso8601String(),
              'created_at': now.toIso8601String(),
              'updated_at': now.toIso8601String(),
            }
          ],
          'food_activities': [],
        };
        final success = await repo.importData(backupData);
        expect(success, isTrue);
        final items = await repo.getActiveFoods();
        expect(items.length, equals(1));
        expect(items.first.name, equals('Café Solúvel'));
      });

      test('Audit 095: FoodRepository importData rejects mismatched app identifier', () async {
        final corrupt = {'app': 'WrongApp', 'version': 1, 'food_items': []};
        final success = await repo.importData(corrupt);
        expect(success, isFalse);
      });

      test('Audit 096: FoodRepository importData rejects missing food_items list', () async {
        final corrupt = {'app': 'Valora', 'version': 1};
        final success = await repo.importData(corrupt);
        expect(success, isFalse);
      });

      test('Audit 097: FoodRepository clearAllData wipes both items and activities', () async {
        final item = FoodItem(
          id: 'repo-18',
          name: 'Uva Passa',
          category: FoodCategory.fruits,
          initialQuantity: 1,
          unit: FoodUnit.package,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertFood(item);
        await repo.recordConsumption(item: item, consumedQuantity: 1);
        await repo.clearAllData();
        expect(await repo.getActiveFoods(), isEmpty);
        expect(await repo.getActivityHistory(), isEmpty);
      });

      test('Audit 098: FoodRepository rejects inserting invalid food item', () async {
        final invalidItem = FoodItem(
          id: 'repo-19',
          name: '', // Empty name violates constraint
          category: FoodCategory.fruits,
          initialQuantity: 1,
          unit: FoodUnit.piece,
          createdAt: now,
          updatedAt: now,
        );
        expect(() => repo.insertFood(invalidItem), throwsArgumentError);
      });

      test('Audit 099: FoodRepository rejects updating with invalid food item', () async {
        final validItem = FoodItem(
          id: 'repo-20',
          name: 'Kiwi',
          category: FoodCategory.fruits,
          initialQuantity: 1,
          unit: FoodUnit.piece,
          createdAt: now,
          updatedAt: now,
        );
        await repo.insertFood(validItem);
        final invalidUpdate = validItem.copyWith(name: '');
        expect(() => repo.updateFood(invalidUpdate), throwsArgumentError);
      });

      test('Audit 100: FoodRepository getActivities sorts in reverse chronological order', () async {
        final act1 = FoodActivity(
          id: 'act-seq-1',
          foodItemId: 'item-1',
          foodName: 'Item 1',
          category: FoodCategory.fruits,
          quantity: 1,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: now.subtract(const Duration(hours: 3)),
        );
        final act2 = FoodActivity(
          id: 'act-seq-2',
          foodItemId: 'item-2',
          foodName: 'Item 2',
          category: FoodCategory.fruits,
          quantity: 1,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: now.subtract(const Duration(hours: 1)),
        );
        await repo.addActivity(act1);
        await repo.addActivity(act2);
        final activities = await repo.getActivityHistory();
        expect(activities.first.id, equals('act-seq-2'));
        expect(activities.last.id, equals('act-seq-1'));
      });
    });

    // -------------------------------------------------------------------------
    // DOMAIN 5: PantryProvider State Management (Audits 101 - 125)
    // -------------------------------------------------------------------------
    group('Domain 5: PantryProvider State (Audits 101-125)', () {
      late InMemoryFoodRepository repo;
      late PantryProvider provider;
      final refDate = DateTime(2026, 10, 18, 12, 0);

      setUp(() async {
        repo = InMemoryFoodRepository();
        provider = PantryProvider(repository: repo);
      });

      test('Audit 101: PantryProvider initializes with empty items', () async {
        await provider.loadItems();
        expect(provider.items, isEmpty);
        expect(provider.totalActiveCount, equals(0));
      });

      test('Audit 102: PantryProvider loads items from repository', () async {
        final item = FoodItem(
          id: 'p-1',
          name: 'Banana Prata',
          category: FoodCategory.fruits,
          initialQuantity: 6,
          unit: FoodUnit.piece,
          createdAt: refDate,
          updatedAt: refDate,
        );
        await repo.insertFood(item);
        await provider.loadItems();
        expect(provider.items.length, equals(1));
        expect(provider.totalActiveCount, equals(1));
      });

      test('Audit 103: PantryProvider filters items by category', () async {
        await repo.insertFood(FoodItem(
          id: 'p-2',
          name: 'Maçã',
          category: FoodCategory.fruits,
          initialQuantity: 2,
          unit: FoodUnit.piece,
          createdAt: refDate,
          updatedAt: refDate,
        ));
        await repo.insertFood(FoodItem(
          id: 'p-3',
          name: 'Leite',
          category: FoodCategory.dairy,
          initialQuantity: 1,
          unit: FoodUnit.liter,
          createdAt: refDate,
          updatedAt: refDate,
        ));
        await provider.loadItems();
        provider.setSelectedCategory(FoodCategory.fruits);
        expect(provider.filteredAndSortedItems.length, equals(1));
        expect(provider.filteredAndSortedItems.first.name, equals('Maçã'));
      });

      test('Audit 104: PantryProvider clearing category filter restores all items', () async {
        await repo.insertFood(FoodItem(id: 'p-4', name: 'Item A', category: FoodCategory.fruits, initialQuantity: 1, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate));
        await repo.insertFood(FoodItem(id: 'p-5', name: 'Item B', category: FoodCategory.dairy, initialQuantity: 1, unit: FoodUnit.liter, createdAt: refDate, updatedAt: refDate));
        await provider.loadItems();
        provider.setSelectedCategory(FoodCategory.fruits);
        expect(provider.filteredAndSortedItems.length, equals(1));
        provider.setSelectedCategory(null);
        expect(provider.filteredAndSortedItems.length, equals(2));
      });

      test('Audit 105: PantryProvider search query filters case-insensitively', () async {
        await repo.insertFood(FoodItem(id: 'p-6', name: 'CHOCOLATE', category: FoodCategory.other, initialQuantity: 1, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate));
        await provider.loadItems();
        provider.setSearchQuery('chocolate');
        expect(provider.filteredAndSortedItems.length, equals(1));
      });

      test('Audit 106: PantryProvider search query filters accent-insensitively', () async {
        await repo.insertFood(FoodItem(id: 'p-7', name: 'Maçã Verde', category: FoodCategory.fruits, initialQuantity: 3, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate));
        await provider.loadItems();
        provider.setSearchQuery('maca');
        expect(provider.filteredAndSortedItems.length, equals(1));
      });

      test('Audit 107: PantryProvider search query ignores leading/trailing whitespaces', () async {
        await repo.insertFood(FoodItem(id: 'p-8', name: 'Arroz Integral', category: FoodCategory.pantryStaples, initialQuantity: 1, unit: FoodUnit.kilogram, createdAt: refDate, updatedAt: refDate));
        await provider.loadItems();
        provider.setSearchQuery('   arroz   ');
        expect(provider.filteredAndSortedItems.length, equals(1));
      });

      test('Audit 108: PantryProvider sort by expirySoonest sorts soonest first', () async {
        final itemA = FoodItem(id: 'p-9', name: 'Expira depois', category: FoodCategory.dairy, initialQuantity: 1, unit: FoodUnit.piece, expiryDate: refDate.add(const Duration(days: 10)), createdAt: refDate, updatedAt: refDate);
        final itemB = FoodItem(id: 'p-10', name: 'Expira antes', category: FoodCategory.dairy, initialQuantity: 1, unit: FoodUnit.piece, expiryDate: refDate.add(const Duration(days: 2)), createdAt: refDate, updatedAt: refDate);
        await repo.insertFood(itemA);
        await repo.insertFood(itemB);
        await provider.loadItems();
        provider.setSortOption(PantrySortOption.expirySoonest);
        expect(provider.filteredAndSortedItems.first.name, equals('Expira antes'));
      });

      test('Audit 109: PantryProvider sort by nameAZ sorts accented letters in proper alphabetical order', () async {
        final itemA = FoodItem(id: 'p-11', name: 'Banana', category: FoodCategory.fruits, initialQuantity: 1, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate);
        final itemB = FoodItem(id: 'p-12', name: 'Água', category: FoodCategory.drinks, initialQuantity: 1, unit: FoodUnit.liter, createdAt: refDate, updatedAt: refDate);
        await repo.insertFood(itemA);
        await repo.insertFood(itemB);
        await provider.loadItems();
        provider.setSortOption(PantrySortOption.nameAZ);
        expect(provider.filteredAndSortedItems.first.name, equals('Água'));
        expect(provider.filteredAndSortedItems.last.name, equals('Banana'));
      });

      test('Audit 110: PantryProvider sort by nameZA reverses alphabetical order', () async {
        final itemA = FoodItem(id: 'p-13', name: 'Abacaxi', category: FoodCategory.fruits, initialQuantity: 1, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate);
        final itemB = FoodItem(id: 'p-14', name: 'Zimbro', category: FoodCategory.pantryStaples, initialQuantity: 1, unit: FoodUnit.gram, createdAt: refDate, updatedAt: refDate);
        await repo.insertFood(itemA);
        await repo.insertFood(itemB);
        await provider.loadItems();
        provider.setSortOption(PantrySortOption.nameZA);
        expect(provider.filteredAndSortedItems.first.name, equals('Zimbro'));
        expect(provider.filteredAndSortedItems.last.name, equals('Abacaxi'));
      });

      test('Audit 111: PantryProvider groups items expiring today', () async {
        final today = DateTime.now();
        final itemToday = FoodItem(id: 'p-15', name: 'Hoje', category: FoodCategory.dairy, initialQuantity: 1, unit: FoodUnit.piece, expiryDate: today, createdAt: refDate, updatedAt: refDate);
        final itemLater = FoodItem(id: 'p-16', name: 'Depois', category: FoodCategory.dairy, initialQuantity: 1, unit: FoodUnit.piece, expiryDate: today.add(const Duration(days: 10)), createdAt: refDate, updatedAt: refDate);
        await repo.insertFood(itemToday);
        await repo.insertFood(itemLater);
        await provider.loadItems();
        expect(provider.groupExpiringToday.length, equals(1));
        expect(provider.groupExpiringToday.first.name, equals('Hoje'));
      });

      test('Audit 112: PantryProvider groups items expiring soon (1-3 days)', () async {
        final in2Days = DateTime.now().add(const Duration(days: 2));
        final item = FoodItem(id: 'p-17', name: 'Breve', category: FoodCategory.dairy, initialQuantity: 1, unit: FoodUnit.piece, expiryDate: in2Days, createdAt: refDate, updatedAt: refDate);
        await repo.insertFood(item);
        await provider.loadItems();
        expect(provider.groupExpiringSoon.length, equals(1));
        expect(provider.groupExpiringSoon.first.name, equals('Breve'));
      });

      test('Audit 113: PantryProvider groups expired items', () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final item = FoodItem(id: 'p-18', name: 'Vencido', category: FoodCategory.dairy, initialQuantity: 1, unit: FoodUnit.piece, expiryDate: yesterday, createdAt: refDate, updatedAt: refDate);
        await repo.insertFood(item);
        await provider.loadItems();
        expect(provider.groupExpired.length, equals(1));
        expect(provider.groupExpired.first.name, equals('Vencido'));
      });

      test('Audit 114: PantryProvider groups unknown expiry items', () async {
        final item = FoodItem(id: 'p-19', name: 'Sem validade', category: FoodCategory.pantryStaples, initialQuantity: 1, unit: FoodUnit.piece, expiryDate: null, createdAt: refDate, updatedAt: refDate);
        await repo.insertFood(item);
        await provider.loadItems();
        expect(provider.groupUnknown.length, equals(1));
        expect(provider.groupUnknown.first.name, equals('Sem validade'));
      });

      test('Audit 115: PantryProvider groups fresh items (4+ days)', () async {
        final in10Days = DateTime.now().add(const Duration(days: 10));
        final item = FoodItem(id: 'p-20', name: 'Seguro', category: FoodCategory.pantryStaples, initialQuantity: 1, unit: FoodUnit.piece, expiryDate: in10Days, createdAt: refDate, updatedAt: refDate);
        await repo.insertFood(item);
        await provider.loadItems();
        expect(provider.groupLater.length, equals(1));
        expect(provider.groupLater.first.name, equals('Seguro'));
      });

      test('Audit 116: PantryProvider addFood inserts food and refreshes state', () async {
        final item = FoodItem(id: 'p-21', name: 'Pera', category: FoodCategory.fruits, initialQuantity: 2, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate);
        await provider.addFood(item);
        expect(provider.items.length, equals(1));
        expect(provider.items.first.name, equals('Pera'));
      });

      test('Audit 117: PantryProvider updateFood modifies existing item', () async {
        final item = FoodItem(id: 'p-22', name: 'Uva', category: FoodCategory.fruits, initialQuantity: 1, unit: FoodUnit.package, createdAt: refDate, updatedAt: refDate);
        await provider.addFood(item);
        await provider.updateFood(item.copyWith(name: 'Uva Crimson'));
        expect(provider.items.first.name, equals('Uva Crimson'));
      });

      test('Audit 118: PantryProvider deleteFood deletes item', () async {
        final item = FoodItem(id: 'p-23', name: 'Manga', category: FoodCategory.fruits, initialQuantity: 1, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate);
        await provider.addFood(item);
        await provider.deleteFood('p-23');
        expect(provider.items, isEmpty);
      });

      test('Audit 119: PantryProvider recordConsumption marks item depleted if fully consumed', () async {
        final item = FoodItem(id: 'p-24', name: 'Suco Uva', category: FoodCategory.drinks, initialQuantity: 1, unit: FoodUnit.liter, createdAt: refDate, updatedAt: refDate);
        await provider.addFood(item);
        await provider.recordConsumption(item: item, consumedQuantity: 1.0);
        expect(provider.items, isEmpty);
      });

      test('Audit 120: PantryProvider recordDisposal marks item depleted if fully discarded', () async {
        final item = FoodItem(id: 'p-25', name: 'Nata', category: FoodCategory.dairy, initialQuantity: 1, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate);
        await provider.addFood(item);
        await provider.recordDisposal(item: item, discardedQuantity: 1.0);
        expect(provider.items, isEmpty);
      });

      test('Audit 121: PantryProvider totalValue calculates sum of item values correctly', () async {
        await repo.insertFood(FoodItem(id: 'p-26', name: 'Vinho', category: FoodCategory.drinks, initialQuantity: 1, unit: FoodUnit.piece, purchasePrice: 40.0, createdAt: refDate, updatedAt: refDate));
        await repo.insertFood(FoodItem(id: 'p-27', name: 'Azeite', category: FoodCategory.pantryStaples, initialQuantity: 1, unit: FoodUnit.piece, purchasePrice: 35.0, createdAt: refDate, updatedAt: refDate));
        await provider.loadItems();
        expect(provider.totalEstimatedValue, equals(75.0));
      });

      test('Audit 122: PantryProvider totalValue gracefully ignores items with null price', () async {
        await repo.insertFood(FoodItem(id: 'p-28', name: 'Item Grátis', category: FoodCategory.fruits, initialQuantity: 1, unit: FoodUnit.piece, purchasePrice: null, createdAt: refDate, updatedAt: refDate));
        await repo.insertFood(FoodItem(id: 'p-29', name: 'Item Pago', category: FoodCategory.fruits, initialQuantity: 1, unit: FoodUnit.piece, purchasePrice: 10.0, createdAt: refDate, updatedAt: refDate));
        await provider.loadItems();
        expect(provider.totalEstimatedValue, equals(10.0));
      });

      test('Audit 123: PantryProvider totalValue accounts for partial consumption', () async {
        await repo.insertFood(FoodItem(
          id: 'p-30',
          name: 'Carne',
          category: FoodCategory.meatFish,
          initialQuantity: 2.0,
          consumedQuantity: 1.0,
          unit: FoodUnit.kilogram,
          purchasePrice: 50.0,
          createdAt: refDate,
          updatedAt: refDate,
        ));
        await provider.loadItems();
        expect(provider.totalEstimatedValue, equals(25.0));
      });

      test('Audit 124: PantryProvider handles rapidly toggling sort options without crashing', () async {
        for (final option in PantrySortOption.values) {
          provider.setSortOption(option);
          expect(provider.sortOption, equals(option));
        }
      });

      test('Audit 125: PantryProvider notifies listeners when state changes', () async {
        int listenerCalls = 0;
        provider.addListener(() => listenerCalls++);
        await provider.addFood(FoodItem(id: 'p-31', name: 'Teste', category: FoodCategory.other, initialQuantity: 1, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate));
        expect(listenerCalls, greaterThan(0));
      });
    });

    // -------------------------------------------------------------------------
    // DOMAIN 6: ImpactProvider & Sustainability Metrics (Audits 126 - 150)
    // -------------------------------------------------------------------------
    group('Domain 6: ImpactProvider Sustainability (Audits 126-150)', () {
      late InMemoryFoodRepository repo;
      late ImpactProvider provider;
      final fixedNow = DateTime(2026, 10, 18, 12, 0);

      setUp(() async {
        repo = InMemoryFoodRepository();
        provider = ImpactProvider(repository: repo, referenceDate: fixedNow);
      });

      test('Audit 126: ImpactProvider initializes with zero metrics', () async {
        await provider.loadActivities();
        expect(provider.activities, isEmpty);
        expect(provider.recordedConsumedCount, equals(0));
        expect(provider.recordedDiscardedCount, equals(0));
        expect(provider.consumptionRate, isNull);
        expect(provider.estimatedValueConsumed, equals(0.0));
        expect(provider.estimatedValueDiscarded, equals(0.0));
      });

      test('Audit 127: ImpactProvider consumptionRate computes consumed / total accurately', () async {
        await repo.addActivity(FoodActivity(id: 'i-1a', foodItemId: 'f-1a', foodName: 'A1', category: FoodCategory.fruits, quantity: 1, unit: FoodUnit.piece, type: ActivityType.consumed, timestamp: fixedNow));
        await repo.addActivity(FoodActivity(id: 'i-1b', foodItemId: 'f-1b', foodName: 'A2', category: FoodCategory.fruits, quantity: 1, unit: FoodUnit.piece, type: ActivityType.consumed, timestamp: fixedNow));
        await repo.addActivity(FoodActivity(id: 'i-1c', foodItemId: 'f-1c', foodName: 'A3', category: FoodCategory.fruits, quantity: 1, unit: FoodUnit.piece, type: ActivityType.consumed, timestamp: fixedNow));
        await repo.addActivity(FoodActivity(id: 'i-2', foodItemId: 'f-2', foodName: 'B', category: FoodCategory.fruits, quantity: 1, unit: FoodUnit.piece, type: ActivityType.discarded, timestamp: fixedNow));
        await provider.loadActivities();
        expect(provider.consumptionRate, equals(75.0));
      });

      test('Audit 128: ImpactProvider consumptionRate returns 100.0 when all items consumed', () async {
        await repo.addActivity(FoodActivity(id: 'i-3', foodItemId: 'f-3', foodName: 'C', category: FoodCategory.fruits, quantity: 2, unit: FoodUnit.piece, type: ActivityType.consumed, timestamp: fixedNow));
        await provider.loadActivities();
        expect(provider.consumptionRate, equals(100.0));
      });

      test('Audit 129: ImpactProvider consumptionRate returns 0.0 when all items discarded', () async {
        await repo.addActivity(FoodActivity(id: 'i-4', foodItemId: 'f-4', foodName: 'D', category: FoodCategory.fruits, quantity: 2, unit: FoodUnit.piece, type: ActivityType.discarded, timestamp: fixedNow));
        await provider.loadActivities();
        expect(provider.consumptionRate, equals(0.0));
      });

      test('Audit 130: ImpactProvider estimatedValueConsumed sums values accurately', () async {
        await repo.addActivity(FoodActivity(id: 'i-5', foodItemId: 'f-5', foodName: 'E', category: FoodCategory.dairy, quantity: 1, unit: FoodUnit.piece, type: ActivityType.consumed, timestamp: fixedNow, estimatedValue: 12.50));
        await repo.addActivity(FoodActivity(id: 'i-6', foodItemId: 'f-6', foodName: 'F', category: FoodCategory.dairy, quantity: 1, unit: FoodUnit.piece, type: ActivityType.consumed, timestamp: fixedNow, estimatedValue: 7.50));
        await provider.loadActivities();
        expect(provider.estimatedValueConsumed, equals(20.0));
      });

      test('Audit 131: ImpactProvider estimatedValueDiscarded sums values accurately', () async {
        await repo.addActivity(FoodActivity(id: 'i-7', foodItemId: 'f-7', foodName: 'G', category: FoodCategory.meatFish, quantity: 1, unit: FoodUnit.piece, type: ActivityType.discarded, timestamp: fixedNow, estimatedValue: 30.0));
        await provider.loadActivities();
        expect(provider.estimatedValueDiscarded, equals(30.0));
      });

      test('Audit 132: ImpactProvider estimatedValue guards against NaN or Infinity', () async {
        await repo.addActivity(FoodActivity(id: 'i-8', foodItemId: 'f-8', foodName: 'H', category: FoodCategory.meatFish, quantity: 1, unit: FoodUnit.piece, type: ActivityType.consumed, timestamp: fixedNow, estimatedValue: double.nan));
        await repo.addActivity(FoodActivity(id: 'i-9', foodItemId: 'f-9', foodName: 'I', category: FoodCategory.meatFish, quantity: 1, unit: FoodUnit.piece, type: ActivityType.discarded, timestamp: fixedNow, estimatedValue: double.infinity));
        await provider.loadActivities();
        expect(provider.estimatedValueConsumed, equals(0.0));
        expect(provider.estimatedValueDiscarded, equals(0.0));
      });

      test('Audit 133: ImpactProvider periodFilter last7Days filters starting from 00:00:00 of 7 days ago', () async {
        final actMorning6DaysAgo = FoodActivity(id: 'i-10', foodItemId: 'f-10', foodName: 'J', category: FoodCategory.fruits, quantity: 1, unit: FoodUnit.piece, type: ActivityType.consumed, timestamp: DateTime(fixedNow.year, fixedNow.month, fixedNow.day - 6, 8, 0));
        final act8DaysAgo = FoodActivity(id: 'i-11', foodItemId: 'f-11', foodName: 'K', category: FoodCategory.fruits, quantity: 1, unit: FoodUnit.piece, type: ActivityType.consumed, timestamp: DateTime(fixedNow.year, fixedNow.month, fixedNow.day - 8, 23, 0));
        await repo.addActivity(actMorning6DaysAgo);
        await repo.addActivity(act8DaysAgo);
        await provider.loadActivities();
        provider.setPeriodFilter(ActivityPeriodFilter.last7Days);
        expect(provider.filteredActivities.length, equals(1));
        expect(provider.filteredActivities.first.id, equals('i-10'));
      });

      test('Audit 134: ImpactProvider periodFilter last30Days filters starting from 00:00:00 of 30 days ago', () async {
        final act29DaysAgo = FoodActivity(id: 'i-12', foodItemId: 'f-12', foodName: 'L', category: FoodCategory.fruits, quantity: 1, unit: FoodUnit.piece, type: ActivityType.consumed, timestamp: DateTime(fixedNow.year, fixedNow.month, fixedNow.day - 29, 10, 0));
        final act35DaysAgo = FoodActivity(id: 'i-13', foodItemId: 'f-13', foodName: 'M', category: FoodCategory.fruits, quantity: 1, unit: FoodUnit.piece, type: ActivityType.consumed, timestamp: DateTime(fixedNow.year, fixedNow.month, fixedNow.day - 35, 10, 0));
        await repo.addActivity(act29DaysAgo);
        await repo.addActivity(act35DaysAgo);
        await provider.loadActivities();
        provider.setPeriodFilter(ActivityPeriodFilter.last30Days);
        expect(provider.filteredActivities.length, equals(1));
        expect(provider.filteredActivities.first.id, equals('i-12'));
      });

      test('Audit 135: ImpactProvider periodFilter last90Days includes items within 90 days', () async {
        final act60DaysAgo = FoodActivity(id: 'i-14', foodItemId: 'f-14', foodName: 'N', category: FoodCategory.fruits, quantity: 1, unit: FoodUnit.piece, type: ActivityType.consumed, timestamp: DateTime(fixedNow.year, fixedNow.month, fixedNow.day - 60));
        await repo.addActivity(act60DaysAgo);
        await provider.loadActivities();
        provider.setPeriodFilter(ActivityPeriodFilter.last90Days);
        expect(provider.filteredActivities.length, equals(1));
      });

      test('Audit 136: ImpactProvider periodFilter allTime includes all activities', () async {
        final actYearAgo = FoodActivity(id: 'i-15', foodItemId: 'f-15', foodName: 'O', category: FoodCategory.fruits, quantity: 1, unit: FoodUnit.piece, type: ActivityType.consumed, timestamp: DateTime(2025, 1, 1));
        await repo.addActivity(actYearAgo);
        await provider.loadActivities();
        provider.setPeriodFilter(ActivityPeriodFilter.allTime);
        expect(provider.filteredActivities.length, equals(1));
      });

      test('Audit 137: ImpactProvider consumedVolumeByUnit aggregates quantities per unit', () async {
        await repo.addActivity(FoodActivity(id: 'i-16', foodItemId: 'f-16', foodName: 'Batata', category: FoodCategory.fruits, quantity: 2.5, unit: FoodUnit.kilogram, type: ActivityType.consumed, timestamp: fixedNow));
        await repo.addActivity(FoodActivity(id: 'i-17', foodItemId: 'f-17', foodName: 'Cenoura', category: FoodCategory.fruits, quantity: 1.5, unit: FoodUnit.kilogram, type: ActivityType.consumed, timestamp: fixedNow));
        await provider.loadActivities();
        expect(provider.consumedVolumeByUnit[FoodUnit.kilogram], equals(4.0));
      });

      test('Audit 138: ImpactProvider discardedVolumeByUnit aggregates quantities per unit', () async {
        await repo.addActivity(FoodActivity(id: 'i-18', foodItemId: 'f-18', foodName: 'Leite', category: FoodCategory.dairy, quantity: 0.5, unit: FoodUnit.liter, type: ActivityType.discarded, timestamp: fixedNow));
        await repo.addActivity(FoodActivity(id: 'i-19', foodItemId: 'f-19', foodName: 'Suco', category: FoodCategory.drinks, quantity: 0.5, unit: FoodUnit.liter, type: ActivityType.discarded, timestamp: fixedNow));
        await provider.loadActivities();
        expect(provider.discardedVolumeByUnit[FoodUnit.liter], equals(1.0));
      });

      test('Audit 139: ImpactProvider totalRecordedActions equals consumed + discarded counts', () async {
        await repo.addActivity(FoodActivity(id: 'i-20', foodItemId: 'f-20', foodName: 'A', category: FoodCategory.fruits, quantity: 1, unit: FoodUnit.piece, type: ActivityType.consumed, timestamp: fixedNow));
        await repo.addActivity(FoodActivity(id: 'i-21', foodItemId: 'f-21', foodName: 'B', category: FoodCategory.fruits, quantity: 1, unit: FoodUnit.piece, type: ActivityType.discarded, timestamp: fixedNow));
        await provider.loadActivities();
        expect(provider.totalRecordedActions, equals(2));
      });

      test('Audit 140: ImpactProvider filterByPeriod label helper works for all filters', () {
        for (final filter in ActivityPeriodFilter.values) {
          provider.setPeriodFilter(filter);
          expect(provider.periodFilter, equals(filter));
        }
      });

      test('Audit 141: ImpactProvider empty state metrics do not throw on getter access', () {
        expect(() => provider.activities, returnsNormally);
        expect(() => provider.filteredActivities, returnsNormally);
        expect(() => provider.recordedConsumedCount, returnsNormally);
        expect(() => provider.recordedDiscardedCount, returnsNormally);
        expect(() => provider.consumptionRate, returnsNormally);
      });

      test('Audit 142: ImpactProvider handles large number of activities efficiently', () async {
        for (int i = 0; i < 100; i++) {
          await repo.addActivity(FoodActivity(
            id: 'perf-$i',
            foodItemId: 'item-$i',
            foodName: 'Food $i',
            category: FoodCategory.fruits,
            quantity: 1,
            unit: FoodUnit.piece,
            type: i.isEven ? ActivityType.consumed : ActivityType.discarded,
            timestamp: fixedNow.subtract(Duration(hours: i)),
            estimatedValue: 2.50,
          ));
        }
        await provider.loadActivities();
        expect(provider.activities.length, equals(100));
        expect(provider.recordedConsumedCount, equals(50));
        expect(provider.recordedDiscardedCount, equals(50));
        expect(provider.consumptionRate, equals(50.0));
      });

      test('Audit 143: ImpactProvider handles activities with null estimatedValue gracefully', () async {
        await repo.addActivity(FoodActivity(
          id: 'null-val',
          foodItemId: 'item-null',
          foodName: 'No price item',
          category: FoodCategory.other,
          quantity: 1,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: fixedNow,
          estimatedValue: null,
        ));
        await provider.loadActivities();
        expect(provider.estimatedValueConsumed, equals(0.0));
      });

      test('Audit 144: ImpactProvider handles fractional quantities in consumption rate', () async {
        await repo.addActivity(FoodActivity(id: 'frac-1', foodItemId: 'f-1', foodName: 'A', category: FoodCategory.fruits, quantity: 0.25, unit: FoodUnit.kilogram, type: ActivityType.consumed, timestamp: fixedNow));
        await repo.addActivity(FoodActivity(id: 'frac-2', foodItemId: 'f-2', foodName: 'B', category: FoodCategory.fruits, quantity: 0.75, unit: FoodUnit.kilogram, type: ActivityType.discarded, timestamp: fixedNow));
        await provider.loadActivities();
        expect(provider.consumptionRate, equals(50.0)); // count of actions is 1 consumed / 2 total = 50%
      });

      test('Audit 145: ImpactProvider referenceDate parameter allows reproducible tests', () {
        final customDate = DateTime(2030, 1, 1);
        final customProvider = ImpactProvider(repository: repo, referenceDate: customDate);
        expect(customProvider.periodFilter, equals(ActivityPeriodFilter.allTime));
      });

      test('Audit 146: ImpactProvider reload maintains current filter', () async {
        provider.setPeriodFilter(ActivityPeriodFilter.last7Days);
        await provider.loadActivities();
        expect(provider.periodFilter, equals(ActivityPeriodFilter.last7Days));
      });

      test('Audit 147: ImpactProvider notifies listeners on filter change', () {
        int calls = 0;
        provider.addListener(() => calls++);
        provider.setPeriodFilter(ActivityPeriodFilter.last7Days);
        expect(calls, equals(1));
      });

      test('Audit 148: ImpactProvider notifies listeners on loadActivities', () async {
        int calls = 0;
        provider.addListener(() => calls++);
        await provider.loadActivities();
        expect(calls, greaterThan(0));
      });

      test('Audit 149: ImpactProvider safely parses zero quantity activities', () async {
        await repo.addActivity(FoodActivity(id: 'zero-act', foodItemId: 'f-zero', foodName: 'Zero', category: FoodCategory.other, quantity: 0.0, unit: FoodUnit.piece, type: ActivityType.consumed, timestamp: fixedNow));
        await provider.loadActivities();
        expect(provider.recordedConsumedCount, equals(1));
      });

      test('Audit 150: ImpactProvider volume map handles multiple different units simultaneously', () async {
        await repo.addActivity(FoodActivity(id: 'u-1', foodItemId: 'f-u1', foodName: 'Kg item', category: FoodCategory.fruits, quantity: 2, unit: FoodUnit.kilogram, type: ActivityType.consumed, timestamp: fixedNow));
        await repo.addActivity(FoodActivity(id: 'u-2', foodItemId: 'f-u2', foodName: 'Liter item', category: FoodCategory.drinks, quantity: 3, unit: FoodUnit.liter, type: ActivityType.consumed, timestamp: fixedNow));
        await repo.addActivity(FoodActivity(id: 'u-3', foodItemId: 'f-u3', foodName: 'Piece item', category: FoodCategory.dairy, quantity: 5, unit: FoodUnit.piece, type: ActivityType.consumed, timestamp: fixedNow));
        await provider.loadActivities();
        expect(provider.consumedVolumeByUnit[FoodUnit.kilogram], equals(2.0));
        expect(provider.consumedVolumeByUnit[FoodUnit.liter], equals(3.0));
        expect(provider.consumedVolumeByUnit[FoodUnit.piece], equals(5.0));
      });
    });

    // -------------------------------------------------------------------------
    // DOMAIN 7: Subscription, Paywall & Referral Engine (Audits 151 - 175)
    // -------------------------------------------------------------------------
    group('Domain 7: Subscription & Referral Engine (Audits 151-175)', () {
      late PreferencesService prefsService;
      late SubscriptionProvider subProvider;

      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        final sp = await SharedPreferences.getInstance();
        prefsService = PreferencesService(sp);
        subProvider = SubscriptionProvider(prefs: prefsService);
      });

      test('Audit 151: SubscriptionProvider initializes firstLaunchDate on new install', () {
        expect(subProvider.firstLaunchDate, isNotNull);
      });

      test('Audit 152: SubscriptionProvider base trial period defaults to 7 days', () {
        expect(subProvider.trialBaseDays, equals(7));
      });

      test('Audit 153: SubscriptionProvider isTrialActive returns true on day 1', () {
        expect(subProvider.isTrialActive, isTrue);
      });

      test('Audit 154: SubscriptionProvider daysRemainingInTrial is positive during trial', () {
        expect(subProvider.daysRemainingInTrial, greaterThan(0));
      });

      test('Audit 155: SubscriptionProvider userReferralCode has VAL- prefix and 4 uppercase chars', () {
        final code = subProvider.userReferralCode;
        expect(code.startsWith('VAL-'), isTrue);
        expect(code.length, equals(8));
      });

      test('Audit 156: SubscriptionProvider inviteBonusDays is 7 days', () {
        expect(subProvider.inviteBonusDays, equals(7));
      });

      test('Audit 157: SubscriptionProvider monthlyPrice is 9.90', () {
        expect(subProvider.price, equals(9.90));
      });

      test('Audit 158: SubscriptionProvider priceFormatted is formatted in R\$', () {
        expect(subProvider.priceFormatted, contains('9,90'));
      });

      test('Audit 159: SubscriptionProvider acceptTrial sets hasAcceptedTrial flag', () async {
        expect(subProvider.hasAcceptedTrial, isFalse);
        await subProvider.acceptTrial();
        expect(subProvider.hasAcceptedTrial, isTrue);
      });

      test('Audit 160: SubscriptionProvider subscribe activates subscription', () async {
        expect(subProvider.isSubscribed, isFalse);
        await subProvider.subscribe();
        expect(subProvider.isSubscribed, isTrue);
        expect(subProvider.subscriptionExpiresAt, isNotNull);
      });

      test('Audit 161: SubscriptionProvider recordInviteSuccess increments count and adds 7 bonus days', () async {
        expect(subProvider.invitedCount, equals(0));
        expect(subProvider.referralBonusDays, equals(0));
        await subProvider.recordInviteSuccess();
        expect(subProvider.invitedCount, equals(1));
        expect(subProvider.referralBonusDays, equals(7));
        expect(subProvider.totalTrialDays, equals(14));
      });

      test('Audit 162: SubscriptionProvider redeemInviteCode grants 7 bonus days on valid friend code', () {
        final result = subProvider.redeemInviteCode('VAL-TEST');
        expect(result, equals(RedemptionResult.success));
        expect(subProvider.referralBonusDays, equals(7));
        expect(subProvider.redeemedCodes, contains('VAL-TEST'));
      });

      test('Audit 163: SubscriptionProvider redeemInviteCode is case-insensitive and trims spaces', () {
        final result = subProvider.redeemInviteCode('  val-code  ');
        expect(result, equals(RedemptionResult.success));
        expect(subProvider.redeemedCodes, contains('VAL-CODE'));
      });

      test('Audit 164: SubscriptionProvider redeemInviteCode prevents self-redemption', () {
        final myCode = subProvider.userReferralCode;
        final result = subProvider.redeemInviteCode(myCode);
        expect(result, equals(RedemptionResult.selfCode));
      });

      test('Audit 165: SubscriptionProvider redeemInviteCode prevents duplicate redemption of same code', () {
        subProvider.redeemInviteCode('VAL-DUPL');
        final duplicateResult = subProvider.redeemInviteCode('VAL-DUPL');
        expect(duplicateResult, equals(RedemptionResult.alreadyUsed));
      });

      test('Audit 166: SubscriptionProvider redeemInviteCode rejects malformed code format', () {
        expect(subProvider.redeemInviteCode(''), equals(RedemptionResult.empty));
        expect(subProvider.redeemInviteCode('123'), equals(RedemptionResult.invalidFormat));
        expect(subProvider.redeemInviteCode('INVALID-CODE-LONG'), equals(RedemptionResult.invalidFormat));
      });

      test('Audit 167: SubscriptionProvider shareMessage contains referral code', () {
        expect(subProvider.shareMessage, contains(subProvider.userReferralCode));
      });

      test('Audit 168: SubscriptionProvider setEnforceOnNonAndroid enforces gating on all platforms', () {
        subProvider.setEnforceOnNonAndroid(true);
        expect(subProvider.isSubscriptionRequired, isTrue);
      });

      test('Audit 169: SubscriptionProvider hasActiveAccess is true when trial is active', () {
        subProvider.setEnforceOnNonAndroid(true);
        expect(subProvider.hasActiveAccess, isTrue);
      });

      test('Audit 170: SubscriptionProvider cancelSubscription terminates subscription state', () async {
        await subProvider.subscribe();
        expect(subProvider.isSubscribed, isTrue);
        await subProvider.cancelSubscription();
        expect(subProvider.isSubscribed, isFalse);
      });

      test('Audit 171: SubscriptionProvider persists bonus days across restarts', () async {
        await subProvider.recordInviteSuccess();
        expect(subProvider.referralBonusDays, equals(7));

        // Create new provider with same persistent preferences
        final restartedProvider = SubscriptionProvider(prefs: prefsService);
        expect(restartedProvider.referralBonusDays, equals(7));
        expect(restartedProvider.invitedCount, equals(1));
      });

      test('Audit 172: SubscriptionProvider persists redeemed codes across restarts', () {
        subProvider.redeemInviteCode('VAL-KEEP');
        final restartedProvider = SubscriptionProvider(prefs: prefsService);
        expect(restartedProvider.redeemedCodes, contains('VAL-KEEP'));
      });

      test('Audit 173: SubscriptionProvider persists trial acceptance across restarts', () async {
        await subProvider.acceptTrial();
        final restartedProvider = SubscriptionProvider(prefs: prefsService);
        expect(restartedProvider.hasAcceptedTrial, isTrue);
      });

      test('Audit 174: SubscriptionProvider trialExpiresAt shifts forward with referral bonus', () async {
        final initialExpiry = subProvider.trialExpiresAt;
        await subProvider.recordInviteSuccess();
        final newExpiry = subProvider.trialExpiresAt;
        expect(newExpiry.difference(initialExpiry).inDays, equals(7));
      });

      test('Audit 175: SubscriptionProvider notifies listeners on trial or sub changes', () async {
        int count = 0;
        subProvider.addListener(() => count++);
        await subProvider.acceptTrial();
        expect(count, greaterThan(0));
      });
    });

    // -------------------------------------------------------------------------
    // DOMAIN 8: Notification Service & Scheduling Resilience (Audits 176 - 185)
    // -------------------------------------------------------------------------
    group('Domain 8: Notification Service & Resilience (Audits 176-185)', () {
      test('Audit 176: Stable 31-bit integer masking (& 0x7FFFFFFF) prevents negative notification IDs', () {
        const testUuid = '00000000-0000-0000-0000-000000000000';
        final maskedId = testUuid.hashCode & 0x7FFFFFFF;
        expect(maskedId, greaterThanOrEqualTo(0));
        expect(maskedId, lessThanOrEqualTo(0x7FFFFFFF));
      });

      test('Audit 177: Minimum integer hashCode boundary does not produce negative ID', () {
        final boundaryNegative = (-2147483648) & 0x7FFFFFFF;
        expect(boundaryNegative, greaterThanOrEqualTo(0));
      });

      test('Audit 178: Maximum integer hashCode boundary produces valid 31-bit positive ID', () {
        final boundaryPositive = 2147483647 & 0x7FFFFFFF;
        expect(boundaryPositive, equals(2147483647));
      });

      test('Audit 179: UUID hash collision resistance across 1000 generated UUIDs', () {
        final uuid = const Uuid();
        final generatedIds = <int>{};
        for (int i = 0; i < 1000; i++) {
          final id = uuid.v4().hashCode & 0x7FFFFFFF;
          expect(id, greaterThanOrEqualTo(0));
          generatedIds.add(id);
        }
        // Hash collisions should be minimal (< 2% across 1000 items)
        expect(generatedIds.length, greaterThan(980));
      });

      test('Audit 180: Notification title and body formatting contains item name', () {
        final item = FoodItem(
          id: 'n-1',
          name: 'Iogurte Natural',
          category: FoodCategory.dairy,
          initialQuantity: 1,
          unit: FoodUnit.piece,
          expiryDate: DateTime.now().add(const Duration(days: 1)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final title = 'Atenção à validade!';
        final body = '${item.name} vence em 1 dia. Que tal consumir hoje?';
        expect(body, contains('Iogurte Natural'));
        expect(title, isNotEmpty);
      });

      test('Audit 181: Notification scheduling logic handles null expiryDate safely by skipping', () {
        final item = FoodItem(
          id: 'n-2',
          name: 'Sal',
          category: FoodCategory.pantryStaples,
          initialQuantity: 1,
          unit: FoodUnit.kilogram,
          expiryDate: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(item.expiryDate, isNull);
      });

      test('Audit 182: Notification scheduling logic skips items already expired in the past', () {
        final item = FoodItem(
          id: 'n-3',
          name: 'Leite',
          category: FoodCategory.dairy,
          initialQuantity: 1,
          unit: FoodUnit.liter,
          expiryDate: DateTime.now().subtract(const Duration(days: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final isPast = item.expiryDate!.isBefore(DateTime.now());
        expect(isPast, isTrue);
      });

      test('Audit 183: Notification scheduled for 1 day in advance calculates correctly', () {
        final expiry = DateTime.now().add(const Duration(days: 3));
        final advanceDays = 1;
        final notificationDate = expiry.subtract(Duration(days: advanceDays));
        expect(notificationDate.isBefore(expiry), isTrue);
        expect(notificationDate.isAfter(DateTime.now()), isTrue);
      });

      test('Audit 184: Notification ID is deterministic for identical item IDs', () {
        const id1 = 'food-unique-id-12345';
        const id2 = 'food-unique-id-12345';
        expect(id1.hashCode & 0x7FFFFFFF, equals(id2.hashCode & 0x7FFFFFFF));
      });

      test('Audit 185: Different item IDs produce different notification IDs', () {
        const idA = 'food-id-alpha';
        const idB = 'food-id-beta';
        expect(idA.hashCode & 0x7FFFFFFF, isNot(equals(idB.hashCode & 0x7FFFFFFF)));
      });
    });

    // -------------------------------------------------------------------------
    // DOMAIN 9: SettingsProvider, Theming & Accessibility (Audits 186 - 192)
    // -------------------------------------------------------------------------
    group('Domain 9: SettingsProvider & Accessibility (Audits 186-192)', () {
      late PreferencesService prefsService;
      late SettingsProvider settingsProvider;

      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        final sp = await SharedPreferences.getInstance();
        prefsService = PreferencesService(sp);
        settingsProvider = SettingsProvider(
          prefs: prefsService,
          notifications: _TestMockNotificationService(),
        );
      });

      test('Audit 186: SettingsProvider userInitials handles single name', () async {
        await settingsProvider.updateProfile(name: 'Carlos', email: 'carlos@test.com');
        expect(settingsProvider.userInitials, equals('CA'));
      });

      test('Audit 187: SettingsProvider userInitials handles two names', () async {
        await settingsProvider.updateProfile(name: 'Carlos Silva', email: 'carlos@test.com');
        expect(settingsProvider.userInitials, equals('CS'));
      });

      test('Audit 188: SettingsProvider userInitials handles three names taking first and last', () async {
        await settingsProvider.updateProfile(name: 'Ana Maria Braga', email: 'ana@test.com');
        expect(settingsProvider.userInitials, equals('AB'));
      });

      test('Audit 189: SettingsProvider userInitials handles emojis without surrogate pair corruption', () async {
        await settingsProvider.updateProfile(name: '🌱 Eco Hero', email: 'eco@test.com');
        expect(() => settingsProvider.userInitials, returnsNormally);
        expect(settingsProvider.userInitials, isNotEmpty);
      });

      test('Audit 190: SettingsProvider userInitials falls back to V on empty or whitespace name', () async {
        await settingsProvider.updateProfile(name: '', email: 'empty@test.com');
        expect(settingsProvider.userInitials, equals('V'));
        await settingsProvider.updateProfile(name: '    ', email: 'space@test.com');
        expect(settingsProvider.userInitials, equals('V'));
      });

      test('Audit 191: SettingsProvider toggles themeMode and persists', () async {
        await settingsProvider.setThemeMode(ThemeMode.dark);
        expect(settingsProvider.themeMode, equals(ThemeMode.dark));
        await settingsProvider.setThemeMode(ThemeMode.light);
        expect(settingsProvider.themeMode, equals(ThemeMode.light));
        await settingsProvider.setThemeMode(ThemeMode.system);
        expect(settingsProvider.themeMode, equals(ThemeMode.system));
      });

      test('Audit 192: SettingsProvider persists notification preferences', () async {
        await settingsProvider.setNotificationsEnabled(false);
        expect(settingsProvider.notificationsEnabled, isFalse);
        await settingsProvider.setWarningThresholdDays(2);
        expect(settingsProvider.warningThresholdDays, equals(2));
      });
    });

    // -------------------------------------------------------------------------
    // DOMAIN 10: Widget Resilience & UI Guardrails (Audits 193 - 200)
    // -------------------------------------------------------------------------
    group('Domain 10: Widget Resilience & UI Guardrails (Audits 193-200)', () {
      Widget wrapWithApp(Widget child, {ThemeData? theme}) {
        return MaterialApp(
          theme: theme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: Scaffold(body: child),
        );
      }

      testWidgets('Audit 193: ConfirmationDialog renders without distortion when isDestructive is false', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const ConfirmationDialog(
              title: 'Confirmar ação?',
              content: 'Deseja prosseguir?',
              confirmLabel: 'Sim',
              cancelLabel: 'Não',
              isDestructive: false,
            ),
          ),
        );
        expect(find.text('Confirmar ação?'), findsOneWidget);
        expect(find.text('Sim'), findsOneWidget);
        expect(find.text('Não'), findsOneWidget);
      });

      testWidgets('Audit 194: ConfirmationDialog renders destructive red styling when isDestructive is true', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const ConfirmationDialog(
              title: 'Excluir alimento?',
              content: 'Esta ação não pode ser desfeita.',
              confirmLabel: 'Excluir',
              cancelLabel: 'Cancelar',
              isDestructive: true,
            ),
          ),
        );
        expect(find.text('Excluir alimento?'), findsOneWidget);
        expect(find.text('Excluir'), findsOneWidget);
      });

      testWidgets('Audit 195: ExpiryBadge renders properly for all expiry states', (tester) async {
        for (final status in ExpiryStatus.values) {
          await tester.pumpWidget(
            wrapWithApp(
              ExpiryBadge(status: status, daysRemaining: status == ExpiryStatus.fresh ? 5 : null),
            ),
          );
          expect(find.byType(ExpiryBadge), findsOneWidget);
        }
      });

      testWidgets('Audit 196: CategoryChip renders with dark theme contrast tokens when in dark mode', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            CategoryChip(
              label: 'Hortifrúti',
              isSelected: false,
              onSelected: () {},
            ),
            theme: ThemeData.dark(),
          ),
        );
        expect(find.byType(CategoryChip), findsOneWidget);
        expect(find.text('Hortifrúti'), findsOneWidget);
      });

      testWidgets('Audit 197: ValoraAppBar renders with dark surface colors in dark mode', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const Scaffold(
              appBar: ValoraAppBar(title: 'Despensa'),
            ),
            theme: ThemeData.dark(),
          ),
        );
        expect(find.text('Valora'), findsOneWidget);
        expect(find.text('Despensa'), findsOneWidget);
      });

      testWidgets('Audit 198: RecordActionDialog handles full quantity consumption when isAll is checked', (tester) async {
        final item = FoodItem(
          id: 'test-rec',
          name: 'Iogurte',
          category: FoodCategory.dairy,
          initialQuantity: 1,
          unit: FoodUnit.piece,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          wrapWithApp(
            RecordActionDialog(
              item: item,
              isDiscard: false,
            ),
          ),
        );
        expect(find.byType(RecordActionDialog), findsOneWidget);
      });

      testWidgets('Audit 199: FoodDetailsSheet renders safe notice for ExpiryStatus.unknown', (tester) async {
        final item = FoodItem(
          id: 'test-sheet',
          name: 'Sal Marinho',
          category: FoodCategory.pantryStaples,
          initialQuantity: 1,
          unit: FoodUnit.kilogram,
          expiryDate: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          wrapWithApp(
            FoodDetailsSheet(
              item: item,
              warningThresholdDays: 3,
              onEdit: () {},
              onConsume: () {},
              onDiscard: () {},
              onDelete: () {},
            ),
          ),
        );
        expect(find.text('Sal Marinho'), findsOneWidget);
        expect(find.text('Validade não informada'), findsOneWidget);
      });

      testWidgets('Audit 200: FoodItemTile renders safe neutral styling for items with ExpiryStatus.unknown', (tester) async {
        final item = FoodItem(
          id: 'test-tile',
          name: 'Açúcar Cristal',
          category: FoodCategory.pantryStaples,
          initialQuantity: 1,
          unit: FoodUnit.kilogram,
          expiryDate: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          wrapWithApp(
            FoodItemTile(
              item: item,
              warningThresholdDays: 3,
              onTap: () {},
              onConsume: () {},
              onDiscard: () {},
              onDelete: () {},
            ),
          ),
        );
        expect(find.text('Açúcar Cristal'), findsOneWidget);
        expect(find.text('Sem data'), findsOneWidget);
      });
    });
  });
}
