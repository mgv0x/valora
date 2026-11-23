import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:valora/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'data/local/food_repository.dart';
import 'data/local/in_memory_food_repository.dart';
import 'data/local/sqlite_food_repository.dart';
import 'data/services/auth_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/preferences_service.dart';
import 'presentation/navigation/main_navigation_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/subscription/subscription_screen.dart';
import 'state/impact_provider.dart';
import 'state/pantry_provider.dart';
import 'state/settings_provider.dart';
import 'state/shopping_list_provider.dart';
import 'state/subscription_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  try {
    await Firebase.initializeApp();
    FirebaseAuthService.markFirebaseInitialized();
  } catch (e) {
    debugPrint('Firebase initialization deferred or offline: $e');
  }

  final preferencesService = await PreferencesService.create();
  final notificationService = LocalNotificationServiceImpl();
  await notificationService.init();

  final FoodRepository repository =
      kIsWeb ? InMemoryFoodRepository() : SqliteFoodRepository();
  await repository.init();

  runApp(
    ValoraApp(
      preferencesService: preferencesService,
      notificationService: notificationService,
      repository: repository,
    ),
  );
}

class ValoraApp extends StatelessWidget {
  final PreferencesService preferencesService;
  final NotificationService notificationService;
  final FoodRepository repository;

  const ValoraApp({
    super.key,
    required this.preferencesService,
    required this.notificationService,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FoodRepository>.value(value: repository),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(
            prefs: preferencesService,
            notifications: notificationService,
          ),
        ),
        ChangeNotifierProvider<SubscriptionProvider>(
          create: (_) => SubscriptionProvider(prefs: preferencesService),
        ),
        ChangeNotifierProvider<PantryProvider>(
          create: (ctx) {
            final provider = PantryProvider(
              repository: repository,
              notificationService: notificationService,
              preferencesService: preferencesService,
            );
            provider.loadItems();
            return provider;
          },
        ),
        ChangeNotifierProvider<ImpactProvider>(
          create: (_) {
            final provider = ImpactProvider(repository: repository);
            provider.loadActivities();
            return provider;
          },
        ),
        ChangeNotifierProvider<ShoppingListProvider>(
          create: (_) => ShoppingListProvider(prefs: preferencesService),
        ),
      ],
      child: Consumer2<SettingsProvider, SubscriptionProvider>(
        builder: (context, settings, subscription, _) {
          final Widget initialScreen;
          if (!settings.isLoggedIn) {
            initialScreen = const LoginScreen(isMandatory: true);
          } else if (!subscription.hasAcceptedTrial) {
            // Paywall obrigatório na primeira inicialização após instalar
            initialScreen = const SubscriptionScreen(isFirstLaunch: true);
          } else if (!subscription.hasActiveAccess) {
            // Período de teste encerrado e sem assinatura ativa
            initialScreen = const SubscriptionScreen(isFirstLaunch: true);
          } else {
            initialScreen = const MainNavigationScreen();
          }

          return MaterialApp(
            title: 'Valora',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            locale: settings.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: initialScreen,
          );
        },
      ),
    );
  }
}
