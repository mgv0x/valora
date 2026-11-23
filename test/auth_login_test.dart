import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valora/data/services/auth_service.dart';
import 'package:valora/data/services/notification_service.dart';
import 'package:valora/data/services/preferences_service.dart';
import 'package:valora/presentation/screens/auth/edit_profile_sheet.dart';
import 'package:valora/presentation/screens/auth/login_screen.dart';
import 'package:valora/state/settings_provider.dart';

class MockNotificationService implements NotificationService {
  @override
  Future<void> init() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> scheduleExpiryWarning({
    required dynamic item,
    required int warningDays,
    required String title,
    required String body,
  }) async {}
  @override
  Future<void> cancelForFood(String foodId) async {}
  @override
  Future<void> cancelAll() async {}
}

class FakeAuthService implements AuthService {
  String? registeredEmail;
  String? loggedInEmail;
  String? resetEmail;
  bool isSignedOut = false;

  @override
  AuthUser? currentUser;

  @override
  bool get isFirebaseAvailable => true;

  @override
  Stream<AuthUser?> get authStateChanges => const Stream.empty();

  @override
  Future<AuthUser?> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    registeredEmail = email;
    currentUser = AuthUser(uid: 'fake-uid-1', email: email, displayName: name);
    return currentUser;
  }

  @override
  Future<AuthUser?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    loggedInEmail = email;
    currentUser = AuthUser(uid: 'fake-uid-1', email: email, displayName: 'Julia Lima');
    return currentUser;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    resetEmail = email;
  }

  @override
  Future<void> signOut() async {
    isSignedOut = true;
    currentUser = null;
  }
}


