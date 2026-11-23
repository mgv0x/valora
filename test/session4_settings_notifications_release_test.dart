import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valora/data/local/food_repository.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/services/notification_service.dart';
import 'package:valora/data/services/preferences_service.dart';
import 'package:valora/l10n/generated/app_localizations.dart';
import 'package:valora/presentation/screens/settings/settings_screen.dart';
import 'package:valora/state/impact_provider.dart';
import 'package:valora/state/pantry_provider.dart';
import 'package:valora/state/settings_provider.dart';
import 'package:valora/state/subscription_provider.dart';

import 'mocks/in_memory_food_repository.dart';

/// Test spy for NotificationService that tracks all scheduled and cancelled alerts.
class MockNotificationService implements NotificationService {
  bool permissionToReturn = true;
  int initCallCount = 0;
  int requestPermissionCallCount = 0;
  int cancelAllCallCount = 0;
  final List<String> cancelledFoodIds = [];
  final List<Map<String, dynamic>> scheduledAlerts = [];

  @override
  Future<void> init() async {
    initCallCount++;
  }

  @override
  Future<bool> requestPermission() async {
    requestPermissionCallCount++;
    return permissionToReturn;
  }

  @override
  Future<void> scheduleExpiryWarning({
    required FoodItem item,
    required int warningDays,
    required String title,
    required String body,
  }) async {
    scheduledAlerts.add({
      'foodId': item.id,
      'foodName': item.name,
      'warningDays': warningDays,
      'title': title,
      'body': body,
    });
  }

  @override
  Future<void> cancelForFood(String foodId) async {
    cancelledFoodIds.add(foodId);
    scheduledAlerts.removeWhere((a) => a['foodId'] == foodId);
  }

  @override
  Future<void> cancelAll() async {
    cancelAllCallCount++;
    scheduledAlerts.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('A. PreferencesService & App Restart Persistence', () {
    test('Saves and loads all settings values correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs1 = await PreferencesService.create();

      // Verify defaults
      expect(prefs1.localeCode, isNull);
      expect(prefs1.warningThresholdDays, equals(3));
      expect(prefs1.notificationsEnabled, isFalse); // opt-in by default
      expect(prefs1.themeMode, isNull);

      // Mutate preferences
      await prefs1.setLocaleCode('pt');
      await prefs1.setWarningThresholdDays(5);
      await prefs1.setNotificationsEnabled(true);
      await prefs1.setThemeMode('dark');

      expect(prefs1.localeCode, equals('pt'));
      expect(prefs1.warningThresholdDays, equals(5));
      expect(prefs1.notificationsEnabled, isTrue);
      expect(prefs1.themeMode, equals('dark'));

      // Simulate App Restart with a fresh PreferencesService reading from disk
      final prefs2 = await PreferencesService.create();
      expect(prefs2.localeCode, equals('pt'));
      expect(prefs2.warningThresholdDays, equals(5));
      expect(prefs2.notificationsEnabled, isTrue);
      expect(prefs2.themeMode, equals('dark'));
    });
  });

  group('B. SettingsProvider Reactive State Transitions', () {
    late PreferencesService prefs;
    late MockNotificationService mockNotifications;
    late SettingsProvider settings;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await PreferencesService.create();
      mockNotifications = MockNotificationService();
      settings = SettingsProvider(prefs: prefs, notifications: mockNotifications);
    });

    test('Initializes with default values from PreferencesService', () {
      expect(settings.locale, isNull);
      expect(settings.warningThresholdDays, equals(3));
      expect(settings.notificationsEnabled, isFalse);
      expect(settings.themeMode, equals(ThemeMode.system));
    });

    test('Updates locale and notifies listeners', () async {
      int listenerCalls = 0;
      settings.addListener(() => listenerCalls++);

      await settings.setLocale('pt');
      expect(settings.locale?.languageCode, equals('pt'));
      expect(listenerCalls, equals(1));

      await settings.setLocale('en');
      expect(settings.locale?.languageCode, equals('en'));
      expect(listenerCalls, equals(2));

      await settings.setLocale(null);
      expect(settings.locale, isNull);
      expect(listenerCalls, equals(3));
    });

