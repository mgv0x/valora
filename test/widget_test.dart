import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valora/core/theme/app_theme.dart';
import 'package:valora/core/widgets/category_chip.dart';
import 'package:valora/core/widgets/valora_logo.dart';
import 'package:valora/data/local/food_repository.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/services/notification_service.dart';
import 'package:valora/data/services/preferences_service.dart';
import 'package:valora/l10n/generated/app_localizations.dart';
import 'package:valora/presentation/navigation/main_navigation_screen.dart';
import 'package:valora/presentation/screens/food_form/add_edit_food_screen.dart';
import 'package:valora/presentation/screens/settings/settings_screen.dart';
import 'package:valora/presentation/screens/subscription/subscription_screen.dart';
import 'package:valora/state/impact_provider.dart';
import 'package:valora/state/pantry_provider.dart';
import 'package:valora/state/settings_provider.dart';
import 'package:valora/state/subscription_provider.dart';

import 'mocks/in_memory_food_repository.dart';

class MockNotificationService implements NotificationService {
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
  }) async {}
  @override
  Future<void> cancelForFood(String foodId) async {}
  @override
  Future<void> cancelAll() async {}
}

void main() {
  Widget createTestWidget({
    required FoodRepository repository,
    required PantryProvider pantryProvider,
    required ImpactProvider impactProvider,
    required SettingsProvider settingsProvider,
    required SubscriptionProvider subscriptionProvider,
    Widget? homeWidget,
  }) {
    return MultiProvider(
      providers: [
        Provider<FoodRepository>.value(value: repository),
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<PantryProvider>.value(value: pantryProvider),
        ChangeNotifierProvider<ImpactProvider>.value(value: impactProvider),
        ChangeNotifierProvider<SubscriptionProvider>.value(value: subscriptionProvider),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: homeWidget ?? const MainNavigationScreen(),
      ),
    );
  }

  group('Valora Widget and Screen Tests', () {
    late InMemoryFoodRepository repository;
    late PantryProvider pantryProvider;
    late ImpactProvider impactProvider;
    late SettingsProvider settingsProvider;
    late SubscriptionProvider subscriptionProvider;
    late MockNotificationService notificationService;
    late PreferencesService preferencesService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      preferencesService = PreferencesService(prefs);

      repository = InMemoryFoodRepository();
      notificationService = MockNotificationService();

      settingsProvider = SettingsProvider(
        prefs: preferencesService,
        notifications: notificationService,
      );

      subscriptionProvider = SubscriptionProvider(prefs: preferencesService);

      pantryProvider = PantryProvider(
        repository: repository,
        notificationService: notificationService,
      );
      impactProvider = ImpactProvider(repository: repository);
    });

    testWidgets('Home Screen displays Valora branding and empty pantry state',
        (WidgetTester tester) async {
      await pantryProvider.loadItems();

      await tester.pumpWidget(
        createTestWidget(
          repository: repository,
          pantryProvider: pantryProvider,
          impactProvider: impactProvider,
          settingsProvider: settingsProvider,
          subscriptionProvider: subscriptionProvider,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(ValoraLogo), findsWidgets);
      expect(find.text('Status da Despensa'), findsOneWidget);
      expect(find.text('Adicionar alimento'), findsWidgets);
    });

    testWidgets('Add Food form validates required fields', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestWidget(
          repository: repository,
          pantryProvider: pantryProvider,
          impactProvider: impactProvider,
          settingsProvider: settingsProvider,
          subscriptionProvider: subscriptionProvider,
          homeWidget: const AddEditFoodScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Novo Alimento'), findsWidgets);

      // Scroll and Tap Save with empty name
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar alimento'));
      await tester.pumpAndSettle();

      // Expect validation error
      expect(find.text('Por favor, informe o nome do alimento.'), findsOneWidget);
    });

    testWidgets('Pantry Screen lists active items and filters by category',
        (WidgetTester tester) async {
      final now = DateTime.now();
      await repository.insertFood(
        FoodItem(
          id: 'apple-1',
          name: 'Crisp Apple',
          category: FoodCategory.fruits,
          initialQuantity: 4,
          unit: FoodUnit.piece,
          expiryDate: now.add(const Duration(days: 6)),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await repository.insertFood(
        FoodItem(
          id: 'milk-1',
          name: 'Whole Milk',
          category: FoodCategory.dairy,
          initialQuantity: 1,
          unit: FoodUnit.liter,
          expiryDate: now.add(const Duration(days: 2)),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await pantryProvider.loadItems();

      await tester.pumpWidget(
        createTestWidget(
          repository: repository,
          pantryProvider: pantryProvider,
          impactProvider: impactProvider,
          settingsProvider: settingsProvider,
          subscriptionProvider: subscriptionProvider,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Pantry tab in bottom navigation
      await tester.tap(find.text('Despensa'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Crisp Apple'), findsOneWidget);
      expect(find.text('Whole Milk'), findsOneWidget);

      // Select Dairy category chip (Laticínios)
      await tester.tap(find.widgetWithText(CategoryChip, 'Laticínios'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Whole Milk'), findsOneWidget);
      expect(find.text('Crisp Apple'), findsNothing);
    });

    testWidgets('Settings Screen renders preferences and data management',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestWidget(
          repository: repository,
          pantryProvider: pantryProvider,
          impactProvider: impactProvider,
          settingsProvider: settingsProvider,
          subscriptionProvider: subscriptionProvider,
          homeWidget: const SettingsScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Configurações'), findsOneWidget);
      expect(find.text('PREFERÊNCIAS DA DESPENSA'), findsOneWidget);
      expect(find.text('Notificações de Validade'), findsOneWidget);
      expect(find.text('DADOS & PRIVACIDADE'), findsOneWidget);
      expect(find.text('Limpar Todos os Alimentos'), findsOneWidget);
    });

    testWidgets('Paywall First Launch displays mandatory 7 days free trial CTA and activates trial',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createTestWidget(
          repository: repository,
          pantryProvider: pantryProvider,
          impactProvider: impactProvider,
          settingsProvider: settingsProvider,
          subscriptionProvider: subscriptionProvider,
          homeWidget: const SubscriptionScreen(isFirstLaunch: true),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Valora'), findsOneWidget);
      expect(find.text('Transforme sua rotina com o Valora Premium'), findsOneWidget);
      expect(find.text('Testar por 7 dias grátis'), findsOneWidget);
      // Close icon is not present on mandatory first launch paywall
      expect(find.byIcon(Icons.close), findsNothing);

      // Tap Testar por 7 dias grátis
      await tester.tap(find.text('Testar por 7 dias grátis'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(subscriptionProvider.hasAcceptedTrial, isTrue);
    });
  });
}
