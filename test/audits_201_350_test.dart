import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:valora/core/theme/app_colors.dart';
import 'package:valora/core/theme/app_theme.dart';
import 'package:valora/core/theme/app_typography.dart';
import 'package:valora/core/utils/currency_formatter.dart';
import 'package:valora/core/utils/text_utils.dart';
import 'package:valora/data/models/expiry_status.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_priority.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/storage_location.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Valora Audits 201-350', () {
    // =========================================================================
    // DOMAIN 1: FoodPriority, Ranking & Urgency Intelligence (Audits 201-250)
    // =========================================================================
    group('Domain 1: FoodPriority, Ranking & Urgency Intelligence (Audits 201-250)', () {
      final baseDate = DateTime(2026, 10, 18, 12, 0);

      FoodItem makeItem({
        required String id,
        required String name,
        DateTime? expiryDate,
        double initialQuantity = 1.0,
        double consumedQuantity = 0.0,
        double discardedQuantity = 0.0,
        FoodLifecycleStatus status = FoodLifecycleStatus.active,
      }) {
        return FoodItem(
          id: id,
          name: name,
          category: FoodCategory.pantryStaples,
          initialQuantity: initialQuantity,
          consumedQuantity: consumedQuantity,
          discardedQuantity: discardedQuantity,
          unit: FoodUnit.kilogram,
          expiryDate: expiryDate,
          status: status,
          createdAt: baseDate,
          updatedAt: baseDate,
        );
      }

      test('Audit 201: FoodPriority enum order has exactly 6 tiers', () {
        expect(FoodPriority.values.length, equals(6));
      });

      test('Audit 202: FoodPriority.expired urgencyRank is 0', () {
        expect(FoodPriority.expired.urgencyRank, equals(0));
      });

      test('Audit 203: FoodPriority.consumeToday urgencyRank is 1', () {
        expect(FoodPriority.consumeToday.urgencyRank, equals(1));
      });

      test('Audit 204: FoodPriority.highPriority urgencyRank is 2', () {
        expect(FoodPriority.highPriority.urgencyRank, equals(2));
      });

      test('Audit 205: FoodPriority.attention urgencyRank is 3', () {
        expect(FoodPriority.attention.urgencyRank, equals(3));
      });

      test('Audit 206: FoodPriority.onTrack urgencyRank is 4', () {
        expect(FoodPriority.onTrack.urgencyRank, equals(4));
      });

      test('Audit 207: FoodPriority.unknownExpiry urgencyRank is 5', () {
        expect(FoodPriority.unknownExpiry.urgencyRank, equals(5));
      });

      test('Audit 208: FoodPriority.expired isUrgent is true', () {
        expect(FoodPriority.expired.isUrgent, isTrue);
      });

      test('Audit 209: FoodPriority.consumeToday isUrgent is true', () {
        expect(FoodPriority.consumeToday.isUrgent, isTrue);
      });

      test('Audit 210: FoodPriority.highPriority isUrgent is true', () {
        expect(FoodPriority.highPriority.isUrgent, isTrue);
      });

      test('Audit 211: FoodPriority.attention isUrgent is true', () {
        expect(FoodPriority.attention.isUrgent, isTrue);
      });

      test('Audit 212: FoodPriority.onTrack isUrgent is false', () {
        expect(FoodPriority.onTrack.isUrgent, isFalse);
      });

      test('Audit 213: FoodPriority.unknownExpiry isUrgent is false', () {
        expect(FoodPriority.unknownExpiry.isUrgent, isFalse);
      });

      test('Audit 214: FoodPriority maxDaysRemaining mapping for bounded tiers', () {
        expect(FoodPriority.consumeToday.maxDaysRemaining, equals(0));
        expect(FoodPriority.highPriority.maxDaysRemaining, equals(3));
        expect(FoodPriority.attention.maxDaysRemaining, equals(7));
      });

      test('Audit 215: FoodPriority maxDaysRemaining is null for unbounded tiers', () {
        expect(FoodPriority.expired.maxDaysRemaining, isNull);
        expect(FoodPriority.onTrack.maxDaysRemaining, isNull);
        expect(FoodPriority.unknownExpiry.maxDaysRemaining, isNull);
      });

      test('Audit 216: FoodPriorityCalculator.classifyFromDays with negative days returns expired', () {
        expect(FoodPriorityCalculator.classifyFromDays(-1), equals(FoodPriority.expired));
        expect(FoodPriorityCalculator.classifyFromDays(-100), equals(FoodPriority.expired));
      });

      test('Audit 217: FoodPriorityCalculator.classifyFromDays with 0 days returns consumeToday', () {
        expect(FoodPriorityCalculator.classifyFromDays(0), equals(FoodPriority.consumeToday));
      });

      test('Audit 218: FoodPriorityCalculator.classifyFromDays with 1, 2, 3 days returns highPriority', () {
        expect(FoodPriorityCalculator.classifyFromDays(1), equals(FoodPriority.highPriority));
        expect(FoodPriorityCalculator.classifyFromDays(2), equals(FoodPriority.highPriority));
        expect(FoodPriorityCalculator.classifyFromDays(3), equals(FoodPriority.highPriority));
      });

      test('Audit 219: FoodPriorityCalculator.classifyFromDays with 4, 5, 6, 7 days returns attention', () {
        expect(FoodPriorityCalculator.classifyFromDays(4), equals(FoodPriority.attention));
        expect(FoodPriorityCalculator.classifyFromDays(5), equals(FoodPriority.attention));
        expect(FoodPriorityCalculator.classifyFromDays(6), equals(FoodPriority.attention));
        expect(FoodPriorityCalculator.classifyFromDays(7), equals(FoodPriority.attention));
      });

      test('Audit 220: FoodPriorityCalculator.classifyFromDays with > 7 days returns onTrack', () {
        expect(FoodPriorityCalculator.classifyFromDays(8), equals(FoodPriority.onTrack));
        expect(FoodPriorityCalculator.classifyFromDays(365), equals(FoodPriority.onTrack));
      });

      test('Audit 221: FoodPriorityCalculator.classifyFromDays with null returns unknownExpiry', () {
        expect(FoodPriorityCalculator.classifyFromDays(null), equals(FoodPriority.unknownExpiry));
      });

      test('Audit 222: FoodPriorityCalculator.classify with null expiry returns unknownExpiry', () {
        final item = makeItem(id: '1', name: 'Arroz', expiryDate: null);
        expect(FoodPriorityCalculator.classify(item, referenceDate: baseDate), equals(FoodPriority.unknownExpiry));
      });

      test('Audit 223: FoodPriorityCalculator.classify preserves calendar day regardless of clock hour (23:59 vs 00:01)', () {
        final refDate = DateTime(2026, 10, 18, 23, 59);
        final expiry = DateTime(2026, 10, 19, 0, 1);
        final item = makeItem(id: '1', name: 'Leite', expiryDate: expiry);
        expect(FoodPriorityCalculator.classify(item, referenceDate: refDate), equals(FoodPriority.highPriority));
      });

      test('Audit 224: PrioritizedFood value equality with operator ==', () {
        final item = makeItem(id: '1', name: 'Feijão');
        final pf1 = PrioritizedFood(item: item, priority: FoodPriority.highPriority, daysRemaining: 2);
        final pf2 = PrioritizedFood(item: item, priority: FoodPriority.highPriority, daysRemaining: 2);
        expect(pf1, equals(pf2));
      });

      test('Audit 225: PrioritizedFood hashCode matches for equal objects', () {
        final item = makeItem(id: '1', name: 'Feijão');
        final pf1 = PrioritizedFood(item: item, priority: FoodPriority.highPriority, daysRemaining: 2);
        final pf2 = PrioritizedFood(item: item, priority: FoodPriority.highPriority, daysRemaining: 2);
        expect(pf1.hashCode, equals(pf2.hashCode));
      });

      test('Audit 226: PrioritizedFood toString contains item name and priority', () {
        final item = makeItem(id: '1', name: 'Iogurte');
        final pf = PrioritizedFood(item: item, priority: FoodPriority.consumeToday, daysRemaining: 0);
        expect(pf.toString(), contains('Iogurte'));
        expect(pf.toString(), contains('consumeToday'));
      });

      test('Audit 227: PriorityInsight.empty default state has 0 counts and noneUrgent kind', () {
        expect(PriorityInsight.empty.kind, equals(PriorityInsightKind.noneUrgent));
        expect(PriorityInsight.empty.expiredCount, equals(0));
        expect(PriorityInsight.empty.expiringTodayCount, equals(0));
        expect(PriorityInsight.empty.expiringTomorrowCount, equals(0));
        expect(PriorityInsight.empty.urgentCount, equals(0));
      });

      test('Audit 228: PriorityInsight operator == and hashCode consistency', () {
        const pi1 = PriorityInsight(
          kind: PriorityInsightKind.expired,
          expiredCount: 2,
          expiringTodayCount: 1,
          expiringTomorrowCount: 0,
          urgentCount: 3,
        );
        const pi2 = PriorityInsight(
          kind: PriorityInsightKind.expired,
          expiredCount: 2,
          expiringTodayCount: 1,
          expiringTomorrowCount: 0,
          urgentCount: 3,
        );
        expect(pi1, equals(pi2));
        expect(pi1.hashCode, equals(pi2.hashCode));
      });

      test('Audit 229: PriorityInsight toString displays kind and all counts', () {
        const pi = PriorityInsight(
          kind: PriorityInsightKind.expiringToday,
          expiredCount: 0,
          expiringTodayCount: 3,
          expiringTomorrowCount: 1,
          urgentCount: 4,
        );
        expect(pi.toString(), contains('expiringToday'));
        expect(pi.toString(), contains('today: 3'));
      });

      test('Audit 230: consumeFirst excludes consumed foods even if expiring today', () {
        final item = makeItem(
          id: '1',
          name: 'Iogurte',
          expiryDate: baseDate,
          status: FoodLifecycleStatus.consumed,
        );
        final result = FoodPriorityCalculator.consumeFirst([item], referenceDate: baseDate);
        expect(result, isEmpty);
      });

      test('Audit 231: consumeFirst excludes discarded foods even if expired', () {
        final item = makeItem(
          id: '1',
          name: 'Pão',
          expiryDate: baseDate.subtract(const Duration(days: 2)),
          status: FoodLifecycleStatus.discarded,
        );
        final result = FoodPriorityCalculator.consumeFirst([item], referenceDate: baseDate);
        expect(result, isEmpty);
      });

      test('Audit 232: consumeFirst excludes archived foods', () {
        final item = makeItem(
          id: '1',
          name: 'Manteiga',
          expiryDate: baseDate,
          status: FoodLifecycleStatus.archived,
        );
        final result = FoodPriorityCalculator.consumeFirst([item], referenceDate: baseDate);
        expect(result, isEmpty);
      });

      test('Audit 233: consumeFirst excludes depleted foods (remainingQuantity <= 0)', () {
        final item = makeItem(
          id: '1',
          name: 'Leite',
          expiryDate: baseDate,
          initialQuantity: 1.0,
          consumedQuantity: 1.0,
        );
        final result = FoodPriorityCalculator.consumeFirst([item], referenceDate: baseDate);
        expect(result, isEmpty);
      });

      test('Audit 234: consumeFirst excludes onTrack foods (> 7 days remaining)', () {
        final item = makeItem(
          id: '1',
          name: 'Arroz',
          expiryDate: baseDate.add(const Duration(days: 15)),
        );
        final result = FoodPriorityCalculator.consumeFirst([item], referenceDate: baseDate);
        expect(result, isEmpty);
      });

      test('Audit 235: consumeFirst excludes unknown expiry foods', () {
        final item = makeItem(id: '1', name: 'Sal', expiryDate: null);
        final result = FoodPriorityCalculator.consumeFirst([item], referenceDate: baseDate);
        expect(result, isEmpty);
      });

      test('Audit 236: consumeFirst sorts expired items before consumeToday', () {
        final exp = makeItem(id: '1', name: 'Queijo', expiryDate: baseDate.subtract(const Duration(days: 1)));
        final today = makeItem(id: '2', name: 'Iogurte', expiryDate: baseDate);
        final result = FoodPriorityCalculator.consumeFirst([today, exp], referenceDate: baseDate);
        expect(result.first.item.id, equals('1'));
        expect(result.last.item.id, equals('2'));
      });

      test('Audit 237: consumeFirst sorts consumeToday before highPriority', () {
        final today = makeItem(id: '1', name: 'Iogurte', expiryDate: baseDate);
        final high = makeItem(id: '2', name: 'Leite', expiryDate: baseDate.add(const Duration(days: 2)));
        final result = FoodPriorityCalculator.consumeFirst([high, today], referenceDate: baseDate);
        expect(result.first.item.id, equals('1'));
        expect(result.last.item.id, equals('2'));
      });

      test('Audit 238: consumeFirst sorts highPriority before attention', () {
        final high = makeItem(id: '1', name: 'Leite', expiryDate: baseDate.add(const Duration(days: 2)));
        final att = makeItem(id: '2', name: 'Maçã', expiryDate: baseDate.add(const Duration(days: 5)));
        final result = FoodPriorityCalculator.consumeFirst([att, high], referenceDate: baseDate);
        expect(result.first.item.id, equals('1'));
        expect(result.last.item.id, equals('2'));
      });

      test('Audit 239: consumeFirst tie-breaker 1: fewer days remaining comes first', () {
        final itemA = makeItem(id: '1', name: 'Banana', expiryDate: baseDate.add(const Duration(days: 2)));
        final itemB = makeItem(id: '2', name: 'Maçã', expiryDate: baseDate.add(const Duration(days: 1)));
        final result = FoodPriorityCalculator.consumeFirst([itemA, itemB], referenceDate: baseDate);
        expect(result.first.item.id, equals('2'));
      });

      test('Audit 240: consumeFirst tie-breaker 2: larger remaining quantity comes first', () {
        final itemSmall = makeItem(id: '1', name: 'Carne P', expiryDate: baseDate.add(const Duration(days: 2)), initialQuantity: 0.5);
        final itemLarge = makeItem(id: '2', name: 'Carne G', expiryDate: baseDate.add(const Duration(days: 2)), initialQuantity: 2.0);
        final result = FoodPriorityCalculator.consumeFirst([itemSmall, itemLarge], referenceDate: baseDate);
        expect(result.first.item.id, equals('2'));
        expect(result.last.item.id, equals('1'));
      });

      test('Audit 241: consumeFirst tie-breaker 3: alphabetical name normalized tie-break', () {
        final itemZ = makeItem(id: '1', name: 'Zimbro', expiryDate: baseDate.add(const Duration(days: 2)), initialQuantity: 1.0);
        final itemA = makeItem(id: '2', name: 'Alecrim', expiryDate: baseDate.add(const Duration(days: 2)), initialQuantity: 1.0);
        final result = FoodPriorityCalculator.consumeFirst([itemZ, itemA], referenceDate: baseDate);
        expect(result.first.item.name, equals('Alecrim'));
        expect(result.last.item.name, equals('Zimbro'));
      });

      test('Audit 242: buildInsight on empty list returns PriorityInsight.empty', () {
        final insight = FoodPriorityCalculator.buildInsight([]);
        expect(insight, equals(PriorityInsight.empty));
      });

      test('Audit 243: buildInsight with expired items sets kind to PriorityInsightKind.expired', () {
        final item = makeItem(id: '1', name: 'Queijo', expiryDate: baseDate.subtract(const Duration(days: 1)));
        final ranked = FoodPriorityCalculator.consumeFirst([item], referenceDate: baseDate);
        final insight = FoodPriorityCalculator.buildInsight(ranked);
        expect(insight.kind, equals(PriorityInsightKind.expired));
        expect(insight.expiredCount, equals(1));
      });

      test('Audit 244: buildInsight with today items (no expired) sets kind to expiringToday', () {
        final item = makeItem(id: '1', name: 'Iogurte', expiryDate: baseDate);
        final ranked = FoodPriorityCalculator.consumeFirst([item], referenceDate: baseDate);
        final insight = FoodPriorityCalculator.buildInsight(ranked);
        expect(insight.kind, equals(PriorityInsightKind.expiringToday));
        expect(insight.expiringTodayCount, equals(1));
        expect(insight.expiredCount, equals(0));
      });

      test('Audit 245: buildInsight with tomorrow items (daysRemaining == 1) sets kind to expiringTomorrow', () {
        final item = makeItem(id: '1', name: 'Presunto', expiryDate: baseDate.add(const Duration(days: 1)));
        final ranked = FoodPriorityCalculator.consumeFirst([item], referenceDate: baseDate);
        final insight = FoodPriorityCalculator.buildInsight(ranked);
        expect(insight.kind, equals(PriorityInsightKind.expiringTomorrow));
        expect(insight.expiringTomorrowCount, equals(1));
      });

      test('Audit 246: buildInsight with 2-7 days items sets kind to generalPriority', () {
        final item = makeItem(id: '1', name: 'Tomate', expiryDate: baseDate.add(const Duration(days: 3)));
        final ranked = FoodPriorityCalculator.consumeFirst([item], referenceDate: baseDate);
        final insight = FoodPriorityCalculator.buildInsight(ranked);
        expect(insight.kind, equals(PriorityInsightKind.generalPriority));
        expect(insight.urgentCount, equals(1));
      });

      test('Audit 247: buildInsight prioritizes expired severity over today and tomorrow', () {
        final exp = makeItem(id: '1', name: 'Queijo', expiryDate: baseDate.subtract(const Duration(days: 1)));
        final today = makeItem(id: '2', name: 'Iogurte', expiryDate: baseDate);
        final tom = makeItem(id: '3', name: 'Leite', expiryDate: baseDate.add(const Duration(days: 1)));
        final ranked = FoodPriorityCalculator.consumeFirst([exp, today, tom], referenceDate: baseDate);
        final insight = FoodPriorityCalculator.buildInsight(ranked);
        expect(insight.kind, equals(PriorityInsightKind.expired));
        expect(insight.expiredCount, equals(1));
        expect(insight.expiringTodayCount, equals(1));
        expect(insight.expiringTomorrowCount, equals(1));
        expect(insight.urgentCount, equals(3));
      });

      test('Audit 248: FoodPriorityCalculator handles negative remaining quantities safely', () {
        final item = makeItem(id: '1', name: 'Erro', expiryDate: baseDate, initialQuantity: 1.0, consumedQuantity: 2.0);
        final result = FoodPriorityCalculator.consumeFirst([item], referenceDate: baseDate);
        expect(result, isEmpty);
      });

      test('Audit 249: FoodPriorityCalculator handles year 2099 future dates safely without overflow', () {
        final item = makeItem(id: '1', name: 'Semente', expiryDate: DateTime(2099, 12, 31));
        expect(FoodPriorityCalculator.classify(item, referenceDate: baseDate), equals(FoodPriority.onTrack));
      });

      test('Audit 250: FoodPriorityCalculator handles leap year February 29 dates precisely', () {
        final leapBase = DateTime(2028, 2, 28);
        final leapItem = makeItem(id: '1', name: 'Salada', expiryDate: DateTime(2028, 2, 29));
        expect(FoodPriorityCalculator.classify(leapItem, referenceDate: leapBase), equals(FoodPriority.highPriority));
        final diff = ExpiryStatus.daysRemaining(expiryDate: leapItem.expiryDate, referenceDate: leapBase);
        expect(diff, equals(1));
      });
    });

    // =========================================================================
    // DOMAIN 2: Formatting, String Utilities & FoodUnit Intelligence (Audits 251-300)
    // =========================================================================
    group('Domain 2: Formatting & Utilities (Audits 251-300)', () {
      test('Audit 251: CurrencyFormatter.format returns empty string on null amount', () {
        expect(CurrencyFormatter.format(null), equals(''));
      });

      test('Audit 252: CurrencyFormatter.format returns empty string on double.nan', () {
        expect(CurrencyFormatter.format(double.nan), equals(''));
      });

      test('Audit 253: CurrencyFormatter.format returns empty string on double.infinity', () {
        expect(CurrencyFormatter.format(double.infinity), equals(''));
      });

      test('Audit 254: CurrencyFormatter.format returns empty string on double.negativeInfinity', () {
        expect(CurrencyFormatter.format(double.negativeInfinity), equals(''));
      });

      test('Audit 255: CurrencyFormatter.format formats zero correctly in default en_US', () {
        expect(CurrencyFormatter.format(0.0), contains('0.00'));
      });

      test('Audit 256: CurrencyFormatter.format formats positive value in pt_BR locale', () {
        final formatted = CurrencyFormatter.format(12.50, localeCode: 'pt_BR');
        expect(formatted, contains('12,50'));
      });

      test('Audit 257: CurrencyFormatter.format formats thousand separator in pt_BR', () {
        final formatted = CurrencyFormatter.format(1250.75, localeCode: 'pt_BR');
        expect(formatted, contains('1.250,75'));
      });

      test('Audit 258: CurrencyFormatter.format handles fallback gracefully on invalid localeCode', () {
        final formatted = CurrencyFormatter.format(42.0, localeCode: 'INVALID_LOCALE_XYZ');
        expect(formatted, isNotEmpty);
        expect(formatted, contains('42'));
      });

      test('Audit 259: TextUtils.normalize converts uppercase to lowercase', () {
        expect(TextUtils.normalize('VALORA PANTRY'), equals('valora pantry'));
      });

      test('Audit 260: TextUtils.normalize strips leading and trailing whitespace', () {
        expect(TextUtils.normalize('   leite integral   '), equals('leite integral'));
      });

      test('Audit 261: TextUtils.normalize condenses multiple consecutive whitespace characters', () {
        expect(TextUtils.normalize('arroz    tipo   1'), equals('arroz tipo 1'));
      });

      test('Audit 262: TextUtils.normalize strips acute accents (á, é, í, ó, ú)', () {
        expect(TextUtils.normalize('café açúcar maracujá'), equals('cafe acucar maracuja'));
      });

      test('Audit 263: TextUtils.normalize strips circumflex accents (â, ê, ô)', () {
        expect(TextUtils.normalize('pêssego estômago câmara'), equals('pessego estomago camara'));
      });

      test('Audit 264: TextUtils.normalize strips tildes (ã, õ)', () {
        expect(TextUtils.normalize('maçã pão feijões'), equals('maca pao feijoes'));
      });

      test('Audit 265: TextUtils.normalize strips cedillas (ç, Ç)', () {
        expect(TextUtils.normalize('Açúcar AÇÚCAR'), equals('acucar acucar'));
      });

      test('Audit 266: TextUtils.normalize strips diaeresis / umlaut (ü, ö, ä, ë, ï)', () {
        expect(TextUtils.normalize('Müller über'), equals('muller uber'));
      });

      test('Audit 267: TextUtils.normalize returns empty string on empty input', () {
        expect(TextUtils.normalize(''), equals(''));
      });

      test('Audit 268: TextUtils.matchesSearch matches exact string', () {
        expect(TextUtils.matchesSearch('Feijão Preto', 'Feijão Preto'), isTrue);
      });

      test('Audit 269: TextUtils.matchesSearch matches regardless of case difference', () {
        expect(TextUtils.matchesSearch('feijao', 'FEIJAO'), isTrue);
      });

      test('Audit 270: TextUtils.matchesSearch matches accented target with unaccented query', () {
        expect(TextUtils.matchesSearch('Maçã Gala', 'maca'), isTrue);
      });

      test('Audit 271: TextUtils.matchesSearch matches unaccented target with accented query', () {
        expect(TextUtils.matchesSearch('maca gala', 'Maçã'), isTrue);
      });

      test('Audit 272: TextUtils.matchesSearch returns true on empty query for any target', () {
        expect(TextUtils.matchesSearch('Qualquer Alimento', ''), isTrue);
        expect(TextUtils.matchesSearch('Qualquer Alimento', '   '), isTrue);
      });

      test('Audit 273: TextUtils.matchesSearch returns false on empty target with non-empty query', () {
        expect(TextUtils.matchesSearch('', 'arroz'), isFalse);
      });

      test('Audit 274: TextUtils.matchesSearch handles substring search anywhere in target', () {
        expect(TextUtils.matchesSearch('Leite Integral Parmalat', 'integral'), isTrue);
      });

      test('Audit 275: FoodUnit.formatQuantity formats whole numbers without .0', () {
        expect(FoodUnit.formatQuantity(1.0), equals('1'));
        expect(FoodUnit.formatQuantity(5.0), equals('5'));
        expect(FoodUnit.formatQuantity(100.0), equals('100'));
      });

      test('Audit 276: FoodUnit.formatQuantity formats single-decimal values without trailing zero', () {
        expect(FoodUnit.formatQuantity(1.5), equals('1.5'));
        expect(FoodUnit.formatQuantity(2.7), equals('2.7'));
      });

      test('Audit 277: FoodUnit.formatQuantity formats two decimals accurately', () {
        expect(FoodUnit.formatQuantity(1.25), equals('1.25'));
        expect(FoodUnit.formatQuantity(0.75), equals('0.75'));
      });

      test('Audit 278: FoodUnit.formatQuantity rounds to max 2 decimals', () {
        expect(FoodUnit.formatQuantity(1.33333), equals('1.33'));
        expect(FoodUnit.formatQuantity(2.66666), equals('2.67'));
      });

      test('Audit 279: FoodUnit.formatQuantity returns "0" for double.nan', () {
        expect(FoodUnit.formatQuantity(double.nan), equals('0'));
      });

      test('Audit 280: FoodUnit.formatQuantity returns "0" for double.infinity', () {
        expect(FoodUnit.formatQuantity(double.infinity), equals('0'));
      });

      test('Audit 281: FoodUnit.formatQuantity returns "0" for double.negativeInfinity', () {
        expect(FoodUnit.formatQuantity(double.negativeInfinity), equals('0'));
      });

      test('Audit 282: FoodUnit.formatQuantity returns "0" for negative or near-zero quantities', () {
        expect(FoodUnit.formatQuantity(0.0), equals('0'));
        expect(FoodUnit.formatQuantity(0.00005), equals('0'));
        expect(FoodUnit.formatQuantity(-1.5), equals('0'));
      });

      test('Audit 283: FoodUnit shortSymbol for piece is un', () {
        expect(FoodUnit.piece.shortSymbol, equals('un'));
      });

      test('Audit 284: FoodUnit shortSymbol for gram is g', () {
        expect(FoodUnit.gram.shortSymbol, equals('g'));
      });

      test('Audit 285: FoodUnit shortSymbol for kilogram is kg', () {
        expect(FoodUnit.kilogram.shortSymbol, equals('kg'));
      });

      test('Audit 286: FoodUnit shortSymbol for milliliter is ml', () {
        expect(FoodUnit.milliliter.shortSymbol, equals('ml'));
      });

      test('Audit 287: FoodUnit shortSymbol for liter is L', () {
        expect(FoodUnit.liter.shortSymbol, equals('L'));
      });

      test('Audit 288: FoodUnit shortSymbol for package is pct', () {
        expect(FoodUnit.package.shortSymbol, equals('pct'));
      });

      test('Audit 289: FoodUnit.fromString parses "kg", "kilo", "kilogram" to kilogram', () {
        expect(FoodUnit.fromString('kg'), equals(FoodUnit.kilogram));
        expect(FoodUnit.fromString('kilo'), equals(FoodUnit.kilogram));
        expect(FoodUnit.fromString('kilogram'), equals(FoodUnit.kilogram));
      });

      test('Audit 290: FoodUnit.fromString parses "g", "gram", "grama" to gram', () {
        expect(FoodUnit.fromString('g'), equals(FoodUnit.gram));
        expect(FoodUnit.fromString('gram'), equals(FoodUnit.gram));
        expect(FoodUnit.fromString('grama'), equals(FoodUnit.gram));
      });

      test('Audit 291: FoodUnit.fromString parses "l", "liter", "litro" to liter', () {
        expect(FoodUnit.fromString('l'), equals(FoodUnit.liter));
        expect(FoodUnit.fromString('liter'), equals(FoodUnit.liter));
        expect(FoodUnit.fromString('litro'), equals(FoodUnit.liter));
      });

      test('Audit 292: FoodUnit.fromString parses "ml", "milliliter", "mililitro" to milliliter', () {
        expect(FoodUnit.fromString('ml'), equals(FoodUnit.milliliter));
        expect(FoodUnit.fromString('milliliter'), equals(FoodUnit.milliliter));
        expect(FoodUnit.fromString('mililitro'), equals(FoodUnit.milliliter));
      });

      test('Audit 293: FoodUnit.fromString parses "pct", "pack", "package", "pacote" to package', () {
        expect(FoodUnit.fromString('pct'), equals(FoodUnit.package));
        expect(FoodUnit.fromString('pack'), equals(FoodUnit.package));
        expect(FoodUnit.fromString('package'), equals(FoodUnit.package));
        expect(FoodUnit.fromString('pacote'), equals(FoodUnit.package));
      });

      test('Audit 294: FoodUnit.fromString parses "un", "unit", "unidade", "piece" to piece', () {
        expect(FoodUnit.fromString('un'), equals(FoodUnit.piece));
        expect(FoodUnit.fromString('unit'), equals(FoodUnit.piece));
        expect(FoodUnit.fromString('unidade'), equals(FoodUnit.piece));
        expect(FoodUnit.fromString('piece'), equals(FoodUnit.piece));
      });

      test('Audit 295: FoodUnit.fromString defaults to piece on unknown input', () {
        expect(FoodUnit.fromString('unknown_unit_xyz'), equals(FoodUnit.piece));
        expect(FoodUnit.fromString(''), equals(FoodUnit.piece));
      });

      test('Audit 296: FoodCategory.fromString parses case-insensitively and removes separators', () {
        expect(FoodCategory.fromString('fruits'), equals(FoodCategory.fruits));
        expect(FoodCategory.fromString('meat-fish'), equals(FoodCategory.meatFish));
        expect(FoodCategory.fromString('meat_fish'), equals(FoodCategory.meatFish));
        expect(FoodCategory.fromString('pantry_staples'), equals(FoodCategory.pantryStaples));
      });

      test('Audit 297: FoodCategory.fromString defaults to other on unrecognized string', () {
        expect(FoodCategory.fromString('unrecognized_cat'), equals(FoodCategory.other));
      });

      test('Audit 298: StorageLocation.fromString matches case-insensitively', () {
        expect(StorageLocation.fromString('refrigerator'), equals(StorageLocation.refrigerator));
        expect(StorageLocation.fromString('REFRIGERATOR'), equals(StorageLocation.refrigerator));
        expect(StorageLocation.fromString('freezer'), equals(StorageLocation.freezer));
        expect(StorageLocation.fromString('pantry'), equals(StorageLocation.pantry));
      });

      test('Audit 299: StorageLocation.fromString defaults to other on unrecognized string', () {
        expect(StorageLocation.fromString('somewhere_else'), equals(StorageLocation.other));
      });

      test('Audit 300: FoodLifecycleStatus.fromString matches active, consumed, discarded, archived', () {
        expect(FoodLifecycleStatus.fromString('active'), equals(FoodLifecycleStatus.active));
        expect(FoodLifecycleStatus.fromString('consumed'), equals(FoodLifecycleStatus.consumed));
        expect(FoodLifecycleStatus.fromString('discarded'), equals(FoodLifecycleStatus.discarded));
        expect(FoodLifecycleStatus.fromString('archived'), equals(FoodLifecycleStatus.archived));
        expect(FoodLifecycleStatus.fromString('unknown'), equals(FoodLifecycleStatus.active));
      });
    });

    // =========================================================================
    // DOMAIN 3: Design System, Tokens, AppColors & AppTheme (Audits 301-350)
    // =========================================================================
    group('Domain 3: Design System Tokens & Theme (Audits 301-350)', () {
      test('Audit 301: AppColors.forestGreen primary brand token has correct ARGB value', () {
        expect(AppColors.forestGreen.toARGB32(), equals(0xFF294D3A));
      });

      test('Audit 302: AppColors.sageGreen secondary brand token has correct ARGB value', () {
        expect(AppColors.sageGreen.toARGB32(), equals(0xFF91A98B));
      });

      test('Audit 303: AppColors.warmCream base background token has correct ARGB value', () {
        expect(AppColors.warmCream.toARGB32(), equals(0xFFF7F5ED));
      });

      test('Audit 304: AppColors.softWhite card and sheet token has correct ARGB value', () {
        expect(AppColors.softWhite.toARGB32(), equals(0xFFFFFEFA));
      });

      test('Audit 305: AppColors.charcoal high-emphasis text token has correct ARGB value', () {
        expect(AppColors.charcoal.toARGB32(), equals(0xFF292D29));
      });

      test('Audit 306: AppColors.border structural border token has correct ARGB value', () {
        expect(AppColors.border.toARGB32(), equals(0xFFE7E7DE));
      });

      test('Audit 307: AppColors.statusSafeBg semantic fresh background token value', () {
        expect(AppColors.statusSafeBg.toARGB32(), equals(0xFFEBF2E9));
      });

      test('Audit 308: AppColors.statusSafeText semantic fresh text token value', () {
        expect(AppColors.statusSafeText.toARGB32(), equals(0xFF294D3A));
      });

      test('Audit 309: AppColors.statusWarningBg semantic warning background token value', () {
        expect(AppColors.statusWarningBg.toARGB32(), equals(0xFFFDF4E5));
      });

      test('Audit 310: AppColors.statusWarningText semantic warning text token value', () {
        expect(AppColors.statusWarningText.toARGB32(), equals(0xFF8C5B14));
      });

      test('Audit 311: AppColors.statusWarningDot semantic warning dot indicator token value', () {
        expect(AppColors.statusWarningDot.toARGB32(), equals(0xFFD97706));
      });

      test('Audit 312: AppColors.statusCriticalBg semantic critical background token value', () {
        expect(AppColors.statusCriticalBg.toARGB32(), equals(0xFFFCE8E6));
      });

      test('Audit 313: AppColors.statusCriticalText semantic critical text token value', () {
        expect(AppColors.statusCriticalText.toARGB32(), equals(0xFF991B1B));
      });

      test('Audit 314: AppColors.statusCriticalDot semantic critical dot indicator token value', () {
        expect(AppColors.statusCriticalDot.toARGB32(), equals(0xFFDC2626));
      });

      test('Audit 315: AppColors dark theme background token is deep dark green/black', () {
        expect(AppColors.darkBackground.toARGB32(), equals(0xFF111714));
      });

      test('Audit 316: AppColors dark theme surface token is distinct from darkBackground', () {
        expect(AppColors.darkSurface.toARGB32(), equals(0xFF1B231F));
        expect(AppColors.darkSurface, isNot(equals(AppColors.darkBackground)));
      });

      test('Audit 317: AppColors dark theme border provides visible structural contrast', () {
        expect(AppColors.darkBorder.toARGB32(), equals(0xFF2E3B34));
      });

      test('Audit 318: AppColors dark text tokens (primary, secondary, tertiary) are opaque', () {
        expect((AppColors.textPrimaryDark.a * 255.0).round(), equals(255));
        expect((AppColors.textSecondaryDark.a * 255.0).round(), equals(255));
        expect((AppColors.textTertiaryDark.a * 255.0).round(), equals(255));
      });

      test('Audit 319: AppColors light text tokens (primary, secondary, tertiary) are opaque', () {
        expect((AppColors.textPrimaryLight.a * 255.0).round(), equals(255));
        expect((AppColors.textSecondaryLight.a * 255.0).round(), equals(255));
        expect((AppColors.textTertiaryLight.a * 255.0).round(), equals(255));
      });

      test('Audit 320: ExpiryStatus.expired badgeBackgroundColor returns dark token in dark mode', () {
        expect(ExpiryStatus.expired.badgeBackgroundColor(true), equals(AppColors.statusExpiredBgDark));
      });

      test('Audit 321: ExpiryStatus.expiringToday badgeBackgroundColor returns dark token in dark mode', () {
        expect(ExpiryStatus.expiringToday.badgeBackgroundColor(true), equals(AppColors.statusExpiringTodayBgDark));
      });

      test('Audit 322: ExpiryStatus.expiringSoon badgeBackgroundColor returns dark token in dark mode', () {
        expect(ExpiryStatus.expiringSoon.badgeBackgroundColor(true), equals(AppColors.statusExpiringSoonBgDark));
      });

      test('Audit 323: ExpiryStatus.fresh badgeBackgroundColor returns dark token in dark mode', () {
        expect(ExpiryStatus.fresh.badgeBackgroundColor(true), equals(AppColors.statusFreshBgDark));
      });

      test('Audit 324: ExpiryStatus.unknown badgeBackgroundColor returns dark token in dark mode', () {
        expect(ExpiryStatus.unknown.badgeBackgroundColor(true), equals(AppColors.statusUnknownBgDark));
      });

      test('Audit 325: ExpiryStatus badgeColor returns identical status tokens regardless of theme mode', () {
        expect(ExpiryStatus.expired.badgeColor, equals(AppColors.statusExpired));
        expect(ExpiryStatus.expiringToday.badgeColor, equals(AppColors.statusExpiringToday));
        expect(ExpiryStatus.expiringSoon.badgeColor, equals(AppColors.statusExpiringSoon));
        expect(ExpiryStatus.fresh.badgeColor, equals(AppColors.statusFresh));
        expect(ExpiryStatus.unknown.badgeColor, equals(AppColors.statusUnknown));
      });

      test('Audit 326: AppTheme.lightTheme has Brightness.light', () {
        final theme = AppTheme.lightTheme;
        expect(theme.brightness, equals(Brightness.light));
      });

      test('Audit 327: AppTheme.darkTheme has Brightness.dark', () {
        final theme = AppTheme.darkTheme;
        expect(theme.brightness, equals(Brightness.dark));
      });

      test('Audit 328: AppTheme.lightTheme scaffoldBackgroundColor is AppColors.canvas', () {
        final theme = AppTheme.lightTheme;
        expect(theme.scaffoldBackgroundColor, equals(AppColors.canvas));
      });

      test('Audit 329: AppTheme.darkTheme scaffoldBackgroundColor is AppColors.darkBackground', () {
        final theme = AppTheme.darkTheme;
        expect(theme.scaffoldBackgroundColor, equals(AppColors.darkBackground));
      });

      test('Audit 330: AppTheme.lightTheme colorScheme primary is AppColors.forestGreen', () {
        final theme = AppTheme.lightTheme;
        expect(theme.colorScheme.primary, equals(AppColors.forestGreen));
      });

      test('Audit 331: AppTheme.darkTheme colorScheme primary is AppColors.forestGreen', () {
        final theme = AppTheme.darkTheme;
        expect(theme.colorScheme.primary, equals(AppColors.forestGreen));
        expect(theme.colorScheme.secondary, equals(AppColors.sageGreen));
      });

      test('Audit 332: AppTypography defines displayLarge with correct fontSize', () {
        expect(AppTypography.displayLarge.fontSize, greaterThanOrEqualTo(28.0));
      });

      test('Audit 333: AppTypography defines bodyMedium for legible standard text', () {
        expect(AppTypography.bodyMedium.fontSize, greaterThanOrEqualTo(13.0));
      });

      test('Audit 334: AppTypography defines labelSmall for compact chips and badges', () {
        expect(AppTypography.labelSmall.fontSize, lessThanOrEqualTo(12.0));
      });

      test('Audit 335: AppTheme cardTheme defines elevation 0 for flat modern cards', () {
        expect(AppTheme.lightTheme.cardTheme.elevation, equals(0.0));
        expect(AppTheme.darkTheme.cardTheme.elevation, equals(0.0));
      });

      test('Audit 336: AppTheme dividerTheme in light mode has AppColors.border color', () {
        expect(AppTheme.lightTheme.dividerTheme.color, equals(AppColors.border));
      });

      test('Audit 337: AppTheme dividerTheme in dark mode has AppColors.darkBorder color', () {
        expect(AppTheme.darkTheme.dividerTheme.color, equals(AppColors.darkBorder));
      });

      test('Audit 338: AppTheme inputDecorationTheme in light mode has filled = true', () {
        expect(AppTheme.lightTheme.inputDecorationTheme.filled, isTrue);
      });

      test('Audit 339: AppTheme inputDecorationTheme in dark mode has filled = true', () {
        expect(AppTheme.darkTheme.inputDecorationTheme.filled, isTrue);
      });

      test('Audit 340: AppColors.canvas is distinct from AppColors.softWhite for layered depth', () {
        expect(AppColors.canvas, isNot(equals(AppColors.softWhite)));
      });

      test('Audit 341: AppColors.surfaceContainerLow maps cleanly for nested panels', () {
        expect(AppColors.surfaceContainerLow.toARGB32(), equals(0xFFF2F5EE));
      });

      test('Audit 342: AppColors.surfaceContainer maps cleanly for container elements', () {
        expect(AppColors.surfaceContainer.toARGB32(), equals(0xFFECEFE8));
      });

      test('Audit 343: AppColors.surfaceContainerHigh maps cleanly for elevated elements', () {
        expect(AppColors.surfaceContainerHigh.toARGB32(), equals(0xFFE6E9E3));
      });

      test('Audit 344: AppColors.surfaceContainerHighest maps cleanly for highest containers', () {
        expect(AppColors.surfaceContainerHighest.toARGB32(), equals(0xFFE0E3DD));
      });

      test('Audit 345: AppColors.subHeader color provides subtle green accent for sections', () {
        expect(AppColors.subHeader.toARGB32(), equals(0xFF567061));
      });

      test('Audit 346: AppColors.mutedOlive tertiary brand token ARGB check', () {
        expect(AppColors.mutedOlive.toARGB32(), equals(0xFFB5BD91));
      });

      test('Audit 347: AppTheme lightTheme appBarTheme elevation is 0 for flat aesthetic', () {
        expect(AppTheme.lightTheme.appBarTheme.elevation, equals(0.0));
      });

      test('Audit 348: AppTheme darkTheme appBarTheme elevation is 0 for flat aesthetic', () {
        expect(AppTheme.darkTheme.appBarTheme.elevation, equals(0.0));
      });

      test('Audit 349: AppTheme lightTheme cardTheme shape has border with AppColors.border', () {
        final shape = AppTheme.lightTheme.cardTheme.shape as RoundedRectangleBorder;
        expect(shape.side.color, equals(AppColors.border));
        expect(shape.borderRadius, equals(BorderRadius.circular(16)));
      });

      test('Audit 350: AppTheme darkTheme cardTheme shape has border with AppColors.darkBorder', () {
        final shape = AppTheme.darkTheme.cardTheme.shape as RoundedRectangleBorder;
        expect(shape.side.color, equals(AppColors.darkBorder));
        expect(shape.borderRadius, equals(BorderRadius.circular(16)));
      });
    });
  });
}