    test('Updates warning threshold within valid boundaries', () async {
      await settings.setWarningThresholdDays(7);
      expect(settings.warningThresholdDays, equals(7));

      // Guard boundaries: Rejects values < 1 or > 30
      await settings.setWarningThresholdDays(0);
      expect(settings.warningThresholdDays, equals(7)); // unchanged

      await settings.setWarningThresholdDays(35);
      expect(settings.warningThresholdDays, equals(7)); // unchanged
    });

    test('Handles theme mode changes accurately', () async {
      await settings.setThemeMode(ThemeMode.dark);
      expect(settings.themeMode, equals(ThemeMode.dark));

      await settings.setThemeMode(ThemeMode.light);
      expect(settings.themeMode, equals(ThemeMode.light));

      await settings.setThemeMode(ThemeMode.system);
      expect(settings.themeMode, equals(ThemeMode.system));
    });

    test('Manages notification permission and cancels alerts when disabled', () async {
      mockNotifications.permissionToReturn = true;

      // Enable notifications
      final resultEnable = await settings.setNotificationsEnabled(true);
      expect(resultEnable, isTrue);
      expect(settings.notificationsEnabled, isTrue);
      expect(mockNotifications.requestPermissionCallCount, equals(1));

      // Disable notifications
      final resultDisable = await settings.setNotificationsEnabled(false);
      expect(resultDisable, isFalse);
      expect(settings.notificationsEnabled, isFalse);
      expect(mockNotifications.cancelAllCallCount, equals(1));

      // Re-enable with denied permission
      mockNotifications.permissionToReturn = false;
      final resultDenied = await settings.setNotificationsEnabled(true);
      expect(resultDenied, isFalse);
      expect(settings.notificationsEnabled, isFalse);
    });
  });

  group('C. Notification Scheduling & Rescheduling Lifecycle in PantryProvider', () {
    late InMemoryFoodRepository mockRepo;
    late MockNotificationService mockNotifications;
    late PantryProvider pantry;
    final now = DateTime(2026, 10, 8, 12, 0);

    setUp(() async {
      mockRepo = InMemoryFoodRepository();
      mockNotifications = MockNotificationService();
      pantry = PantryProvider(
        repository: mockRepo,
        notificationService: mockNotifications,
      );
      pantry.updateWarningThreshold(3);
    });

    test('Schedules warning when food item with expiry is added', () async {
      final item = FoodItem(
        id: 'apple-1',
        name: 'Maçã Fuji',
        category: FoodCategory.fruits,
        initialQuantity: 4,
        unit: FoodUnit.piece,
        expiryDate: now.add(const Duration(days: 5)),
        createdAt: now,
        updatedAt: now,
      );

      await pantry.addFood(item);

      expect(mockNotifications.scheduledAlerts.length, equals(1));
      expect(mockNotifications.scheduledAlerts.first['foodId'], equals('apple-1'));
      expect(mockNotifications.scheduledAlerts.first['warningDays'], equals(3));
    });

    test('Does not schedule warning for food with unknown expiry', () async {
      final item = FoodItem(
        id: 'rice-1',
        name: 'Arroz Integral',
        category: FoodCategory.pantryStaples,
        initialQuantity: 1,
        unit: FoodUnit.kilogram,
        expiryDate: null,
        createdAt: now,
        updatedAt: now,
      );

      await pantry.addFood(item);
      expect(mockNotifications.scheduledAlerts, isEmpty);
    });

    test('Cancels notification when food is deleted', () async {
      final item = FoodItem(
        id: 'milk-1',
        name: 'Leite Integral',
        category: FoodCategory.dairy,
        initialQuantity: 1,
        unit: FoodUnit.liter,
        expiryDate: now.add(const Duration(days: 4)),
        createdAt: now,
        updatedAt: now,
      );

      await pantry.addFood(item);
      expect(mockNotifications.scheduledAlerts.length, equals(1));

      await pantry.deleteFood('milk-1');
      expect(mockNotifications.cancelledFoodIds, contains('milk-1'));
      expect(mockNotifications.scheduledAlerts, isEmpty);
    });

    test('Cancels notification when food is fully consumed', () async {
      final item = FoodItem(
        id: 'yogurt-1',
        name: 'Iogurte Natural',
        category: FoodCategory.dairy,
        initialQuantity: 2,
        unit: FoodUnit.piece,
        expiryDate: now.add(const Duration(days: 2)),
        createdAt: now,
        updatedAt: now,
      );

      await pantry.addFood(item);

      // Consume 2 out of 2
      await pantry.recordConsumption(item: item, consumedQuantity: 2);
      expect(mockNotifications.cancelledFoodIds, contains('yogurt-1'));
    });

    test('Cancels notification when food is fully discarded', () async {
      final item = FoodItem(
        id: 'bread-1',
        name: 'Pão de Forma',
        category: FoodCategory.bakery,
        initialQuantity: 1,
        unit: FoodUnit.piece,
        expiryDate: now.add(const Duration(days: 1)),
        createdAt: now,
        updatedAt: now,
      );

      await pantry.addFood(item);

      // Discard 1 out of 1
      await pantry.recordDisposal(item: item, discardedQuantity: 1);
      expect(mockNotifications.cancelledFoodIds, contains('bread-1'));
    });

    test('Reschedules all active warnings when warning threshold changes', () async {
      final item1 = FoodItem(
        id: 'cheese-1',
        name: 'Queijo Minas',
        category: FoodCategory.dairy,
        initialQuantity: 1,
        unit: FoodUnit.piece,
        expiryDate: now.add(const Duration(days: 6)),
        createdAt: now,
        updatedAt: now,
      );
      final item2 = FoodItem(
        id: 'tomato-1',
        name: 'Tomate Italiano',
        category: FoodCategory.vegetables,
        initialQuantity: 5,
        unit: FoodUnit.piece,
        expiryDate: now.add(const Duration(days: 3)),
        createdAt: now,
        updatedAt: now,
      );

      await pantry.addFood(item1);
      await pantry.addFood(item2);

      // Change threshold from 3 to 5 days
      await pantry.updateWarningThreshold(5);

      expect(pantry.warningThresholdDays, equals(5));
      expect(mockNotifications.cancelAllCallCount, greaterThanOrEqualTo(1));
      expect(mockNotifications.scheduledAlerts.length, equals(2));
      expect(mockNotifications.scheduledAlerts.every((a) => a['warningDays'] == 5), isTrue);
    });

    test('Disabling notifications cancels all alerts and prevents new schedules', () async {
      final item = FoodItem(
        id: 'melon-1',
        name: 'Melão Amarelo',
        category: FoodCategory.fruits,
        initialQuantity: 1,
        unit: FoodUnit.piece,
        expiryDate: now.add(const Duration(days: 7)),
        createdAt: now,
        updatedAt: now,
      );

      await pantry.addFood(item);
      expect(mockNotifications.scheduledAlerts.length, equals(1));

      // Disable notifications in pantry
      pantry.setNotificationsEnabled(false);
      expect(mockNotifications.scheduledAlerts, isEmpty);

      // Adding another item when disabled does not schedule alerts
      final item2 = FoodItem(
        id: 'pear-1',
        name: 'Pera Williams',
        category: FoodCategory.fruits,
        initialQuantity: 2,
        unit: FoodUnit.piece,
        expiryDate: now.add(const Duration(days: 4)),
        createdAt: now,
        updatedAt: now,
      );
      await pantry.addFood(item2);
      expect(mockNotifications.scheduledAlerts, isEmpty);
    });

    test('rescheduleAllExpiryWarnings resets and repopulates alerts for all active items', () async {
      await mockRepo.insertFood(FoodItem(
        id: 'imported-1',
        name: 'Manteiga',
        category: FoodCategory.dairy,
        initialQuantity: 1,
        unit: FoodUnit.piece,
        expiryDate: now.add(const Duration(days: 10)),
        createdAt: now,
        updatedAt: now,
      ));
      await mockRepo.insertFood(FoodItem(
        id: 'imported-2',
        name: 'Iogurte',
        category: FoodCategory.dairy,
        initialQuantity: 2,
        unit: FoodUnit.piece,
        expiryDate: now.add(const Duration(days: 4)),
        createdAt: now,
        updatedAt: now,
      ));

      await pantry.loadItems();
      await pantry.rescheduleAllExpiryWarnings();

      expect(mockNotifications.cancelAllCallCount, greaterThanOrEqualTo(1));
      expect(mockNotifications.scheduledAlerts.length, equals(2));
      expect(mockNotifications.scheduledAlerts.map((a) => a['foodId']), containsAll(['imported-1', 'imported-2']));
    });
  });

  group('D. SettingsScreen Widget & Localization Tests', () {
    late InMemoryFoodRepository mockRepo;
    late PreferencesService prefs;
    late MockNotificationService mockNotifications;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'valora_pref_user_name': 'Helena Silva',
        'valora_pref_is_logged_in': true,
      });
      prefs = await PreferencesService.create();
      mockNotifications = MockNotificationService();
      mockRepo = InMemoryFoodRepository();
    });

    Widget createTestApp({Locale locale = const Locale('pt')}) {
      final settingsProvider = SettingsProvider(
        prefs: prefs,
        notifications: mockNotifications,
      );
      final pantryProvider = PantryProvider(
        repository: mockRepo,
        notificationService: mockNotifications,
      );
      final impactProvider = ImpactProvider(repository: mockRepo);
      final subscriptionProvider = SubscriptionProvider(prefs: prefs);

      return MultiProvider(
        providers: [
          Provider<FoodRepository>.value(value: mockRepo),
          ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
          ChangeNotifierProvider<SubscriptionProvider>.value(value: subscriptionProvider),
          ChangeNotifierProvider<PantryProvider>.value(value: pantryProvider),
          ChangeNotifierProvider<ImpactProvider>.value(value: impactProvider),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      );
    }

    testWidgets('Renders all sections in Portuguese correctly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestApp(locale: const Locale('pt')));
      await tester.pumpAndSettle();

      // Title & User Profile
      expect(find.text('Configurações'), findsOneWidget);
      expect(find.text('Helena Silva'), findsOneWidget);

      // Key Settings Tiles
      expect(find.text('Notificações de Validade'), findsOneWidget);
      expect(find.text('Antecedência do Aviso'), findsOneWidget);
      expect(find.text('Convidar Amigos & Ganhar Premium'), findsOneWidget);
      expect(find.text('Gerenciar Assinatura'), findsOneWidget);

      // Scroll down to reveal lower sections
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('DADOS & PRIVACIDADE'), findsOneWidget);
      expect(find.text('SOBRE O APLICATIVO'), findsOneWidget);
      expect(find.text('Limpar Todos os Alimentos'), findsOneWidget);
    });

    testWidgets('Renders Premium banner and subscription price correctly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestApp(locale: const Locale('pt')));
      await tester.pumpAndSettle();

      expect(find.text('Valora Premium'), findsOneWidget);
      expect(find.text('R\$ 9,90'), findsOneWidget);
      expect(find.text('Desbloquear'), findsOneWidget);
    });

    testWidgets('Threshold tap updates warning threshold in pantry', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestApp(locale: const Locale('pt')));
      await tester.pumpAndSettle();

      // Default threshold is 3 dias antes
      expect(find.text('3 dias antes'), findsOneWidget);

      // Tap Antecedência do Aviso to cycle threshold
      await tester.tap(find.text('Antecedência do Aviso'));
      await tester.pumpAndSettle();

      expect(find.text('5 dias antes'), findsOneWidget);
    });

    testWidgets('Convidar Amigos opens referral program screen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestApp(locale: const Locale('pt')));
      await tester.pumpAndSettle();

      // Tap Convidar Amigos
      await tester.tap(find.text('Convidar Amigos & Ganhar Premium'));
      await tester.pumpAndSettle();

      expect(find.text('Indique e Ganhe'), findsOneWidget);
      expect(find.text('Suas Conquistas'), findsOneWidget);
    });

    testWidgets('Clear data button prompts with confirmation dialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestApp(locale: const Locale('pt')));
      await tester.pumpAndSettle();

      // Scroll down to reveal clear data button
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Tap Clear Data
      await tester.tap(find.text('Limpar Todos os Alimentos'));
      await tester.pumpAndSettle();

      // Dialog opens
      expect(find.text('Limpar Despensa?'), findsOneWidget);
      expect(find.textContaining('Esta ação não pode ser desfeita'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Limpar Tudo'), findsOneWidget);

      // Cancel dismisses dialog without deleting
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(find.text('Limpar Tudo'), findsNothing);
    });
  });
}
