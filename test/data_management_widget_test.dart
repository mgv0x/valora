import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:valora/data/local/food_repository.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/services/notification_service.dart';
import 'package:valora/data/services/preferences_service.dart';
import 'package:valora/l10n/generated/app_localizations.dart';
import 'package:valora/presentation/screens/data_management/data_management_screen.dart';
import 'package:valora/presentation/screens/food_form/widgets/api_food_search_sheet.dart';
import 'package:valora/state/impact_provider.dart';
import 'package:valora/state/pantry_provider.dart';
import 'package:valora/state/settings_provider.dart';
import 'package:valora/state/shopping_list_provider.dart';
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
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late InMemoryFoodRepository repo;
  late PreferencesService prefs;
  late PantryProvider pantryProvider;
  late ImpactProvider impactProvider;
  late ShoppingListProvider shoppingProvider;
  late SettingsProvider settingsProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await PreferencesService.create();
    repo = InMemoryFoodRepository();

    pantryProvider = PantryProvider(
      repository: repo,
      preferencesService: prefs,
    );
    impactProvider = ImpactProvider(repository: repo);
    shoppingProvider = ShoppingListProvider(prefs: prefs);
    settingsProvider = SettingsProvider(
      prefs: prefs,
      notifications: MockNotificationService(),
    );

    // Insert dummy item
    final now = DateTime.now();
    await repo.insertFood(FoodItem(
      id: 'ui-food-1',
      name: 'Iogurte Natural',
      category: FoodCategory.dairy,
      initialQuantity: 2,
      unit: FoodUnit.piece,
      createdAt: now,
      updatedAt: now,
    ));
    await pantryProvider.loadItems();
    await impactProvider.loadActivities();
  });

  Widget buildTestApp(Widget child) {
    return MultiProvider(
      providers: [
        Provider<FoodRepository>.value(value: repo),
        ChangeNotifierProvider<PantryProvider>.value(value: pantryProvider),
        ChangeNotifierProvider<ImpactProvider>.value(value: impactProvider),
        ChangeNotifierProvider<ShoppingListProvider>.value(value: shoppingProvider),
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );
  }

  testWidgets('DataManagementScreen renders all 3 data system sections', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp(const DataManagementScreen()));
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Gerenciamento de Dados'), findsOneWidget);

    // Verify 1. Local Storage section
    expect(find.text('1. ARMAZENAMENTO LOCAL (SQLITE & ACID)'), findsOneWidget);
    expect(find.text('Otimizar Banco'), findsOneWidget);
    expect(find.text('Exportar JSON'), findsOneWidget);

    // Verify 2. Cloud Database section
    expect(find.text('2. BANCO EM NUVEM & SINCRONIZAÇÃO'), findsOneWidget);
    expect(find.text('Sincronizar com Nuvem'), findsOneWidget);

    // Verify 3. APIs section
    expect(find.text('3. APIS E SERVIÇOS CONECTADOS'), findsOneWidget);
    expect(find.text('Open Food Facts REST API'), findsOneWidget);
  });

  testWidgets('ApiFoodSearchSheet renders search input and quick tags', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestApp(const Scaffold(body: ApiFoodSearchSheet())));
    await tester.pumpAndSettle();

    expect(find.text('Base Global Open Food Facts API'), findsOneWidget);
    expect(find.text('Leite'), findsWidgets);
    expect(find.text('Arroz'), findsOneWidget);
    expect(find.text('Feijão'), findsOneWidget);
  });
}
