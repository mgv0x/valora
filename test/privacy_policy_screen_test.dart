import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valora/data/local/food_repository.dart';
import 'package:valora/data/services/preferences_service.dart';
import 'package:valora/l10n/generated/app_localizations.dart';
import 'package:valora/presentation/screens/settings/privacy_policy_screen.dart';
import 'package:valora/presentation/screens/settings/settings_screen.dart';
import 'package:valora/state/impact_provider.dart';
import 'package:valora/state/pantry_provider.dart';
import 'package:valora/state/settings_provider.dart';
import 'package:valora/state/subscription_provider.dart';

import 'mocks/in_memory_food_repository.dart';
import 'session4_settings_notifications_release_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late InMemoryFoodRepository mockRepo;
  late PreferencesService prefs;
  late MockNotificationService mockNotifications;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await PreferencesService.create();
    mockNotifications = MockNotificationService();
    mockRepo = InMemoryFoodRepository();
  });

  Widget buildTestApp({Widget? home}) {
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
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: home ?? const PrivacyPolicyScreen(),
      ),
    );
  }

  group('PrivacyPolicyScreen Widget & LGPD Tests', () {
    testWidgets('Renders PrivacyPolicyScreen with all required LGPD badges and highlights', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Title & Hero
      expect(find.text('Política de Privacidade'), findsOneWidget);
      expect(find.text('LGPD & GDPR Compliant'), findsOneWidget);
      expect(find.text('Transparência e Soberania Total sobre seus Dados'), findsOneWidget);

      // Highlights
      expect(find.text('Offline-First'), findsOneWidget);
      expect(find.text('Zero Ads'), findsOneWidget);
      expect(find.text('Segurança'), findsOneWidget);
      expect(find.text('Portabilidade'), findsOneWidget);

      // Sections
      expect(find.text('1. Princípios Fundamentais'), findsOneWidget);
      expect(find.text('2. Dados Tratados: Modo Local vs. Nuvem'), findsOneWidget);
      expect(find.text('3. Bases Legais (LGPD Art. 7º)'), findsOneWidget);
      expect(find.text('4. Permissões Solicitadas'), findsOneWidget);

      // Scroll down
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('5. Compartilhamento Técnico'), findsOneWidget);
      expect(find.text('6. Segurança e Proteção'), findsOneWidget);
      expect(find.text('7. Seus Direitos (LGPD Artigo 18)'), findsOneWidget);
      expect(find.text('8. Menores de Idade'), findsOneWidget);

      // Portability Button & DPO Contact
      expect(find.text('Exercer Direito de Portabilidade'), findsOneWidget);
      expect(find.text('Visualizar e Exportar JSON'), findsOneWidget);
      expect(find.text('marcussgollub@gmail.com'), findsOneWidget);
    });

    testWidgets('Tapping Portability button displays JSON export dialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Scroll to portability button
      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Visualizar e Exportar JSON'));
      await tester.pumpAndSettle();

      expect(find.text('Portabilidade LGPD (JSON)'), findsOneWidget);
      expect(find.text('Copiar JSON'), findsOneWidget);
      expect(find.text('Fechar'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Fechar'));
      await tester.pumpAndSettle();
      expect(find.text('Portabilidade LGPD (JSON)'), findsNothing);
    });

    testWidgets('Navigation from SettingsScreen to PrivacyPolicyScreen works seamlessly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildTestApp(home: const SettingsScreen()));
      await tester.pumpAndSettle();

      // Scroll down to SOBRE O APLICATIVO
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      expect(find.text('Política de Privacidade'), findsOneWidget);
      expect(find.text('Conformidade LGPD, modelo offline e segurança'), findsOneWidget);

      // Tap on Política de Privacidade
      await tester.tap(find.text('Política de Privacidade'));
      await tester.pumpAndSettle();

      // Privacy Policy screen should be open
      expect(find.text('Transparência e Soberania Total sobre seus Dados'), findsOneWidget);
      expect(find.text('LGPD & GDPR Compliant'), findsOneWidget);

      // Back navigation
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Back to settings
      expect(find.text('Configurações'), findsOneWidget);
    });
  });
}
