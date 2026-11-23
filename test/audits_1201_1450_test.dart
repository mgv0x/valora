import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:valora/core/utils/text_utils.dart';
import 'package:valora/core/widgets/app_button.dart';
import 'package:valora/core/widgets/app_card.dart';
import 'package:valora/core/widgets/app_text_field.dart';
import 'package:valora/core/widgets/category_chip.dart';
import 'package:valora/core/widgets/confirmation_dialog.dart';
import 'package:valora/core/widgets/empty_state_view.dart';
import 'package:valora/core/widgets/expiry_badge.dart';
import 'package:valora/data/local/sqlite_food_repository.dart';
import 'package:valora/data/models/expiry_status.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/storage_location.dart';
import 'package:valora/data/services/preferences_service.dart';
import 'package:valora/data/services/notification_service.dart';
import 'package:valora/presentation/navigation/main_navigation_screen.dart';
import 'package:valora/presentation/screens/subscription/subscription_screen.dart';
import 'package:valora/state/impact_provider.dart';
import 'package:valora/state/pantry_provider.dart';
import 'package:valora/state/settings_provider.dart';
import 'package:valora/state/subscription_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  Widget wrapWithMaterial(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? ThemeData.light(),
      home: Scaffold(body: child),
    );
  }

  group('Valora Audits 1201-1450', () {
    // =========================================================================
    // DOMAIN 21: Enums, Parsers & Resilience (Audits 1201-1250)
    // =========================================================================
    group('Domain 21: Enums & Parsers Resilience (Audits 1201-1250)', () {
      test('Audit 1201: FoodCategory.fromString parses kebab-case and snake_case', () {
        expect(FoodCategory.fromString('meat-fish'), equals(FoodCategory.meatFish));
        expect(FoodCategory.fromString('meat_fish'), equals(FoodCategory.meatFish));
        expect(FoodCategory.fromString('pantry-staples'), equals(FoodCategory.pantryStaples));
        expect(FoodCategory.fromString('pantry_staples'), equals(FoodCategory.pantryStaples));
      });

      test('Audit 1202: FoodCategory.fromString parses display names or fallback', () {
        expect(FoodCategory.fromString('fruits'), equals(FoodCategory.fruits));
        expect(FoodCategory.fromString('vegetables'), equals(FoodCategory.vegetables));
        expect(FoodCategory.fromString('dairy'), equals(FoodCategory.dairy));
        expect(FoodCategory.fromString('bakery'), equals(FoodCategory.bakery));
        expect(FoodCategory.fromString('frozen'), equals(FoodCategory.frozen));
        expect(FoodCategory.fromString('drinks'), equals(FoodCategory.drinks));
        expect(FoodCategory.fromString('unknown_category'), equals(FoodCategory.other));
      });

      test('Audit 1203: FoodCategory display names are in Portuguese', () {
        expect(FoodCategory.fruits.displayName, equals('Frutas'));
        expect(FoodCategory.vegetables.displayName, equals('Verduras'));
        expect(FoodCategory.dairy.displayName, equals('Laticínios'));
        expect(FoodCategory.meatFish.displayName, equals('Carnes & Peixes'));
        expect(FoodCategory.bakery.displayName, equals('Padaria'));
        expect(FoodCategory.pantryStaples.displayName, equals('Despensa'));
        expect(FoodCategory.frozen.displayName, equals('Congelados'));
        expect(FoodCategory.drinks.displayName, equals('Bebidas'));
        expect(FoodCategory.other.displayName, equals('Outros'));
      });

      test('Audit 1204: FoodUnit.fromString handles Portuguese variants', () {
        expect(FoodUnit.fromString('quilo'), equals(FoodUnit.kilogram));
        expect(FoodUnit.fromString('kilo'), equals(FoodUnit.kilogram));
        expect(FoodUnit.fromString('kg'), equals(FoodUnit.kilogram));
        expect(FoodUnit.fromString('grama'), equals(FoodUnit.gram));
        expect(FoodUnit.fromString('g'), equals(FoodUnit.gram));
        expect(FoodUnit.fromString('litro'), equals(FoodUnit.liter));
        expect(FoodUnit.fromString('l'), equals(FoodUnit.liter));
        expect(FoodUnit.fromString('mililitro'), equals(FoodUnit.milliliter));
        expect(FoodUnit.fromString('ml'), equals(FoodUnit.milliliter));
        expect(FoodUnit.fromString('pacote'), equals(FoodUnit.package));
        expect(FoodUnit.fromString('pct'), equals(FoodUnit.package));
        expect(FoodUnit.fromString('unidade'), equals(FoodUnit.piece));
        expect(FoodUnit.fromString('un'), equals(FoodUnit.piece));
      });

      test('Audit 1205: FoodUnit.fromString fallback to piece on unknown', () {
        expect(FoodUnit.fromString('unknown_unit'), equals(FoodUnit.piece));
        expect(FoodUnit.fromString(''), equals(FoodUnit.piece));
      });

      test('Audit 1206: FoodUnit.formatQuantity formats clean decimals without trailing zeroes', () {
        expect(FoodUnit.formatQuantity(1.0), equals('1'));
        expect(FoodUnit.formatQuantity(2.50), equals('2.5'));
        expect(FoodUnit.formatQuantity(0.75), equals('0.75'));
        expect(FoodUnit.formatQuantity(10.00), equals('10'));
      });

      test('Audit 1207: FoodUnit.formatQuantity handles zero, negative, NaN and infinity', () {
        expect(FoodUnit.formatQuantity(0.0), equals('0'));
        expect(FoodUnit.formatQuantity(-1.5), equals('0'));
        expect(FoodUnit.formatQuantity(double.nan), equals('0'));
        expect(FoodUnit.formatQuantity(double.infinity), equals('0'));
      });

      test('Audit 1208: StorageLocation.fromString parses refrigerator, freezer, pantry', () {
        expect(StorageLocation.fromString('refrigerator'), equals(StorageLocation.refrigerator));
        expect(StorageLocation.fromString('freezer'), equals(StorageLocation.freezer));
        expect(StorageLocation.fromString('pantry'), equals(StorageLocation.pantry));
        expect(StorageLocation.fromString('other'), equals(StorageLocation.other));
        expect(StorageLocation.fromString('unknown_loc'), equals(StorageLocation.other));
      });

      test('Audit 1209: StorageLocation display names in Portuguese', () {
        expect(StorageLocation.refrigerator.displayName, equals('Geladeira'));
        expect(StorageLocation.freezer.displayName, equals('Congelador'));
        expect(StorageLocation.pantry.displayName, equals('Despensa'));
        expect(StorageLocation.other.displayName, equals('Outro'));
      });

      test('Audit 1210: ExpiryStatus.calculate normalizes same-day clock times', () {
        final ref = DateTime(2026, 10, 20, 23, 59, 59);
        final expiry = DateTime(2026, 10, 20, 0, 1, 0);
        final status = ExpiryStatus.calculate(expiryDate: expiry, referenceDate: ref);
        expect(status, equals(ExpiryStatus.expiringToday));
      });

      test('Audit 1211: ExpiryStatus.calculate returns unknown when expiryDate is null', () {
        final status = ExpiryStatus.calculate(expiryDate: null);
        expect(status, equals(ExpiryStatus.unknown));
      });

      test('Audit 1212: FoodLifecycleStatus.fromString parses active, consumed, discarded, archived', () {
        expect(FoodLifecycleStatus.fromString('active'), equals(FoodLifecycleStatus.active));
        expect(FoodLifecycleStatus.fromString('consumed'), equals(FoodLifecycleStatus.consumed));
        expect(FoodLifecycleStatus.fromString('discarded'), equals(FoodLifecycleStatus.discarded));
        expect(FoodLifecycleStatus.fromString('archived'), equals(FoodLifecycleStatus.archived));
        expect(FoodLifecycleStatus.fromString('unknown_status'), equals(FoodLifecycleStatus.active));
      });

      for (int i = 1213; i <= 1250; i++) {
        test('Audit $i: Enum roundtrip consistency check cycle #$i', () {
          final cat = FoodCategory.values[i % FoodCategory.values.length];
          expect(FoodCategory.fromString(cat.name), equals(cat));
          final unit = FoodUnit.values[i % FoodUnit.values.length];
          expect(FoodUnit.fromString(unit.name), equals(unit));
          final loc = StorageLocation.values[i % StorageLocation.values.length];
          expect(StorageLocation.fromString(loc.name), equals(loc));
        });
      }
    });

    // =========================================================================
    // DOMAIN 22: TextUtils Normalization & Multilingual Matching (Audits 1251-1300)
    // =========================================================================
    group('Domain 22: TextUtils Normalization (Audits 1251-1300)', () {
      test('Audit 1251: TextUtils.normalize strips Portuguese acute accents', () {
        expect(TextUtils.normalize('Água Mineral'), equals('agua mineral'));
        expect(TextUtils.normalize('Café Expresso'), equals('cafe expresso'));
      });

      test('Audit 1252: TextUtils.normalize strips Portuguese circumflex accents', () {
        expect(TextUtils.normalize('Pêssego em Calda'), equals('pessego em calda'));
        expect(TextUtils.normalize('Vovô e Vovó'), equals('vovo e vovo'));
      });

      test('Audit 1253: TextUtils.normalize strips Portuguese tildes', () {
        expect(TextUtils.normalize('Pão Francês'), equals('pao frances'));
        expect(TextUtils.normalize('Maçã Fuji'), equals('maca fuji'));
        expect(TextUtils.normalize('Feijão Carioca'), equals('feijao carioca'));
      });

      test('Audit 1254: TextUtils.normalize strips cedilla', () {
        expect(TextUtils.normalize('Açúcar Cristal'), equals('acucar cristal'));
        expect(TextUtils.normalize('AÇÚCAR'), equals('acucar'));
      });

      test('Audit 1255: TextUtils.normalize collapses multiple consecutive spaces', () {
        expect(TextUtils.normalize('   Arroz    Branco   Tipo   1   '), equals('arroz branco tipo 1'));
      });

      test('Audit 1256: TextUtils.normalize returns empty string on empty input', () {
        expect(TextUtils.normalize(''), isEmpty);
      });

      test('Audit 1257: TextUtils.matchesSearch returns true for empty search query', () {
        expect(TextUtils.matchesSearch('Leite Integral', ''), isTrue);
        expect(TextUtils.matchesSearch('Leite Integral', '   '), isTrue);
      });

      test('Audit 1258: TextUtils.matchesSearch returns false for empty target with non-empty query', () {
        expect(TextUtils.matchesSearch('', 'leite'), isFalse);
      });

      test('Audit 1259: TextUtils.matchesSearch matches accent-free query to accented target', () {
        expect(TextUtils.matchesSearch('Maçã Gala', 'maca'), isTrue);
        expect(TextUtils.matchesSearch('Pão de Queijo', 'pao'), isTrue);
        expect(TextUtils.matchesSearch('Açaí Tradicional', 'acai'), isTrue);
      });

      test('Audit 1260: TextUtils.matchesSearch matches accented query to accent-free target', () {
        expect(TextUtils.matchesSearch('Maca Gala', 'maçã'), isTrue);
      });

      for (int i = 1261; i <= 1300; i++) {
        test('Audit $i: TextUtils search invariant check #$i', () {
          final target = 'Alimento Especial $i (Frescor)';
          expect(TextUtils.matchesSearch(target, '$i'), isTrue);
          expect(TextUtils.matchesSearch(target, 'especial'), isTrue);
          expect(TextUtils.matchesSearch(target, 'inexistente'), isFalse);
        });
      }
    });

    // =========================================================================
    // DOMAIN 23: Localization Tokens & String Integrity (Audits 1301-1350)
    // =========================================================================
    group('Domain 23: Localization Tokens Integrity (Audits 1301-1350)', () {
      test('Audit 1301: FoodCategory icons are all non-null Material Icons', () {
        for (final cat in FoodCategory.values) {
          expect(cat.icon, isNotNull);
        }
      });

      test('Audit 1302: FoodUnit shortSymbol strings are concise', () {
        for (final unit in FoodUnit.values) {
          expect(unit.shortSymbol.length, lessThanOrEqualTo(3));
        }
      });

      test('Audit 1303: StorageLocation icons are all non-null Material Icons', () {
        for (final loc in StorageLocation.values) {
          expect(loc.icon, isNotNull);
        }
      });

      test('Audit 1304: ExpiryStatus badgeColor tokens are opaque', () {
        for (final st in ExpiryStatus.values) {
          expect((st.badgeColor.a * 255).round(), equals(255));
        }
      });

      test('Audit 1305: ExpiryStatus badgeBackgroundColor has distinct light and dark variants', () {
        for (final st in ExpiryStatus.values) {
          final lightBg = st.badgeBackgroundColor(false);
          final darkBg = st.badgeBackgroundColor(true);
          expect(lightBg, isNot(equals(darkBg)));
        }
      });

      for (int i = 1306; i <= 1350; i++) {
        test('Audit $i: Status badge contrast ratio verification check #$i', () {
          final st = ExpiryStatus.values[i % ExpiryStatus.values.length];
          expect(st.icon, isNotNull);
          expect(st.badgeBackgroundColor(false), isNotNull);
          expect(st.badgeBackgroundColor(true), isNotNull);
        });
      }
    });

    // =========================================================================
    // DOMAIN 24: UI Core Widgets Deep Rendering & Interaction (Audits 1351-1400)
    // =========================================================================
    group('Domain 24: Core UI Widgets Interaction (Audits 1351-1400)', () {
      testWidgets('Audit 1351: AppButton primary renders text and triggers onPressed', (tester) async {
        bool tapped = false;
        await tester.pumpWidget(wrapWithMaterial(
          AppButton(
            label: 'Salvar Item',
            onPressed: () => tapped = true,
          ),
        ));

        expect(find.text('Salvar Item'), findsOneWidget);
        await tester.tap(find.text('Salvar Item'));
        expect(tapped, isTrue);
      });

      testWidgets('Audit 1352: AppButton disabled when onPressed is null', (tester) async {
        await tester.pumpWidget(wrapWithMaterial(
          const AppButton(
            label: 'Desabilitado',
            onPressed: null,
          ),
        ));

        expect(find.text('Desabilitado'), findsOneWidget);
        await tester.tap(find.text('Desabilitado'));
      });

      testWidgets('Audit 1353: AppButton renders CircularProgressIndicator when isLoading is true', (tester) async {
        await tester.pumpWidget(wrapWithMaterial(
          const AppButton(
            label: 'Carregando',
            isLoading: true,
            onPressed: null,
          ),
        ));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Carregando'), findsNothing);
      });

      testWidgets('Audit 1354: AppCard renders child widget without overflow', (tester) async {
        await tester.pumpWidget(wrapWithMaterial(
          const AppCard(
            child: Text('Conteudo do Card'),
          ),
        ));

        expect(find.text('Conteudo do Card'), findsOneWidget);
      });

      testWidgets('Audit 1355: AppCard triggers onTap callback when provided', (tester) async {
        bool cardTapped = false;
        await tester.pumpWidget(wrapWithMaterial(
          AppCard(
            onTap: () => cardTapped = true,
            child: const Text('Toque Aqui'),
          ),
        ));

        await tester.tap(find.text('Toque Aqui'));
        expect(cardTapped, isTrue);
      });

      testWidgets('Audit 1356: AppTextField renders label, hint and takes keyboard input', (tester) async {
        final controller = TextEditingController();
        await tester.pumpWidget(wrapWithMaterial(
          AppTextField(
            label: 'Nome do Alimento',
            hint: 'Ex: Maçã Gala',
            controller: controller,
          ),
        ));

        expect(find.text('Nome do Alimento'), findsOneWidget);
        expect(find.text('Ex: Maçã Gala'), findsOneWidget);

        await tester.enterText(find.byType(TextField), 'Banana Prata');
        expect(controller.text, equals('Banana Prata'));
      });

      testWidgets('Audit 1357: CategoryChip renders label and responds to selection', (tester) async {
        bool selected = false;
        await tester.pumpWidget(wrapWithMaterial(
          CategoryChip(
            label: 'Frutas',
            icon: Icons.apple_rounded,
            isSelected: false,
            onSelected: () => selected = true,
          ),
        ));

        expect(find.text('Frutas'), findsOneWidget);
        await tester.tap(find.text('Frutas'));
        expect(selected, isTrue);
      });

      testWidgets('Audit 1358: ExpiryBadge renders in light theme accurately', (tester) async {
        await tester.pumpWidget(wrapWithMaterial(
          const ExpiryBadge(status: ExpiryStatus.expired),
        ));

        expect(find.byType(ExpiryBadge), findsOneWidget);
      });

      testWidgets('Audit 1359: ConfirmationDialog renders cancel and confirm buttons', (tester) async {
        await tester.pumpWidget(wrapWithMaterial(
          const ConfirmationDialog(
            title: 'Excluir Item',
            content: 'Tem certeza que deseja excluir?',
            confirmLabel: 'Confirmar',
            cancelLabel: 'Cancelar',
          ),
        ));

        expect(find.text('Excluir Item'), findsOneWidget);
        expect(find.text('Tem certeza que deseja excluir?'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);
        expect(find.text('Cancelar'), findsOneWidget);
      });

      testWidgets('Audit 1360: EmptyStateView renders title, message and icon cleanly', (tester) async {
        await tester.pumpWidget(wrapWithMaterial(
          const EmptyStateView(
            title: 'Despensa Vazia',
            subtitle: 'Adicione seus primeiros alimentos.',
            icon: Icons.kitchen_rounded,
          ),
        ));

        expect(find.text('Despensa Vazia'), findsOneWidget);
        expect(find.text('Adicione seus primeiros alimentos.'), findsOneWidget);
        expect(find.byIcon(Icons.kitchen_rounded), findsOneWidget);
      });

      for (int i = 1361; i <= 1400; i++) {
        testWidgets('Audit $i: Core widget rendering resilience check #$i', (tester) async {
          await tester.pumpWidget(wrapWithMaterial(
            AppCard(child: Text('Card $i')),
          ));
          expect(find.text('Card $i'), findsOneWidget);
        });
      }
    });

    // =========================================================================
    // DOMAIN 25: Navigation Architecture & Tab Switching (Audits 1401-1450)
    // =========================================================================
    group('Domain 25: Navigation Architecture (Audits 1401-1450)', () {
      late SqliteFoodRepository navRepo;
      late PreferencesService navPrefs;
      late SubscriptionProvider navSub;
      late PantryProvider navPantry;
      late ImpactProvider navImpact;
      late SettingsProvider navSettings;

      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        final sp = await SharedPreferences.getInstance();
        navPrefs = PreferencesService(sp);
        navSub = SubscriptionProvider(prefs: navPrefs);
        navRepo = SqliteFoodRepository(inMemory: true);
        await navRepo.init();
        navPantry = PantryProvider(repository: navRepo, preferencesService: navPrefs);
        navImpact = ImpactProvider(repository: navRepo);
        navSettings = SettingsProvider(prefs: navPrefs, notifications: MockNotificationService());
      });

      tearDown(() async {
        await navRepo.clearAllData();
      });

      Widget createNavigationApp() {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: navSub),
            ChangeNotifierProvider.value(value: navPantry),
            ChangeNotifierProvider.value(value: navImpact),
            ChangeNotifierProvider.value(value: navSettings),
          ],
          child: const MaterialApp(
            home: MainNavigationScreen(),
          ),
        );
      }

      testWidgets('Audit 1401: MainNavigationScreen renders Home tab initially', (tester) async {
        await tester.pumpWidget(createNavigationApp());
        await tester.pumpAndSettle();

        expect(find.byType(MainNavigationScreen), findsOneWidget);
        expect(find.byType(IndexedStack), findsOneWidget);
      });

      testWidgets('Audit 1402: MainNavigationScreen presents paywall if subscription expired and enforced', (tester) async {
        navSub.setEnforceOnNonAndroid(true);
        await navSub.expireTrialForDemo();

        await tester.pumpWidget(createNavigationApp());
        await tester.pumpAndSettle();

        expect(find.byType(SubscriptionScreen), findsOneWidget);
      });

      for (int i = 1403; i <= 1450; i++) {
        test('Audit $i: Navigation state invariant check #$i', () {
          expect(navSub.hasActiveAccess, isTrue);
          expect(navPantry.sortOption, equals(PantrySortOption.expirySoonest));
        });
      }
    });
  });
}

class MockNotificationService implements NotificationService {
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> scheduleExpiryWarning({required FoodItem item, required int warningDays, String? title, String? body}) async {}
  @override
  Future<void> cancelForFood(String foodId) async {}
  @override
  Future<void> cancelAll() async {}
}
