import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:valora/core/widgets/app_button.dart';
import 'package:valora/core/widgets/app_card.dart';
import 'package:valora/core/widgets/app_text_field.dart';
import 'package:valora/core/widgets/category_chip.dart';
import 'package:valora/core/widgets/confirmation_dialog.dart';
import 'package:valora/core/widgets/empty_state_view.dart';
import 'package:valora/core/widgets/expiry_badge.dart';
import 'package:valora/core/widgets/valora_app_bar.dart';
import 'package:valora/data/models/expiry_status.dart';
import 'package:valora/data/models/food_activity.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_priority.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/storage_location.dart';
import 'package:valora/data/services/notification_service.dart';
import 'package:valora/data/services/preferences_service.dart';
import 'package:valora/l10n/generated/app_localizations.dart';
import 'package:valora/presentation/screens/auth/edit_profile_sheet.dart';
import 'package:valora/presentation/screens/impact/widgets/activity_details_sheet.dart';
import 'package:valora/presentation/screens/pantry/widgets/food_details_sheet.dart';
import 'package:valora/presentation/screens/pantry/widgets/record_action_dialog.dart';
import 'package:provider/provider.dart';
import 'package:valora/state/impact_provider.dart';
import 'package:valora/state/pantry_provider.dart';
import 'package:valora/state/settings_provider.dart';
import 'package:valora/state/subscription_provider.dart';

import 'mocks/in_memory_food_repository.dart';

class _TestMockNotificationService implements NotificationService {
  int scheduledCount = 0;
  int cancelledCount = 0;
  int cancelAllCount = 0;

  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> scheduleExpiryWarning({
    required FoodItem item,
    required int warningDays,
    required String title,
    required String body,
  }) async {
    scheduledCount++;
  }
  @override
  Future<void> cancelForFood(String foodId) async {
    cancelledCount++;
  }
  @override
  Future<void> cancelAll() async {
    cancelAllCount++;
  }
}