void main() {
  group('Auth & User Profile State Tests', () {
    late PreferencesService prefs;
    late SettingsProvider settings;
    late MockNotificationService notifications;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await PreferencesService.create();
      notifications = MockNotificationService();
      settings = SettingsProvider(prefs: prefs, notifications: notifications);
    });

    test('Initial user state requires login with empty credentials', () {
      expect(settings.userName, isEmpty);
      expect(settings.userEmail, isEmpty);
      expect(settings.userFirstName, equals('Amigo'));
      expect(settings.userInitials, equals('V'));
      expect(settings.isLoggedIn, isFalse);
    });

    test('Login updates user name, email, and session', () async {
      await settings.login(
        email: 'marcus@email.com',
        password: 'password123',
        name: 'Marcus Silva',
      );

      expect(settings.userName, equals('Marcus Silva'));
      expect(settings.userEmail, equals('marcus@email.com'));
      expect(settings.userFirstName, equals('Marcus'));
      expect(settings.userInitials, equals('MS'));
      expect(settings.isLoggedIn, isTrue);

      // Verify persistence
      expect(prefs.userName, equals('Marcus Silva'));
      expect(prefs.userEmail, equals('marcus@email.com'));
      expect(prefs.isLoggedIn, isTrue);
    });

    test('Login infers user display name when name is omitted', () async {
      await settings.login(
        email: 'lucas.oliveira@email.com',
        password: 'password123',
      );

      expect(settings.userName, equals('Lucas Oliveira'));
      expect(settings.userFirstName, equals('Lucas'));
      expect(settings.userInitials, equals('LO'));
    });

    test('Register sets new user credentials and logs in', () async {
      await settings.register(
        name: 'Beatriz Costa',
        email: 'beatriz@email.com',
        password: 'secretPassword',
      );

      expect(settings.userName, equals('Beatriz Costa'));
      expect(settings.userEmail, equals('beatriz@email.com'));
      expect(settings.userFirstName, equals('Beatriz'));
      expect(settings.userInitials, equals('BC'));
      expect(settings.isLoggedIn, isTrue);
    });

    test('Update profile changes name and email without resetting session', () async {
      await settings.updateProfile(
        name: 'Carlos Eduardo',
        email: 'carlos@novoemail.com',
      );

      expect(settings.userName, equals('Carlos Eduardo'));
      expect(settings.userEmail, equals('carlos@novoemail.com'));
      expect(settings.userFirstName, equals('Carlos'));
      expect(settings.userInitials, equals('CE'));
      expect(prefs.userName, equals('Carlos Eduardo'));
    });

    test('Logout clears logged in status', () async {
      await settings.logout();
      expect(settings.isLoggedIn, isFalse);
      expect(prefs.isLoggedIn, isFalse);
    });

    test('Continue as guest sets guest profile', () async {
      await settings.continueAsGuest();
      expect(settings.userName, equals('Convidado'));
      expect(settings.userFirstName, equals('Convidado'));
      expect(settings.userEmail, equals('convidado@valora.app'));
      expect(settings.isLoggedIn, isTrue);
    });

    test('SettingsProvider delegates to AuthService when available', () async {
      final mockAuth = FakeAuthService();
      final customSettings = SettingsProvider(
        prefs: prefs,
        notifications: notifications,
        authService: mockAuth,
      );

      await customSettings.register(
        name: 'Julia Lima',
        email: 'julia@firebase.com',
        password: 'password123',
      );
      expect(mockAuth.registeredEmail, equals('julia@firebase.com'));
      expect(customSettings.userName, equals('Julia Lima'));

      await customSettings.login(
        email: 'julia@firebase.com',
        password: 'password123',
      );
      expect(mockAuth.loggedInEmail, equals('julia@firebase.com'));

      await customSettings.sendPasswordResetEmail('julia@firebase.com');
      expect(mockAuth.resetEmail, equals('julia@firebase.com'));

      await customSettings.logout();
      expect(mockAuth.isSignedOut, isTrue);
    });
  });

  group('LoginScreen Widget Tests', () {
    late PreferencesService prefs;
    late SettingsProvider settings;
    late MockNotificationService notifications;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await PreferencesService.create();
      notifications = MockNotificationService();
      settings = SettingsProvider(prefs: prefs, notifications: notifications);
    });

    Widget createTestApp({required Widget home}) {
      return ChangeNotifierProvider<SettingsProvider>.value(
        value: settings,
        child: MaterialApp(
          home: home,
        ),
      );
    }

    testWidgets('Renders Valora branding, tabs, and form elements without demo or guest buttons', (tester) async {
      await tester.pumpWidget(createTestApp(home: const LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Valora'), findsOneWidget);
      expect(find.text('Entrar'), findsWidgets);
      expect(find.text('Criar Conta'), findsOneWidget);
      expect(find.text('Entrar como Helena Silva (Demonstração)'), findsNothing);
      expect(find.text('Continuar como Convidado (Modo Offline)'), findsNothing);
    });

    testWidgets('LoginScreen in mandatory mode disables back button navigation', (tester) async {
      await tester.pumpWidget(createTestApp(home: const LoginScreen(isMandatory: true)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('Switching to Criar Conta tab displays registration fields', (tester) async {
      await tester.pumpWidget(createTestApp(home: const LoginScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Criar Conta'));
      await tester.pumpAndSettle();

      expect(find.text('Seu Nome'), findsOneWidget);
      expect(find.text('Confirmar Senha'), findsOneWidget);
      expect(find.text('Criar Minha Conta'), findsOneWidget);
    });

    testWidgets('EditProfileSheet saves updated user name', (tester) async {
      await settings.login(
        email: 'helena@email.com',
        password: 'password123',
        name: 'Helena Silva',
      );
      await tester.pumpWidget(
        createTestApp(
          home: const Scaffold(body: EditProfileSheet()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Editar Perfil'), findsOneWidget);
      expect(find.text('Helena Silva'), findsOneWidget);

      final nameField = find.widgetWithText(TextFormField, 'Helena Silva');
      await tester.enterText(nameField, 'Marcus Vinicius');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar Alterações'));
      await tester.pumpAndSettle();

      expect(settings.userName, equals('Marcus Vinicius'));
      expect(settings.userFirstName, equals('Marcus'));
    });
  });
}