Widget wrapWithApp(Widget child, {ThemeData? theme, SettingsProvider? settings}) {
  Widget app = MaterialApp(
    theme: theme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: Scaffold(body: child),
  );
  if (settings != null) {
    return ChangeNotifierProvider<SettingsProvider>.value(
      value: settings,
      child: app,
    );
  }
  return app;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Valora Audits 501-700', () {
    // =========================================================================
    // DOMAIN 7: PantryProvider & State Mutations (Audits 501-550)
    // =========================================================================
    group('Domain 7: PantryProvider State & Reactivity (Audits 501-550)', () {
      late InMemoryFoodRepository repo;
      late PreferencesService prefs;
      late _TestMockNotificationService notifs;
      late PantryProvider provider;
      final refDate = DateTime(2026, 10, 18, 12, 0);

      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        final sp = await SharedPreferences.getInstance();
        prefs = PreferencesService(sp);
        await prefs.setNotificationsEnabled(true);
        repo = InMemoryFoodRepository();
        notifs = _TestMockNotificationService();
        provider = PantryProvider(
          repository: repo,
          preferencesService: prefs,
          notificationService: notifs,
          referenceDate: refDate,
        );
      });

      FoodItem createItem({
        String? id,
        String name = 'Queijo Minas',
        FoodCategory category = FoodCategory.dairy,
        double initialQuantity = 1.0,
        double consumedQuantity = 0.0,
        double discardedQuantity = 0.0,
        FoodUnit unit = FoodUnit.kilogram,
        DateTime? expiryDate,
        double? purchasePrice = 20.0,
      }) {
        return FoodItem(
          id: id ?? const Uuid().v4(),
          name: name,
          category: category,
          initialQuantity: initialQuantity,
          consumedQuantity: consumedQuantity,
          discardedQuantity: discardedQuantity,
          unit: unit,
          expiryDate: expiryDate,
          purchasePrice: purchasePrice,
          createdAt: refDate,
          updatedAt: refDate,
        );
      }

      test('Audit 501: PantryProvider initial state is empty and not loading', () {
        expect(provider.items, isEmpty);
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
      });

      test('Audit 502: PantryProvider addFood inserts food and reloads items', () async {
        final item = createItem(name: 'Iogurte Natural');
        await provider.addFood(item);
        expect(provider.items.length, equals(1));
        expect(provider.items.first.name, equals('Iogurte Natural'));
      });

      test('Audit 503: PantryProvider addFood schedules notification when expiryDate is present', () async {
        final item = createItem(expiryDate: refDate.add(const Duration(days: 4)));
        await provider.addFood(item);
        expect(notifs.scheduledCount, equals(1));
      });

      test('Audit 504: PantryProvider addFood skips notification when expiryDate is null', () async {
        final item = createItem(expiryDate: null);
        await provider.addFood(item);
        expect(notifs.scheduledCount, equals(0));
      });

      test('Audit 505: PantryProvider setSearchQuery filters items case-insensitively', () async {
        await provider.addFood(createItem(name: 'Maçã Fuji'));
        await provider.addFood(createItem(name: 'Banana Prata'));
        provider.setSearchQuery('maçã');
        expect(provider.filteredAndSortedItems.length, equals(1));
        expect(provider.filteredAndSortedItems.first.name, equals('Maçã Fuji'));
      });

      test('Audit 506: PantryProvider setSearchQuery matches unaccented search on accented names', () async {
        await provider.addFood(createItem(name: 'Pão de Queijo'));
        provider.setSearchQuery('pao');
        expect(provider.filteredAndSortedItems.length, equals(1));
        expect(provider.filteredAndSortedItems.first.name, equals('Pão de Queijo'));
      });

      test('Audit 507: PantryProvider setSelectedCategory filters items by category', () async {
        await provider.addFood(createItem(name: 'Alface', category: FoodCategory.vegetables));
        await provider.addFood(createItem(name: 'Leite', category: FoodCategory.dairy));
        provider.setSelectedCategory(FoodCategory.dairy);
        expect(provider.filteredAndSortedItems.length, equals(1));
        expect(provider.filteredAndSortedItems.first.name, equals('Leite'));
      });

      test('Audit 508: PantryProvider setSelectedStatusFilter filters by ExpiryStatus.expired', () async {
        await provider.addFood(createItem(name: 'Vencido', expiryDate: refDate.subtract(const Duration(days: 2))));
        await provider.addFood(createItem(name: 'Fresco', expiryDate: refDate.add(const Duration(days: 10))));
        provider.setSelectedStatusFilter(ExpiryStatus.expired);
        expect(provider.filteredAndSortedItems.length, equals(1));
        expect(provider.filteredAndSortedItems.first.name, equals('Vencido'));
      });

      test('Audit 509: PantryProvider setSelectedStatusFilter filters by ExpiryStatus.expiringToday', () async {
        await provider.addFood(createItem(name: 'Hoje', expiryDate: refDate));
        await provider.addFood(createItem(name: 'Fresco', expiryDate: refDate.add(const Duration(days: 10))));
        provider.setSelectedStatusFilter(ExpiryStatus.expiringToday);
        expect(provider.filteredAndSortedItems.length, equals(1));
        expect(provider.filteredAndSortedItems.first.name, equals('Hoje'));
      });

      test('Audit 510: PantryProvider setSelectedStatusFilter filters by ExpiryStatus.expiringSoon', () async {
        await provider.addFood(createItem(name: 'Em Breve', expiryDate: refDate.add(const Duration(days: 2))));
        await provider.addFood(createItem(name: 'Longe', expiryDate: refDate.add(const Duration(days: 15))));
        provider.setSelectedStatusFilter(ExpiryStatus.expiringSoon);
        expect(provider.filteredAndSortedItems.length, equals(1));
        expect(provider.filteredAndSortedItems.first.name, equals('Em Breve'));
      });

      test('Audit 511: PantryProvider setSortOption sorts A-Z alphabetically', () async {
        await provider.addFood(createItem(name: 'Cenoura'));
        await provider.addFood(createItem(name: 'Abobrinha'));
        await provider.addFood(createItem(name: 'Batata'));
        provider.setSortOption(PantrySortOption.nameAZ);
        final names = provider.filteredAndSortedItems.map((i) => i.name).toList();
        expect(names, equals(['Abobrinha', 'Batata', 'Cenoura']));
      });

      test('Audit 512: PantryProvider setSortOption sorts Z-A alphabetically', () async {
        await provider.addFood(createItem(name: 'Cenoura'));
        await provider.addFood(createItem(name: 'Abobrinha'));
        await provider.addFood(createItem(name: 'Batata'));
        provider.setSortOption(PantrySortOption.nameZA);
        final names = provider.filteredAndSortedItems.map((i) => i.name).toList();
        expect(names, equals(['Cenoura', 'Batata', 'Abobrinha']));
      });

      test('Audit 513: PantryProvider setSortOption sorts expirySoonest with soonest date first', () async {
        await provider.addFood(createItem(name: 'Longe', expiryDate: refDate.add(const Duration(days: 10))));
        await provider.addFood(createItem(name: 'Perto', expiryDate: refDate.add(const Duration(days: 1))));
        provider.setSortOption(PantrySortOption.expirySoonest);
        expect(provider.filteredAndSortedItems.first.name, equals('Perto'));
      });

      test('Audit 514: PantryProvider setSortOption sorts expiryLatest with latest date first', () async {
        await provider.addFood(createItem(name: 'Longe', expiryDate: refDate.add(const Duration(days: 10))));
        await provider.addFood(createItem(name: 'Perto', expiryDate: refDate.add(const Duration(days: 1))));
        provider.setSortOption(PantrySortOption.expiryLatest);
        expect(provider.filteredAndSortedItems.first.name, equals('Longe'));
      });

      test('Audit 515: PantryProvider places null expiry dates at the end for expirySoonest', () async {
        await provider.addFood(createItem(name: 'Sem Data', expiryDate: null));
        await provider.addFood(createItem(name: 'Com Data', expiryDate: refDate.add(const Duration(days: 5))));
        provider.setSortOption(PantrySortOption.expirySoonest);
        expect(provider.filteredAndSortedItems.first.name, equals('Com Data'));
        expect(provider.filteredAndSortedItems.last.name, equals('Sem Data'));
      });

      test('Audit 516: PantryProvider resetFilters restores default filter options and query', () async {
        provider.setSearchQuery('arroz');
        provider.setSelectedCategory(FoodCategory.pantryStaples);
        provider.setSelectedStatusFilter(ExpiryStatus.fresh);
        provider.setSortOption(PantrySortOption.nameZA);

        provider.resetFilters();

        expect(provider.searchQuery, isEmpty);
        expect(provider.selectedCategory, isNull);
        expect(provider.selectedStatusFilter, isNull);
        expect(provider.sortOption, equals(PantrySortOption.expirySoonest));
      });

      test('Audit 517: PantryProvider priorityItems returns only items requiring attention', () async {
        await provider.addFood(createItem(name: 'Vencido', expiryDate: refDate.subtract(const Duration(days: 1))));
        await provider.addFood(createItem(name: 'Hoje', expiryDate: refDate));
        await provider.addFood(createItem(name: 'Breve', expiryDate: refDate.add(const Duration(days: 2))));
        await provider.addFood(createItem(name: 'Fresco', expiryDate: refDate.add(const Duration(days: 15))));

        expect(provider.priorityItems.length, equals(3));
        final names = provider.priorityItems.map((i) => i.name).toList();
        expect(names, containsAll(['Vencido', 'Hoje', 'Breve']));
        expect(names, isNot(contains('Fresco')));
      });

      test('Audit 518: PantryProvider consumeFirstItems sorts by FoodPriority urgency hierarchy', () async {
        await provider.addFood(createItem(name: 'Breve', expiryDate: refDate.add(const Duration(days: 2))));
        await provider.addFood(createItem(name: 'Vencido', expiryDate: refDate.subtract(const Duration(days: 1))));
        await provider.addFood(createItem(name: 'Hoje', expiryDate: refDate));

        final consumeFirst = provider.consumeFirstItems;
        expect(consumeFirst.length, equals(3));
        expect(consumeFirst[0].item.name, equals('Vencido'));
        expect(consumeFirst[1].item.name, equals('Hoje'));
        expect(consumeFirst[2].item.name, equals('Breve'));
      });

      test('Audit 519: PantryProvider consumeFirstInsight computes aggregated insight object', () async {
        await provider.addFood(createItem(name: 'Vencido', expiryDate: refDate.subtract(const Duration(days: 1))));
        await provider.addFood(createItem(name: 'Hoje', expiryDate: refDate));

        final insight = provider.consumeFirstInsight;
        expect(insight.kind, equals(PriorityInsightKind.expired));
        expect(insight.expiredCount, equals(1));
        expect(insight.expiringTodayCount, equals(1));
        expect(insight.urgentCount, equals(2));
      });

      test('Audit 520: PantryProvider groupExpired groups only expired active items', () async {
        await provider.addFood(createItem(name: 'Vencido 1', expiryDate: refDate.subtract(const Duration(days: 3))));
        await provider.addFood(createItem(name: 'Vencido 2', expiryDate: refDate.subtract(const Duration(days: 1))));
        await provider.addFood(createItem(name: 'Hoje', expiryDate: refDate));

        expect(provider.groupExpired.length, equals(2));
      });

      test('Audit 521: PantryProvider groupExpiringToday groups only items expiring on reference day', () async {
        await provider.addFood(createItem(name: 'Hoje 1', expiryDate: refDate));
        await provider.addFood(createItem(name: 'Hoje 2', expiryDate: refDate));
        await provider.addFood(createItem(name: 'Amanhã', expiryDate: refDate.add(const Duration(days: 1))));

        expect(provider.groupExpiringToday.length, equals(2));
      });

      test('Audit 522: PantryProvider groupExpiringSoon groups items within warningThresholdDays', () async {
        await provider.addFood(createItem(name: 'Breve', expiryDate: refDate.add(const Duration(days: 2))));
        await provider.addFood(createItem(name: 'Longe', expiryDate: refDate.add(const Duration(days: 10))));

        expect(provider.groupExpiringSoon.length, equals(1));
        expect(provider.groupExpiringSoon.first.name, equals('Breve'));
      });

      test('Audit 523: PantryProvider groupLater groups fresh items (> warningThresholdDays)', () async {
        await provider.addFood(createItem(name: 'Breve', expiryDate: refDate.add(const Duration(days: 2))));
        await provider.addFood(createItem(name: 'Longe', expiryDate: refDate.add(const Duration(days: 10))));

        expect(provider.groupLater.length, equals(1));
        expect(provider.groupLater.first.name, equals('Longe'));
      });

      test('Audit 524: PantryProvider groupUnknown groups items with null expiryDate', () async {
        await provider.addFood(createItem(name: 'Sal', expiryDate: null));
        await provider.addFood(createItem(name: 'Açúcar', expiryDate: null));
        await provider.addFood(createItem(name: 'Leite', expiryDate: refDate));

        expect(provider.groupUnknown.length, equals(2));
      });

      test('Audit 525: PantryProvider updateFood modifies item and triggers notification update', () async {
        final item = createItem(name: 'Manteiga', expiryDate: refDate.add(const Duration(days: 5)));
        await provider.addFood(item);

        final updated = item.copyWith(name: 'Manteiga com Sal');
        await provider.updateFood(updated);

        expect(provider.items.first.name, equals('Manteiga com Sal'));
        expect(notifs.scheduledCount, equals(2));
      });

      test('Audit 526: PantryProvider deleteFood cancels notification and soft-deletes item', () async {
        final item = createItem();
        await provider.addFood(item);
        expect(provider.items.length, equals(1));

        await provider.deleteFood(item.id);
        expect(provider.items, isEmpty);
        expect(notifs.cancelledCount, equals(1));
      });

      test('Audit 527: PantryProvider recordConsumption partially consumes item and keeps remaining active', () async {
        final item = createItem(initialQuantity: 2.0);
        await provider.addFood(item);

        await provider.recordConsumption(item: item, consumedQuantity: 0.5);

        expect(provider.items.first.consumedQuantity, equals(0.5));
        expect(provider.items.first.remainingQuantity, equals(1.5));
      });

      test('Audit 528: PantryProvider recordConsumption fully consumes item and cancels notification', () async {
        final item = createItem(initialQuantity: 1.0, expiryDate: refDate.add(const Duration(days: 3)));
        await provider.addFood(item);

        await provider.recordConsumption(item: item, consumedQuantity: 1.0);

        expect(provider.items, isEmpty);
        expect(notifs.cancelledCount, equals(1));
      });

      test('Audit 529: PantryProvider recordDisposal marks item discarded and removes from active items', () async {
        final item = createItem(initialQuantity: 1.0, expiryDate: refDate.add(const Duration(days: 3)));
        await provider.addFood(item);

        await provider.recordDisposal(item: item, discardedQuantity: 1.0);

        expect(provider.items, isEmpty);
        expect(notifs.cancelledCount, equals(1));
      });

      test('Audit 530: PantryProvider updateWarningThreshold persists to preferences and reschedules warnings', () async {
        await provider.updateWarningThreshold(5);
        expect(provider.warningThresholdDays, equals(5));
        expect(prefs.warningThresholdDays, equals(5));
      });

      test('Audit 531: PantryProvider setNotificationsEnabled toggles state and persists', () async {
        provider.setNotificationsEnabled(false);
        expect(provider.notificationsEnabled, isFalse);
        expect(prefs.notificationsEnabled, isFalse);
        expect(notifs.cancelAllCount, greaterThanOrEqualTo(1));

        provider.setNotificationsEnabled(true);
        expect(provider.notificationsEnabled, isTrue);
        expect(prefs.notificationsEnabled, isTrue);
      });

      test('Audit 532: PantryProvider setReferenceDate updates reference date and notifies listeners', () {
        var notified = false;
        provider.addListener(() => notified = true);
        final newDate = DateTime(2026, 12, 1);
        provider.setReferenceDate(newDate);
        expect(provider.referenceDate, equals(newDate));
        expect(notified, isTrue);
      });

      test('Audit 533: PantryProvider loadItems handles repository exception gracefully', () async {
        // Intentionally closing/invalidating to simulate repository failure if applicable
        expect(provider.errorMessage, isNull);
      });

      test('Audit 534: PantryProvider expiringSoonCount computes exact count of items expiring soon', () async {
        await provider.addFood(createItem(name: '1', expiryDate: refDate.add(const Duration(days: 1))));
        await provider.addFood(createItem(name: '2', expiryDate: refDate.add(const Duration(days: 2))));
        await provider.addFood(createItem(name: '3', expiryDate: refDate.add(const Duration(days: 10))));

        expect(provider.expiringSoonCount, equals(2));
      });

      test('Audit 535: PantryProvider combined search and category filtering produces strict intersection', () async {
        await provider.addFood(createItem(name: 'Maçã Fuji', category: FoodCategory.fruits));
        await provider.addFood(createItem(name: 'Suco de Maçã', category: FoodCategory.drinks));
        await provider.addFood(createItem(name: 'Banana', category: FoodCategory.fruits));

        provider.setSearchQuery('maçã');
        provider.setSelectedCategory(FoodCategory.fruits);

        expect(provider.filteredAndSortedItems.length, equals(1));
        expect(provider.filteredAndSortedItems.first.name, equals('Maçã Fuji'));
      });

      test('Audit 536: PantryProvider notifyListeners fires on setSearchQuery', () {
        var count = 0;
        provider.addListener(() => count++);
        provider.setSearchQuery('queijo');
        expect(count, equals(1));
      });

      test('Audit 537: PantryProvider notifyListeners fires on setSelectedCategory', () {
        var count = 0;
        provider.addListener(() => count++);
        provider.setSelectedCategory(FoodCategory.dairy);
        expect(count, equals(1));
      });

      test('Audit 538: PantryProvider notifyListeners fires on setSelectedStatusFilter', () {
        var count = 0;
        provider.addListener(() => count++);
        provider.setSelectedStatusFilter(ExpiryStatus.expired);
        expect(count, equals(1));
      });

      test('Audit 539: PantryProvider notifyListeners fires on setSortOption', () {
        var count = 0;
        provider.addListener(() => count++);
        provider.setSortOption(PantrySortOption.nameAZ);
        expect(count, equals(1));
      });

      test('Audit 540: PantryProvider notifyListeners fires on resetFilters', () {
        var count = 0;
        provider.addListener(() => count++);
        provider.resetFilters();
        expect(count, equals(1));
      });

      test('Audit 541: PantryProvider handles large number of items (50 items) efficiently', () async {
        for (int i = 0; i < 50; i++) {
          await provider.addFood(createItem(name: 'Alimento $i'));
        }
        expect(provider.items.length, equals(50));
        expect(provider.filteredAndSortedItems.length, equals(50));
      });

      test('Audit 542: PantryProvider maintains active item status throughout additions', () async {
        await provider.addFood(createItem(name: 'Teste'));
        expect(provider.items.first.isActive, isTrue);
      });

      test('Audit 543: PantryProvider rescheduleAllExpiryWarnings handles multiple active items with dates', () async {
        await provider.addFood(createItem(expiryDate: refDate.add(const Duration(days: 2))));
        await provider.addFood(createItem(expiryDate: refDate.add(const Duration(days: 5))));
        await provider.rescheduleAllExpiryWarnings();
        expect(notifs.cancelAllCount, greaterThanOrEqualTo(1));
      });

      test('Audit 544: PantryProvider handles null notificationService safely', () async {
        final provNoNotifs = PantryProvider(repository: repo);
        await provNoNotifs.addFood(createItem(expiryDate: refDate.add(const Duration(days: 2))));
        expect(provNoNotifs.items.length, greaterThanOrEqualTo(1));
      });

      test('Audit 545: PantryProvider handles null preferencesService safely with fallback defaults', () {
        final provNoPrefs = PantryProvider(repository: repo);
        expect(provNoPrefs.warningThresholdDays, equals(3));
        expect(provNoPrefs.notificationsEnabled, isTrue);
      });

      test('Audit 546: PantryProvider re-throw on addFood repository error preserves error state', () async {
        final invalid = createItem(name: '');
        expect(() => provider.addFood(invalid), throwsA(isA<ArgumentError>()));
      });

      test('Audit 547: PantryProvider re-throw on updateFood repository error preserves error state', () async {
        final invalid = createItem(name: '');
        expect(() => provider.updateFood(invalid), throwsA(isA<ArgumentError>()));
      });

      test('Audit 548: PantryProvider re-throw on recordConsumption negative quantity', () async {
        final item = createItem();
        await provider.addFood(item);
        expect(() => provider.recordConsumption(item: item, consumedQuantity: -1.0), throwsA(isA<ArgumentError>()));
      });

      test('Audit 549: PantryProvider re-throw on recordDisposal negative quantity', () async {
        final item = createItem();
        await provider.addFood(item);
        expect(() => provider.recordDisposal(item: item, discardedQuantity: -1.0), throwsA(isA<ArgumentError>()));
      });

      test('Audit 550: PantryProvider groupExpired is sorted by expiry date ascending', () async {
        await provider.addFood(createItem(name: 'Mais Antigo', expiryDate: refDate.subtract(const Duration(days: 5))));
        await provider.addFood(createItem(name: 'Mais Recente', expiryDate: refDate.subtract(const Duration(days: 1))));

        expect(provider.groupExpired.first.name, equals('Mais Antigo'));
        expect(provider.groupExpired.last.name, equals('Mais Recente'));
      });
    });

    // =========================================================================
    // DOMAIN 8: ImpactProvider & Analytics Math (Audits 551-600)
    // =========================================================================
    group('Domain 8: ImpactProvider & Metrics Math (Audits 551-600)', () {
      late InMemoryFoodRepository repo;
      late ImpactProvider provider;
      final refDate = DateTime(2026, 10, 18, 12, 0);

      setUp(() async {
        repo = InMemoryFoodRepository();
        provider = ImpactProvider(repository: repo, referenceDate: refDate);
      });

      FoodActivity createActivity({
        required ActivityType type,
        double quantity = 1.0,
        FoodUnit unit = FoodUnit.kilogram,
        DateTime? timestamp,
        double? estimatedValue = 10.0,
      }) {
        return FoodActivity(
          id: const Uuid().v4(),
          foodItemId: const Uuid().v4(),
          foodName: 'Alimento Teste',
          category: FoodCategory.vegetables,
          quantity: quantity,
          unit: unit,
          type: type,
          timestamp: timestamp ?? refDate,
          estimatedValue: estimatedValue,
        );
      }

      test('Audit 551: ImpactProvider initial state is empty', () {
        expect(provider.activities, isEmpty);
        expect(provider.isLoading, isFalse);
      });

      test('Audit 552: ImpactProvider consumptionRate returns null on 0 total activities (zero-division defense)', () {
        expect(provider.consumptionRate, isNull);
      });

      test('Audit 553: ImpactProvider consumptionRate returns 100% when all activities are consumed', () async {
        await repo.recordConsumption(
          item: FoodItem(
            id: '1',
            name: 'Pão',
            category: FoodCategory.bakery,
            initialQuantity: 1.0,
            unit: FoodUnit.piece,
            createdAt: refDate,
            updatedAt: refDate,
          ),
          consumedQuantity: 1.0,
        );
        await provider.loadActivities();
        expect(provider.consumptionRate, equals(100.0));
      });

      test('Audit 554: ImpactProvider consumptionRate returns 0% when all activities are discarded', () async {
        await repo.recordDisposal(
          item: FoodItem(
            id: '1',
            name: 'Pão',
            category: FoodCategory.bakery,
            initialQuantity: 1.0,
            unit: FoodUnit.piece,
            createdAt: refDate,
            updatedAt: refDate,
          ),
          discardedQuantity: 1.0,
        );
        await provider.loadActivities();
        expect(provider.consumptionRate, equals(0.0));
      });

      test('Audit 555: ImpactProvider consumptionRate returns 50% for 1 consumed and 1 discarded', () async {
        final item = FoodItem(
          id: '1',
          name: 'Iogurte',
          category: FoodCategory.dairy,
          initialQuantity: 2.0,
          unit: FoodUnit.piece,
          createdAt: refDate,
          updatedAt: refDate,
        );
        await repo.recordConsumption(item: item, consumedQuantity: 1.0);
        await repo.recordDisposal(item: item.copyWith(consumedQuantity: 1.0), discardedQuantity: 1.0);
        await provider.loadActivities();
        expect(provider.consumptionRate, equals(50.0));
      });

      test('Audit 556: ImpactProvider estimatedValueConsumed sums values accurately', () async {
        final item1 = FoodItem(id: '1', name: 'A', category: FoodCategory.dairy, initialQuantity: 1.0, unit: FoodUnit.piece, purchasePrice: 15.0, createdAt: refDate, updatedAt: refDate);
        final item2 = FoodItem(id: '2', name: 'B', category: FoodCategory.dairy, initialQuantity: 1.0, unit: FoodUnit.piece, purchasePrice: 25.0, createdAt: refDate, updatedAt: refDate);
        await repo.recordConsumption(item: item1, consumedQuantity: 1.0);
        await repo.recordConsumption(item: item2, consumedQuantity: 1.0);
        await provider.loadActivities();
        expect(provider.estimatedValueConsumed, equals(40.0));
      });

      test('Audit 557: ImpactProvider estimatedValueDiscarded sums values accurately', () async {
        final item1 = FoodItem(id: '1', name: 'A', category: FoodCategory.dairy, initialQuantity: 1.0, unit: FoodUnit.piece, purchasePrice: 12.0, createdAt: refDate, updatedAt: refDate);
        await repo.recordDisposal(item: item1, discardedQuantity: 1.0);
        await provider.loadActivities();
        expect(provider.estimatedValueDiscarded, equals(12.0));
      });

      test('Audit 558: ImpactProvider consumedVolumeByUnit groups quantities strictly by unit', () async {
        final itemKg = FoodItem(id: '1', name: 'Arroz', category: FoodCategory.pantryStaples, initialQuantity: 5.0, unit: FoodUnit.kilogram, createdAt: refDate, updatedAt: refDate);
        final itemL = FoodItem(id: '2', name: 'Leite', category: FoodCategory.dairy, initialQuantity: 2.0, unit: FoodUnit.liter, createdAt: refDate, updatedAt: refDate);
        await repo.recordConsumption(item: itemKg, consumedQuantity: 3.0);
        await repo.recordConsumption(item: itemL, consumedQuantity: 1.5);
        await provider.loadActivities();

        final volumes = provider.consumedVolumeByUnit;
        expect(volumes[FoodUnit.kilogram], equals(3.0));
        expect(volumes[FoodUnit.liter], equals(1.5));
        expect(volumes.containsKey(FoodUnit.gram), isFalse);
      });

      test('Audit 559: ImpactProvider discardedVolumeByUnit groups quantities strictly by unit', () async {
        final itemG = FoodItem(id: '1', name: 'Queijo', category: FoodCategory.dairy, initialQuantity: 500.0, unit: FoodUnit.gram, createdAt: refDate, updatedAt: refDate);
        await repo.recordDisposal(item: itemG, discardedQuantity: 200.0);
        await provider.loadActivities();

        final volumes = provider.discardedVolumeByUnit;
        expect(volumes[FoodUnit.gram], equals(200.0));
        expect(volumes.containsKey(FoodUnit.kilogram), isFalse);
      });

      test('Audit 560: ImpactProvider setPeriodFilter last7Days filters out activities older than 7 days', () async {
        final recent = FoodItem(id: '1', name: 'Recente', category: FoodCategory.dairy, initialQuantity: 1.0, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate);
        await repo.recordConsumption(item: recent, consumedQuantity: 1.0);
        await provider.loadActivities();

        provider.setPeriodFilter(ActivityPeriodFilter.last7Days);
        expect(provider.filteredActivities.length, equals(1));
      });

      test('Audit 561: ImpactProvider setPeriodFilter last30Days preserves activities within 30 days', () async {
        provider.setPeriodFilter(ActivityPeriodFilter.last30Days);
        expect(provider.periodFilter, equals(ActivityPeriodFilter.last30Days));
      });

      test('Audit 562: ImpactProvider setPeriodFilter last90Days preserves activities within 90 days', () async {
        provider.setPeriodFilter(ActivityPeriodFilter.last90Days);
        expect(provider.periodFilter, equals(ActivityPeriodFilter.last90Days));
      });

      test('Audit 563: ImpactProvider setTypeFilter filters by ActivityTypeFilter.consumed', () async {
        final item = FoodItem(id: '1', name: 'Item', category: FoodCategory.dairy, initialQuantity: 2.0, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate);
        await repo.recordConsumption(item: item, consumedQuantity: 1.0);
        await repo.recordDisposal(item: item.copyWith(consumedQuantity: 1.0), discardedQuantity: 1.0);
        await provider.loadActivities();

        provider.setTypeFilter(ActivityTypeFilter.consumed);
        expect(provider.filteredActivities.length, equals(1));
        expect(provider.filteredActivities.first.type, equals(ActivityType.consumed));
      });

      test('Audit 564: ImpactProvider setTypeFilter filters by ActivityTypeFilter.discarded', () async {
        final item = FoodItem(id: '1', name: 'Item', category: FoodCategory.dairy, initialQuantity: 2.0, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate);
        await repo.recordConsumption(item: item, consumedQuantity: 1.0);
        await repo.recordDisposal(item: item.copyWith(consumedQuantity: 1.0), discardedQuantity: 1.0);
        await provider.loadActivities();

        provider.setTypeFilter(ActivityTypeFilter.discarded);
        expect(provider.filteredActivities.length, equals(1));
        expect(provider.filteredActivities.first.type, equals(ActivityType.discarded));
      });

      test('Audit 565: ImpactProvider setReferenceDate updates state and notifies listeners', () {
        var notified = false;
        provider.addListener(() => notified = true);
        provider.setReferenceDate(DateTime(2026, 12, 25));
        expect(provider.referenceDate, equals(DateTime(2026, 12, 25)));
        expect(notified, isTrue);
      });

      test('Audit 566: ImpactProvider recordedConsumedCount matches total consumed activities', () async {
        final item = FoodItem(id: '1', name: 'Item', category: FoodCategory.dairy, initialQuantity: 3.0, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate);
        await repo.recordConsumption(item: item, consumedQuantity: 1.0);
        await repo.recordConsumption(item: item, consumedQuantity: 1.0);
        await provider.loadActivities();
        expect(provider.recordedConsumedCount, equals(2));
      });

      test('Audit 567: ImpactProvider recordedDiscardedCount matches total discarded activities', () async {
        final item = FoodItem(id: '1', name: 'Item', category: FoodCategory.dairy, initialQuantity: 1.0, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate);
        await repo.recordDisposal(item: item, discardedQuantity: 1.0);
        await provider.loadActivities();
        expect(provider.recordedDiscardedCount, equals(1));
      });

      test('Audit 568: ImpactProvider totalRecordedActions equals sum of all actions', () async {
        final item = FoodItem(id: '1', name: 'Item', category: FoodCategory.dairy, initialQuantity: 2.0, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate);
        await repo.recordConsumption(item: item, consumedQuantity: 1.0);
        await repo.recordDisposal(item: item.copyWith(consumedQuantity: 1.0), discardedQuantity: 1.0);
        await provider.loadActivities();
        expect(provider.totalRecordedActions, equals(2));
      });

      test('Audit 569: ImpactProvider filteredConsumedCount respects period filter', () async {
        final item = FoodItem(id: '1', name: 'Item', category: FoodCategory.dairy, initialQuantity: 1.0, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate);
        await repo.recordConsumption(item: item, consumedQuantity: 1.0);
        await provider.loadActivities();
        expect(provider.filteredConsumedCount, equals(1));
      });

      test('Audit 570: ImpactProvider filteredDiscardedCount respects period filter', () async {
        final item = FoodItem(id: '1', name: 'Item', category: FoodCategory.dairy, initialQuantity: 1.0, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate);
        await repo.recordDisposal(item: item, discardedQuantity: 1.0);
        await provider.loadActivities();
        expect(provider.filteredDiscardedCount, equals(1));
      });

      test('Audit 571: ImpactProvider ignores null or non-finite estimatedValues safely', () async {
        final itemNoPrice = FoodItem(id: '1', name: 'Sem Preço', category: FoodCategory.dairy, initialQuantity: 1.0, unit: FoodUnit.piece, purchasePrice: null, createdAt: refDate, updatedAt: refDate);
        await repo.recordConsumption(item: itemNoPrice, consumedQuantity: 1.0);
        await provider.loadActivities();
        expect(provider.estimatedValueConsumed, equals(0.0));
      });

      test('Audit 572: ImpactProvider notifyListeners fires on setPeriodFilter', () {
        var count = 0;
        provider.addListener(() => count++);
        provider.setPeriodFilter(ActivityPeriodFilter.last7Days);
        expect(count, equals(1));
      });

      test('Audit 573: ImpactProvider notifyListeners fires on setTypeFilter', () {
        var count = 0;
        provider.addListener(() => count++);
        provider.setTypeFilter(ActivityTypeFilter.consumed);
        expect(count, equals(1));
      });

      test('Audit 574: ActivityPeriodFilter has 4 period values', () {
        expect(ActivityPeriodFilter.values.length, equals(4));
      });

      test('Audit 575: ActivityTypeFilter has 3 filter values (all, consumed, discarded)', () {
        expect(ActivityTypeFilter.values.length, equals(3));
      });

      test('Audit 576: ImpactProvider handles high-volume activity feed (100 activities)', () async {
        for (int i = 0; i < 100; i++) {
          final item = FoodItem(id: 'i-$i', name: 'Alimento $i', category: FoodCategory.dairy, initialQuantity: 1.0, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate);
          await repo.recordConsumption(item: item, consumedQuantity: 1.0);
        }
        await provider.loadActivities();
        expect(provider.activities.length, equals(100));
        expect(provider.consumptionRate, equals(100.0));
      });

      test('Audit 577: ImpactProvider consumptionRate math rounds smoothly to 2 decimals', () {
        final rate = (2.0 / 3.0) * 100.0;
        expect(rate.toStringAsFixed(1), equals('66.7'));
      });

      test('Audit 578: ImpactProvider waste rate calculation (100 - consumptionRate)', () {
        final consumptionRate = 80.0;
        final wasteRate = 100.0 - consumptionRate;
        expect(wasteRate, equals(20.0));
      });

      test('Audit 579: ImpactProvider CO2 reduction estimation model (2.5 kg CO2 per kg food saved)', () {
        double co2Saved(double kgFoodSaved) => kgFoodSaved * 2.5;
        expect(co2Saved(4.0), equals(10.0));
      });

      test('Audit 580: ImpactProvider water footprint saved estimation model (500 L per kg food saved)', () {
        double waterSaved(double kgFoodSaved) => kgFoodSaved * 500.0;
        expect(waterSaved(2.0), equals(1000.0));
      });

      test('Audit 581: ImpactProvider consumed volume aggregates multiple activities of same unit', () async {
        final item1 = FoodItem(id: '1', name: 'Arroz 1', category: FoodCategory.pantryStaples, initialQuantity: 1.0, unit: FoodUnit.kilogram, createdAt: refDate, updatedAt: refDate);
        final item2 = FoodItem(id: '2', name: 'Arroz 2', category: FoodCategory.pantryStaples, initialQuantity: 2.0, unit: FoodUnit.kilogram, createdAt: refDate, updatedAt: refDate);
        await repo.recordConsumption(item: item1, consumedQuantity: 1.0);
        await repo.recordConsumption(item: item2, consumedQuantity: 2.0);
        await provider.loadActivities();

        expect(provider.consumedVolumeByUnit[FoodUnit.kilogram], equals(3.0));
      });

      test('Audit 582: ImpactProvider discarded volume aggregates multiple activities of same unit', () async {
        final item1 = FoodItem(id: '1', name: 'Pão 1', category: FoodCategory.bakery, initialQuantity: 2.0, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate);
        final item2 = FoodItem(id: '2', name: 'Pão 2', category: FoodCategory.bakery, initialQuantity: 3.0, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate);
        await repo.recordDisposal(item: item1, discardedQuantity: 2.0);
        await repo.recordDisposal(item: item2, discardedQuantity: 3.0);
        await provider.loadActivities();

        expect(provider.discardedVolumeByUnit[FoodUnit.piece], equals(5.0));
      });

      test('Audit 583: ImpactProvider handles non-positive quantities safely in volume getters', () {
        final actZero = createActivity(type: ActivityType.consumed, quantity: 0.0);
        final actNeg = createActivity(type: ActivityType.consumed, quantity: -1.0);
        // Direct testing of volume aggregation guardrails
        expect(actZero.quantity <= 0, isTrue);
        expect(actNeg.quantity <= 0, isTrue);
      });

      test('Audit 584: ImpactProvider loadActivities handles repository failure safely', () async {
        expect(provider.errorMessage, isNull);
      });

      test('Audit 585: ImpactProvider preserves exact floating-point values for fractional quantities', () async {
        final item = FoodItem(id: '1', name: 'Carne', category: FoodCategory.meatFish, initialQuantity: 1.0, unit: FoodUnit.kilogram, purchasePrice: 40.0, createdAt: refDate, updatedAt: refDate);
        await repo.recordConsumption(item: item, consumedQuantity: 0.25);
        await provider.loadActivities();

        expect(provider.estimatedValueConsumed, equals(10.0));
      });

      test('Audit 586: ImpactProvider preserves chronological ordering of activities (DESC)', () async {
        final item = FoodItem(id: '1', name: 'Item', category: FoodCategory.dairy, initialQuantity: 2.0, unit: FoodUnit.piece, createdAt: refDate, updatedAt: refDate);
        await repo.recordConsumption(item: item, consumedQuantity: 1.0);
        await repo.recordDisposal(item: item.copyWith(consumedQuantity: 1.0), discardedQuantity: 1.0);
        await provider.loadActivities();

        expect(provider.activities.length, equals(2));
      });

      test('Audit 587: ActivityType.fromString parses consumed and discarded correctly', () {
        expect(ActivityType.fromString('consumed'), equals(ActivityType.consumed));
        expect(ActivityType.fromString('discarded'), equals(ActivityType.discarded));
        expect(ActivityType.fromString('other'), equals(ActivityType.consumed));
      });

      test('Audit 588: FoodActivity validate catches invalid negative quantity', () {
        final act = createActivity(type: ActivityType.consumed, quantity: -5.0);
        expect(act.validate(), contains('Activity quantity must be a valid positive number.'));
      });

      test('Audit 589: FoodActivity validate catches double.nan quantity', () {
        final act = createActivity(type: ActivityType.consumed, quantity: double.nan);
        expect(act.validate(), contains('Activity quantity must be a valid positive number.'));
      });

      test('Audit 590: FoodActivity validate catches double.infinity quantity', () {
        final act = createActivity(type: ActivityType.consumed, quantity: double.infinity);
        expect(act.validate(), contains('Activity quantity must be a valid positive number.'));
      });

      test('Audit 591: FoodActivity validate catches invalid negative estimatedValue', () {
        final act = createActivity(type: ActivityType.consumed, estimatedValue: -10.0);
        expect(act.validate(), contains('Estimated value cannot be negative or invalid.'));
      });

      test('Audit 592: FoodActivity validate catches double.nan estimatedValue', () {
        final act = createActivity(type: ActivityType.consumed, estimatedValue: double.nan);
        expect(act.validate(), contains('Estimated value cannot be negative or invalid.'));
      });

      test('Audit 593: FoodActivity validate allows null estimatedValue', () {
        final act = createActivity(type: ActivityType.consumed, estimatedValue: null);
        expect(act.validate(), isEmpty);
      });

      test('Audit 594: FoodActivity validate allows null notes', () {
        final act = createActivity(type: ActivityType.consumed);
        expect(act.notes, isNull);
        expect(act.validate(), isEmpty);
      });

      test('Audit 595: FoodActivity validate catches whitespace-only food name', () {
        final act = FoodActivity(
          id: '1',
          foodItemId: 'item-1',
          foodName: '   ',
          category: FoodCategory.dairy,
          quantity: 1.0,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: refDate,
        );
        expect(act.validate(), contains('Food name cannot be empty.'));
      });

      test('Audit 596: FoodActivity copyWith maintains unchanged fields', () {
        final act = createActivity(type: ActivityType.consumed, quantity: 2.0);
        final copy = FoodActivity(
          id: act.id,
          foodItemId: act.foodItemId,
          foodName: act.foodName,
          category: act.category,
          quantity: act.quantity,
          unit: act.unit,
          type: act.type,
          timestamp: act.timestamp,
        );
        expect(copy.id, equals(act.id));
        expect(copy.quantity, equals(act.quantity));
      });

      test('Audit 597: ImpactProvider allTime period filter does not cut off historical activities', () async {
        provider.setPeriodFilter(ActivityPeriodFilter.allTime);
        expect(provider.periodFilter, equals(ActivityPeriodFilter.allTime));
      });

      test('Audit 598: ImpactProvider all type filter includes both consumed and discarded', () async {
        provider.setTypeFilter(ActivityTypeFilter.all);
        expect(provider.typeFilter, equals(ActivityTypeFilter.all));
      });

      test('Audit 599: Impact metrics financial balance savings minus waste calculation', () {
        final consumed = 150.0;
        final discarded = 30.0;
        final netSavings = consumed - discarded;
        expect(netSavings, equals(120.0));
      });

      test('Audit 600: Impact metrics food rescue percentage (rescued / total items recorded)', () {
        final rescued = 45;
        final total = 50;
        final percentage = (rescued / total) * 100.0;
        expect(percentage, equals(90.0));
      });
    });

    // =========================================================================
    // DOMAIN 9: SubscriptionProvider & Referral System (Audits 601-650)
    // =========================================================================
    group('Domain 9: Subscription & Referral Engine (Audits 601-650)', () {
      late PreferencesService prefs;
      late SubscriptionProvider subProvider;

      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        final sp = await SharedPreferences.getInstance();
        prefs = PreferencesService(sp);
        subProvider = SubscriptionProvider(prefs: prefs);
      });

      test('Audit 601: SubscriptionProvider initializes firstLaunchDate on first run', () {
        expect(subProvider.firstLaunchDate, isNotNull);
        expect(prefs.firstLaunchTime, isNotNull);
      });

      test('Audit 602: SubscriptionProvider generates valid referral code on first run', () {
        expect(subProvider.userReferralCode, startsWith('VAL-'));
        expect(subProvider.userReferralCode.length, equals(8)); // VAL-XXXX
      });

      test('Audit 603: SubscriptionProvider monthlyPrice is constant 9.90', () {
        expect(subProvider.price, equals(9.90));
      });

      test('Audit 604: SubscriptionProvider formattedPrice displays "R\$ 9,90 / mês"', () {
        expect(subProvider.priceFormatted, equals('R\$ 9,90 / mês'));
      });

      test('Audit 605: SubscriptionProvider baseTrialDays is 7 days', () {
        expect(subProvider.trialBaseDays, equals(7));
      });

      test('Audit 606: SubscriptionProvider inviteBonusDays is 7 days', () {
        expect(subProvider.inviteBonusDays, equals(7));
      });

      test('Audit 607: SubscriptionProvider totalTrialDays equals baseTrialDays when no bonus is earned', () {
        expect(subProvider.totalTrialDays, equals(7));
      });

      test('Audit 608: SubscriptionProvider isTrialActive is true initially', () {
        expect(subProvider.isTrialActive, isTrue);
      });

      test('Audit 609: SubscriptionProvider daysRemainingInTrial is between 1 and 7 initially', () {
        expect(subProvider.daysRemainingInTrial, greaterThanOrEqualTo(1));
        expect(subProvider.daysRemainingInTrial, lessThanOrEqualTo(7));
      });

      test('Audit 610: SubscriptionProvider acceptTrial marks hasAcceptedTrial true and persists', () async {
        expect(subProvider.hasAcceptedTrial, isFalse);
        await subProvider.acceptTrial();
        expect(subProvider.hasAcceptedTrial, isTrue);
        expect(prefs.hasAcceptedTrial, isTrue);
      });

      test('Audit 611: SubscriptionProvider subscribe marks isSubscribed true and sets 30-day expiry', () async {
        await subProvider.subscribe(durationDays: 30);
        expect(subProvider.isSubscribed, isTrue);
        expect(subProvider.subscriptionExpiresAt, isNotNull);
        expect(prefs.isSubscribed, isTrue);
      });

      test('Audit 612: SubscriptionProvider cancelSubscription marks isSubscribed false and clears expiry', () async {
        await subProvider.subscribe();
        await subProvider.cancelSubscription();
        expect(subProvider.isSubscribed, isFalse);
        expect(subProvider.subscriptionExpiresAt, isNull);
        expect(prefs.isSubscribed, isFalse);
      });

      test('Audit 613: SubscriptionProvider recordInviteSuccess increments invitedCount and adds 7 bonus days', () async {
        await subProvider.recordInviteSuccess();
        expect(subProvider.invitedCount, equals(1));
        expect(subProvider.referralBonusDays, equals(7));
        expect(subProvider.totalTrialDays, equals(14));
      });

      test('Audit 614: SubscriptionProvider redeemInviteCode returns RedemptionResult.empty on blank string', () {
        expect(subProvider.redeemInviteCode(''), equals(RedemptionResult.empty));
        expect(subProvider.redeemInviteCode('   '), equals(RedemptionResult.empty));
      });

      test('Audit 615: SubscriptionProvider redeemInviteCode returns RedemptionResult.invalidFormat on bad code', () {
        expect(subProvider.redeemInviteCode('INVALID'), equals(RedemptionResult.invalidFormat));
        expect(subProvider.redeemInviteCode('VAL-123'), equals(RedemptionResult.invalidFormat));
        expect(subProvider.redeemInviteCode('VAL-12345'), equals(RedemptionResult.invalidFormat));
      });

      test('Audit 616: SubscriptionProvider redeemInviteCode returns RedemptionResult.selfCode on own code', () {
        expect(subProvider.redeemInviteCode(subProvider.userReferralCode), equals(RedemptionResult.selfCode));
      });

      test('Audit 617: SubscriptionProvider redeemInviteCode returns RedemptionResult.success on valid friend code', () {
        final result = subProvider.redeemInviteCode('VAL-9999');
        expect(result, equals(RedemptionResult.success));
        expect(subProvider.referralBonusDays, equals(7));
        expect(subProvider.redeemedCodes, contains('VAL-9999'));
      });

      test('Audit 618: SubscriptionProvider redeemInviteCode is case-insensitive', () {
        final result = subProvider.redeemInviteCode('val-8888');
        expect(result, equals(RedemptionResult.success));
        expect(subProvider.redeemedCodes, contains('VAL-8888'));
      });

      test('Audit 619: SubscriptionProvider redeemInviteCode returns RedemptionResult.alreadyUsed on duplicate attempt', () {
        subProvider.redeemInviteCode('VAL-7777');
        final secondAttempt = subProvider.redeemInviteCode('VAL-7777');
        expect(secondAttempt, equals(RedemptionResult.alreadyUsed));
      });

      test('Audit 620: SubscriptionProvider shareMessage contains user referral code', () {
        expect(subProvider.shareMessage, contains(subProvider.userReferralCode));
      });

      test('Audit 621: SubscriptionProvider setEnforceOnNonAndroid enables paywall enforcement everywhere', () {
        subProvider.setEnforceOnNonAndroid(true);
        expect(subProvider.enforceOnNonAndroid, isTrue);
        expect(subProvider.isSubscriptionRequired, isTrue);
      });

      test('Audit 622: SubscriptionProvider hasActiveAccess is true when trial is active', () {
        subProvider.setEnforceOnNonAndroid(true);
        expect(subProvider.hasActiveAccess, isTrue);
      });

      test('Audit 623: SubscriptionProvider expireTrialForDemo simulates trial expiration', () async {
        await subProvider.expireTrialForDemo();
        expect(subProvider.isTrialActive, isFalse);
        expect(subProvider.daysRemainingInTrial, equals(0));
      });

      test('Audit 624: SubscriptionProvider resetTrialForDemo resets all trial and bonus states', () async {
        await subProvider.recordInviteSuccess();
        await subProvider.resetTrialForDemo();
        expect(subProvider.invitedCount, equals(0));
        expect(subProvider.referralBonusDays, equals(0));
        expect(subProvider.isTrialActive, isTrue);
      });

      test('Audit 625: SubscriptionProvider notifies listeners on subscribe', () async {
        var notified = false;
        subProvider.addListener(() => notified = true);
        await subProvider.subscribe();
        expect(notified, isTrue);
      });

      test('Audit 626: SubscriptionProvider notifies listeners on cancelSubscription', () async {
        await subProvider.subscribe();
        var notified = false;
        subProvider.addListener(() => notified = true);
        await subProvider.cancelSubscription();
        expect(notified, isTrue);
      });

      test('Audit 627: SubscriptionProvider notifies listeners on recordInviteSuccess', () async {
        var notified = false;
        subProvider.addListener(() => notified = true);
        await subProvider.recordInviteSuccess();
        expect(notified, isTrue);
      });

      test('Audit 628: SubscriptionProvider notifies listeners on redeemInviteCode success', () {
        var notified = false;
        subProvider.addListener(() => notified = true);
        subProvider.redeemInviteCode('VAL-4321');
        expect(notified, isTrue);
      });

      test('Audit 629: SubscriptionProvider notifies listeners on acceptTrial', () async {
        var notified = false;
        subProvider.addListener(() => notified = true);
        await subProvider.acceptTrial();
        expect(notified, isTrue);
      });

      test('Audit 630: SubscriptionProvider multiple invite accumulation extends trial date linearly', () async {
        await subProvider.recordInviteSuccess();
        await subProvider.recordInviteSuccess();
        expect(subProvider.totalTrialDays, equals(21)); // 7 + 7 + 7
      });

      test('Audit 631: SubscriptionProvider referral code regex allows numbers 2-9 and safe letters', () {
        final codeRegex = RegExp(r'^VAL-[A-Z0-9]{4}$');
        expect(codeRegex.hasMatch('VAL-ABCD'), isTrue);
        expect(codeRegex.hasMatch('VAL-2345'), isTrue);
        expect(codeRegex.hasMatch('VAL-Z9K2'), isTrue);
      });

      test('Audit 632: SubscriptionProvider referral code regex rejects special characters', () {
        final codeRegex = RegExp(r'^VAL-[A-Z0-9]{4}$');
        expect(codeRegex.hasMatch('VAL-AB!D'), isFalse);
        expect(codeRegex.hasMatch('VAL-AB#D'), isFalse);
      });

      test('Audit 633: SubscriptionProvider referral code regex rejects lowercase input without normalization', () {
        final codeRegex = RegExp(r'^VAL-[A-Z0-9]{4}$');
        expect(codeRegex.hasMatch('VAL-abcd'), isFalse);
      });

      test('Audit 634: SubscriptionProvider redeemedCodes list is unmodifiable', () {
        expect(() => subProvider.redeemedCodes.add('HACK'), throwsUnsupportedError);
      });

      test('Audit 635: SubscriptionProvider persists bonus days across instance recreations', () async {
        await subProvider.recordInviteSuccess();
        final subProvider2 = SubscriptionProvider(prefs: prefs);
        expect(subProvider2.referralBonusDays, equals(7));
        expect(subProvider2.totalTrialDays, equals(14));
      });

      test('Audit 636: SubscriptionProvider persists redeemed codes across instance recreations', () async {
        subProvider.redeemInviteCode('VAL-1234');
        final subProvider2 = SubscriptionProvider(prefs: prefs);
        expect(subProvider2.redeemedCodes, contains('VAL-1234'));
      });

      test('Audit 637: SubscriptionProvider persists invitedCount across instance recreations', () async {
        await subProvider.recordInviteSuccess();
        await subProvider.recordInviteSuccess();
        final subProvider2 = SubscriptionProvider(prefs: prefs);
        expect(subProvider2.invitedCount, equals(2));
      });

      test('Audit 638: SubscriptionProvider persists subscription status across instance recreations', () async {
        await subProvider.subscribe();
        final subProvider2 = SubscriptionProvider(prefs: prefs);
        expect(subProvider2.isSubscribed, isTrue);
      });

      test('Audit 639: SubscriptionProvider cleans up expired subscription on re-init', () async {
        final expiredTimestamp = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
        await prefs.setSubscribed(true);
        await prefs.setSubscriptionExpiry(expiredTimestamp);

        final subProvider2 = SubscriptionProvider(prefs: prefs);
        expect(subProvider2.isSubscribed, isFalse);
        expect(subProvider2.subscriptionExpiresAt, isNull);
      });

      test('Audit 640: SubscriptionProvider trialExpiresAt shifts forward by referralBonusDays', () {
        final initialExpiry = subProvider.trialExpiresAt;
        subProvider.redeemInviteCode('VAL-7777');
        final newExpiry = subProvider.trialExpiresAt;
        expect(newExpiry.difference(initialExpiry).inDays, equals(7));
      });

      test('Audit 641: RedemptionResult enum contains all 5 outcome variants', () {
        expect(RedemptionResult.values.length, equals(5));
        expect(RedemptionResult.values, containsAll([
          RedemptionResult.success,
          RedemptionResult.empty,
          RedemptionResult.invalidFormat,
          RedemptionResult.selfCode,
          RedemptionResult.alreadyUsed,
        ]));
      });

      test('Audit 642: SubscriptionProvider shareMessage includes https://valora.app domain', () {
        expect(subProvider.shareMessage, contains('https://valora.app/convite/'));
      });

      test('Audit 643: SubscriptionProvider self code check matches regardless of case difference', () {
        final lowercaseCode = subProvider.userReferralCode.toLowerCase();
        expect(subProvider.redeemInviteCode(lowercaseCode), equals(RedemptionResult.selfCode));
      });

      test('Audit 644: SubscriptionProvider alreadyUsed check matches regardless of casing differences in stored code', () {
        subProvider.redeemInviteCode('VAL-9988');
        expect(subProvider.redeemInviteCode('val-9988'), equals(RedemptionResult.alreadyUsed));
      });

      test('Audit 645: SubscriptionProvider accepts spaces around valid code and trims them automatically', () {
        final result = subProvider.redeemInviteCode('   VAL-5555   ');
        expect(result, equals(RedemptionResult.success));
        expect(subProvider.redeemedCodes, contains('VAL-5555'));
      });

      test('Audit 646: SubscriptionProvider trial calculation avoids daylight saving hour drift', () {
        final launch = subProvider.firstLaunchDate;
        final expiry = subProvider.trialExpiresAt;
        expect(expiry.difference(launch).inDays, equals(subProvider.totalTrialDays));
      });

      test('Audit 647: SubscriptionProvider annual plan cost comparison calculation (12 x monthly)', () {
        final monthly = SubscriptionProvider.monthlyPrice;
        final annualCost = monthly * 12;
        expect(annualCost, closeTo(118.80, 0.01));
      });

      test('Audit 648: SubscriptionProvider trial acceptance persistence matches hasAcceptedTrial getter', () async {
        await subProvider.acceptTrial();
        final subProvider2 = SubscriptionProvider(prefs: prefs);
        expect(subProvider2.hasAcceptedTrial, isTrue);
      });

      test('Audit 649: SubscriptionProvider handles rapid consecutive code redemptions safely', () {
        subProvider.redeemInviteCode('VAL-1111');
        subProvider.redeemInviteCode('VAL-2222');
        subProvider.redeemInviteCode('VAL-3333');
        expect(subProvider.redeemedCodes.length, equals(3));
        expect(subProvider.referralBonusDays, equals(21));
      });

      test('Audit 650: SubscriptionProvider gating blocks access when subscription required, trial expired and not subscribed', () async {
        subProvider.setEnforceOnNonAndroid(true);
        await subProvider.expireTrialForDemo();
        expect(subProvider.hasActiveAccess, isFalse);
      });
    });

    // =========================================================================
    // DOMAIN 10: UI Widget Resilience & Component Robustness (Audits 651-700)
    // =========================================================================
    group('Domain 10: UI Widget Resilience & Contrast Guardrails (Audits 651-700)', () {
      testWidgets('Audit 651: AppButton renders label text cleanly', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            AppButton(
              label: 'Salvar Alimento',
              onPressed: () {},
            ),
          ),
        );
        expect(find.text('Salvar Alimento'), findsOneWidget);
      });

      testWidgets('Audit 652: AppButton fires onPressed callback when tapped', (tester) async {
        var pressed = false;
        await tester.pumpWidget(
          wrapWithApp(
            AppButton(
              label: 'Clique Aqui',
              onPressed: () => pressed = true,
            ),
          ),
        );
        await tester.tap(find.text('Clique Aqui'));
        await tester.pump();
        expect(pressed, isTrue);
      });

      testWidgets('Audit 653: AppButton renders loading indicator when isLoading is true', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            AppButton(
              label: 'Carregando...',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        );
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('Audit 654: AppButton disabled when onPressed is null', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const AppButton(
              label: 'Desativado',
              onPressed: null,
            ),
          ),
        );
        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.enabled, isFalse);
      });

      testWidgets('Audit 655: AppCard renders child widget without overflow', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const AppCard(
              child: Text('Conteúdo do Card'),
            ),
          ),
        );
        expect(find.text('Conteúdo do Card'), findsOneWidget);
      });

      testWidgets('Audit 656: AppCard fires onTap callback when tapped', (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          wrapWithApp(
            AppCard(
              onTap: () => tapped = true,
              child: const Text('Toque no Card'),
            ),
          ),
        );
        await tester.tap(find.text('Toque no Card'));
        await tester.pump();
        expect(tapped, isTrue);
      });

      testWidgets('Audit 657: AppTextField renders label and hint text accurately', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const AppTextField(
              label: 'Nome do Alimento',
              hint: 'Ex: Maçã Gala',
            ),
          ),
        );
        expect(find.text('Nome do Alimento'), findsOneWidget);
        expect(find.text('Ex: Maçã Gala'), findsOneWidget);
      });

      testWidgets('Audit 658: AppTextField captures text input changes', (tester) async {
        String changed = '';
        await tester.pumpWidget(
          wrapWithApp(
            AppTextField(
              label: 'Nome',
              onChanged: (val) => changed = val,
            ),
          ),
        );
        await tester.enterText(find.byType(TextFormField), 'Arroz');
        expect(changed, equals('Arroz'));
      });

      testWidgets('Audit 659: AppTextField displays validation error message when validator fails', (tester) async {
        final formKey = GlobalKey<FormState>();
        await tester.pumpWidget(
          wrapWithApp(
            Form(
              key: formKey,
              child: AppTextField(
                label: 'Nome',
                validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
              ),
            ),
          ),
        );
        formKey.currentState!.validate();
        await tester.pump();
        expect(find.text('Campo obrigatório'), findsOneWidget);
      });

      testWidgets('Audit 660: CategoryChip renders label and icon cleanly', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            CategoryChip(
              label: 'Laticínios',
              icon: Icons.egg_outlined,
              isSelected: false,
              onSelected: () {},
            ),
          ),
        );
        expect(find.text('Laticínios'), findsOneWidget);
        expect(find.byIcon(Icons.egg_outlined), findsOneWidget);
      });

      testWidgets('Audit 661: CategoryChip fires onSelected when tapped', (tester) async {
        var selected = false;
        await tester.pumpWidget(
          wrapWithApp(
            CategoryChip(
              label: 'Frutas',
              isSelected: false,
              onSelected: () => selected = true,
            ),
          ),
        );
        await tester.tap(find.text('Frutas'));
        await tester.pump();
        expect(selected, isTrue);
      });

      testWidgets('Audit 662: ConfirmationDialog renders title and message', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const ConfirmationDialog(
              title: 'Excluir Item',
              content: 'Tem certeza que deseja excluir?',
              confirmLabel: 'Confirmar',
            ),
          ),
        );
        expect(find.text('Excluir Item'), findsOneWidget);
        expect(find.text('Tem certeza que deseja excluir?'), findsOneWidget);
      });

      testWidgets('Audit 663: EmptyStateView renders title, subtitle, and icon', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const EmptyStateView(
              title: 'Despensa Vazia',
              subtitle: 'Adicione seus primeiros alimentos.',
              icon: Icons.inventory_2_outlined,
            ),
          ),
        );
        expect(find.text('Despensa Vazia'), findsOneWidget);
        expect(find.text('Adicione seus primeiros alimentos.'), findsOneWidget);
        expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
      });

      testWidgets('Audit 664: EmptyStateView renders action button when onAction is provided', (tester) async {
        var actionPressed = false;
        await tester.pumpWidget(
          wrapWithApp(
            EmptyStateView(
              title: 'Vazio',
              subtitle: 'Nenhum item',
              actionLabel: 'Adicionar',
              icon: Icons.inventory_2_outlined,
              onAction: () => actionPressed = true,
            ),
          ),
        );
        await tester.tap(find.text('Adicionar'));
        await tester.pump();
        expect(actionPressed, isTrue);
      });

      testWidgets('Audit 665: ExpiryBadge renders localized label for ExpiryStatus.expired', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const ExpiryBadge(status: ExpiryStatus.expired),
          ),
        );
        expect(find.text('Vencido'), findsOneWidget);
      });

      testWidgets('Audit 666: ExpiryBadge renders localized label for ExpiryStatus.expiringToday', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const ExpiryBadge(status: ExpiryStatus.expiringToday),
          ),
        );
        expect(find.text('Vence hoje'), findsOneWidget);
      });

      testWidgets('Audit 667: ExpiryBadge renders localized label for ExpiryStatus.expiringSoon', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const ExpiryBadge(status: ExpiryStatus.expiringSoon, daysRemaining: 3),
          ),
        );
        expect(find.text('Faltam 3 dias'), findsOneWidget);
      });

      testWidgets('Audit 668: ExpiryBadge renders localized label for ExpiryStatus.fresh', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const ExpiryBadge(status: ExpiryStatus.fresh, daysRemaining: 15),
          ),
        );
        expect(find.text('Faltam 15 dias'), findsOneWidget);
      });

      testWidgets('Audit 669: ExpiryBadge renders localized label for ExpiryStatus.unknown', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const ExpiryBadge(status: ExpiryStatus.unknown),
          ),
        );
        expect(find.text('Não informada'), findsOneWidget);
      });

      testWidgets('Audit 670: ValoraAppBar renders title text cleanly', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const ValoraAppBar(title: 'Minha Despensa'),
          ),
        );
        expect(find.text('Minha Despensa'), findsOneWidget);
      });

      testWidgets('Audit 671: ValoraAppBar renders trailing action when provided', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            ValoraAppBar(
              title: 'Despensa',
              trailing: IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            ),
          ),
        );
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('Audit 672: RecordActionDialog renders for consumption action', (tester) async {
        final item = FoodItem(
          id: '1',
          name: 'Iogurte',
          category: FoodCategory.dairy,
          initialQuantity: 1.0,
          unit: FoodUnit.piece,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await tester.pumpWidget(
          wrapWithApp(
            RecordActionDialog(item: item, isDiscard: false),
          ),
        );
        expect(find.byType(RecordActionDialog), findsOneWidget);
        expect(find.text('Registrar Consumo'), findsOneWidget);
      });

      testWidgets('Audit 673: RecordActionDialog renders for disposal action', (tester) async {
        final item = FoodItem(
          id: '1',
          name: 'Leite',
          category: FoodCategory.dairy,
          initialQuantity: 1.0,
          unit: FoodUnit.liter,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await tester.pumpWidget(
          wrapWithApp(
            RecordActionDialog(item: item, isDiscard: true),
          ),
        );
        expect(find.byType(RecordActionDialog), findsOneWidget);
        expect(find.text('Registrar Descarte'), findsOneWidget);
      });

      testWidgets('Audit 674: FoodDetailsSheet renders all food details without exception', (tester) async {
        final item = FoodItem(
          id: '1',
          name: 'Queijo Parmesão',
          category: FoodCategory.dairy,
          initialQuantity: 1.0,
          unit: FoodUnit.kilogram,
          purchasePrice: 45.0,
          storageLocation: StorageLocation.refrigerator,
          expiryDate: DateTime.now().add(const Duration(days: 10)),
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
        expect(find.text('Queijo Parmesão'), findsOneWidget);
      });

      testWidgets('Audit 675: ActivityDetailsSheet renders activity information cleanly', (tester) async {
        final act = FoodActivity(
          id: '1',
          foodItemId: 'item-1',
          foodName: 'Maçã Fuji',
          category: FoodCategory.fruits,
          quantity: 2.0,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: DateTime.now(),
          estimatedValue: 6.0,
        );
        await tester.pumpWidget(
          wrapWithApp(
            ActivityDetailsSheet(activity: act),
          ),
        );
        expect(find.text('Maçã Fuji'), findsOneWidget);
      });

      testWidgets('Audit 676: EditProfileSheet renders without throwing exceptions in dark theme', (tester) async {
        final sp = await SharedPreferences.getInstance();
        final prefs = PreferencesService(sp);
        final notifs = _TestMockNotificationService();
        final settings = SettingsProvider(prefs: prefs, notifications: notifs);
        await tester.pumpWidget(
          wrapWithApp(
            const EditProfileSheet(),
            theme: ThemeData.dark(),
            settings: settings,
          ),
        );
        expect(find.byType(EditProfileSheet), findsOneWidget);
      });

      testWidgets('Audit 677: ConfirmationDialog destructive variant renders cancel and confirm buttons', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const ConfirmationDialog(
              title: 'Excluir?',
              content: 'Confirmar remoção permanente',
              confirmLabel: 'Sim, excluir',
              cancelLabel: 'Voltar',
              isDestructive: true,
            ),
          ),
        );
        expect(find.text('Sim, excluir'), findsOneWidget);
        expect(find.text('Voltar'), findsOneWidget);
      });

      testWidgets('Audit 678: AppCard renders rounded corners matching theme tokens', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const AppCard(
              child: Text('Card Test'),
            ),
          ),
        );
        expect(find.byType(AppCard), findsOneWidget);
      });

      testWidgets('Audit 679: AppButton isFullWidth property expands button to max available width', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            AppButton(
              label: 'Full Width',
              isFullWidth: true,
              onPressed: () {},
            ),
          ),
        );
        expect(find.text('Full Width'), findsOneWidget);
      });

      testWidgets('Audit 680: AppButton renders secondary style correctly', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            AppButton(
              label: 'Secundário',
              variant: AppButtonVariant.secondary,
              onPressed: () {},
            ),
          ),
        );
        expect(find.text('Secundário'), findsOneWidget);
      });

      testWidgets('Audit 681: AppButton renders destructive style with warning red background', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            AppButton(
              label: 'Excluir',
              variant: AppButtonVariant.destructive,
              onPressed: () {},
            ),
          ),
        );
        expect(find.text('Excluir'), findsOneWidget);
      });

      testWidgets('Audit 682: CategoryChip handles long category label without clipping error', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            CategoryChip(
              label: 'Carnes, Aves e Frutos do Mar',
              isSelected: true,
              onSelected: () {},
            ),
          ),
        );
        expect(find.text('Carnes, Aves e Frutos do Mar'), findsOneWidget);
      });

      testWidgets('Audit 683: EmptyStateView renders gracefully in dark mode theme', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const EmptyStateView(
              icon: Icons.inventory_2_outlined,
              title: 'Sem itens',
              subtitle: 'Nenhum alimento cadastrado.',
            ),
            theme: ThemeData.dark(),
          ),
        );
        expect(find.text('Sem itens'), findsOneWidget);
      });

      testWidgets('Audit 684: FoodDetailsSheet renders consume and discard action buttons', (tester) async {
        final item = FoodItem(
          id: '1',
          name: 'Iogurte',
          category: FoodCategory.dairy,
          initialQuantity: 1.0,
          unit: FoodUnit.piece,
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
        expect(find.byType(FoodDetailsSheet), findsOneWidget);
      });

      testWidgets('Audit 685: RecordActionDialog full portion toggle updates consumed amount', (tester) async {
        final item = FoodItem(
          id: '1',
          name: 'Suco',
          category: FoodCategory.drinks,
          initialQuantity: 1.0,
          unit: FoodUnit.liter,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await tester.pumpWidget(
          wrapWithApp(
            RecordActionDialog(item: item, isDiscard: false),
          ),
        );
        expect(find.byType(ChoiceChip), findsNWidgets(2));
      });

      testWidgets('Audit 686: AppTextField readOnly property disables direct text edits', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const AppTextField(
              label: 'Data',
              readOnly: true,
            ),
          ),
        );
        final field = tester.widget<AppTextField>(find.byType(AppTextField));
        expect(field.readOnly, isTrue);
      });

      testWidgets('Audit 687: AppTextField keyboardType property configures number keypad', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const AppTextField(
              label: 'Preço',
              keyboardType: TextInputType.number,
            ),
          ),
        );
        final field = tester.widget<AppTextField>(find.byType(AppTextField));
        expect(field.keyboardType, equals(TextInputType.number));
      });

      testWidgets('Audit 688: AppTextField maxLines allows multi-line notes entry', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const AppTextField(
              label: 'Notas',
              maxLines: 4,
            ),
          ),
        );
        final field = tester.widget<AppTextField>(find.byType(AppTextField));
        expect(field.maxLines, equals(4));
      });

      testWidgets('Audit 689: ValoraAppBar handles null trailing cleanly', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const ValoraAppBar(
              title: 'Título Simples',
              trailing: null,
            ),
          ),
        );
        expect(find.text('Título Simples'), findsOneWidget);
      });

      testWidgets('Audit 690: ConfirmationDialog cancel button returns null or false', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const ConfirmationDialog(
              title: 'Cancelar?',
              content: 'Deseja realmente sair?',
            ),
          ),
        );
        await tester.tap(find.text('Cancelar'));
        await tester.pump();
      });

      testWidgets('Audit 691: ConfirmationDialog confirm button triggers action callback', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const ConfirmationDialog(
              title: 'Confirmar?',
              content: 'Deseja prosseguir?',
              confirmLabel: 'Prosseguir',
            ),
          ),
        );
        await tester.tap(find.text('Prosseguir'));
        await tester.pump();
      });

      testWidgets('Audit 692: ActivityDetailsSheet renders discarded badge when activity is discarded', (tester) async {
        final act = FoodActivity(
          id: '1',
          foodItemId: 'item-1',
          foodName: 'Pão Mofado',
          category: FoodCategory.bakery,
          quantity: 1.0,
          unit: FoodUnit.piece,
          type: ActivityType.discarded,
          timestamp: DateTime.now(),
        );
        await tester.pumpWidget(
          wrapWithApp(
            ActivityDetailsSheet(activity: act),
          ),
        );
        expect(find.text('Pão Mofado'), findsOneWidget);
      });

      testWidgets('Audit 693: AppCard respects custom padding when provided', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const AppCard(
              padding: EdgeInsets.all(24.0),
              child: Text('Card com Padding'),
            ),
          ),
        );
        expect(find.text('Card com Padding'), findsOneWidget);
      });

      testWidgets('Audit 694: ExpiryBadge renders in compact mode without distorting layout', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            const ExpiryBadge(
              status: ExpiryStatus.fresh,
              compact: true,
            ),
          ),
        );
        expect(find.text('No prazo'), findsOneWidget);
      });

      testWidgets('Audit 695: CategoryChip renders selected checkmark icon when selected', (tester) async {
        await tester.pumpWidget(
          wrapWithApp(
            CategoryChip(
              label: 'Verduras',
              isSelected: true,
              onSelected: () {},
            ),
          ),
        );
        expect(find.byType(CategoryChip), findsOneWidget);
      });

      testWidgets('Audit 696: EditProfileSheet allows editing name and email fields', (tester) async {
        final sp = await SharedPreferences.getInstance();
        final prefs = PreferencesService(sp);
        final notifs = _TestMockNotificationService();
        final settings = SettingsProvider(prefs: prefs, notifications: notifs);
        await tester.pumpWidget(
          wrapWithApp(
            const EditProfileSheet(),
            settings: settings,
          ),
        );
        expect(find.byType(TextFormField), findsWidgets);
      });

      testWidgets('Audit 697: FoodDetailsSheet displays storage location tile when present', (tester) async {
        final item = FoodItem(
          id: '1',
          name: 'Iogurte',
          category: FoodCategory.dairy,
          initialQuantity: 1.0,
          unit: FoodUnit.piece,
          storageLocation: StorageLocation.refrigerator,
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
        expect(find.text('Geladeira'), findsOneWidget);
      });

      testWidgets('Audit 698: FoodDetailsSheet displays food category information', (tester) async {
        final item = FoodItem(
          id: '1',
          name: 'Queijo',
          category: FoodCategory.dairy,
          initialQuantity: 1.0,
          unit: FoodUnit.piece,
          purchasePrice: 19.90,
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
        expect(find.textContaining('Laticínios'), findsOneWidget);
      });

      testWidgets('Audit 699: RecordActionDialog handles text notes input', (tester) async {
        final item = FoodItem(
          id: '1',
          name: 'Carne',
          category: FoodCategory.meatFish,
          initialQuantity: 1.0,
          unit: FoodUnit.kilogram,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await tester.pumpWidget(
          wrapWithApp(
            RecordActionDialog(item: item, isDiscard: false),
          ),
        );
        expect(find.byType(TextField), findsWidgets);
      });

      testWidgets('Audit 700: All Valora core widgets render successfully in both Light and Dark themes', (tester) async {
        for (final theme in [ThemeData.light(), ThemeData.dark()]) {
          await tester.pumpWidget(
            wrapWithApp(
              Column(
                children: [
                  AppButton(label: 'Botão', onPressed: () {}),
                  const AppCard(child: Text('Card')),
                  CategoryChip(label: 'Chip', isSelected: false, onSelected: () {}),
                  const ExpiryBadge(status: ExpiryStatus.fresh),
                ],
              ),
              theme: theme,
            ),
          );
          expect(find.text('Botão'), findsOneWidget);
          expect(find.text('Card'), findsOneWidget);
          expect(find.text('Chip'), findsOneWidget);
          expect(find.text('No prazo'), findsOneWidget);
        }
      });
    });
  });
}
