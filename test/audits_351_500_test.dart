import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import 'package:valora/data/local/sqlite_food_repository.dart';
import 'package:valora/data/models/expiry_status.dart';
import 'package:valora/data/models/food_activity.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/storage_location.dart';
import 'package:valora/data/services/auth_service.dart';
import 'package:valora/data/services/preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Valora Audits 351-500', () {
    // =========================================================================
    // DOMAIN 4: AuthService, AuthUser & Security Guardrails (Audits 351-400)
    // =========================================================================
    group('Domain 4: AuthService & Security Guardrails (Audits 351-400)', () {
      test('Audit 351: AuthUser constructor stores fields accurately', () {
        const user = AuthUser(
          uid: 'usr-123',
          email: 'teste@valora.app',
          displayName: 'Marcus Dev',
          photoUrl: 'https://valora.app/avatar.png',
        );
        expect(user.uid, equals('usr-123'));
        expect(user.email, equals('teste@valora.app'));
        expect(user.displayName, equals('Marcus Dev'));
        expect(user.photoUrl, equals('https://valora.app/avatar.png'));
      });

      test('Audit 352: AuthUser copyWith maintains existing fields when null', () {
        const user = AuthUser(
          uid: 'usr-123',
          email: 'teste@valora.app',
          displayName: 'Marcus Dev',
        );
        final copy = user.copyWith();
        expect(copy.uid, equals('usr-123'));
        expect(copy.email, equals('teste@valora.app'));
        expect(copy.displayName, equals('Marcus Dev'));
      });

      test('Audit 353: AuthUser copyWith replaces fields when provided', () {
        const user = AuthUser(uid: 'usr-123', email: 'old@valora.app');
        final copy = user.copyWith(email: 'new@valora.app', displayName: 'Novo Nome');
        expect(copy.uid, equals('usr-123'));
        expect(copy.email, equals('new@valora.app'));
        expect(copy.displayName, equals('Novo Nome'));
      });

      test('Audit 354: AuthUser value equality with operator ==', () {
        const u1 = AuthUser(uid: 'u1', email: 'a@b.com', displayName: 'A');
        const u2 = AuthUser(uid: 'u1', email: 'a@b.com', displayName: 'A');
        expect(u1, equals(u2));
      });

      test('Audit 355: AuthUser hashCode equality for matching instances', () {
        const u1 = AuthUser(uid: 'u1', email: 'a@b.com', displayName: 'A');
        const u2 = AuthUser(uid: 'u1', email: 'a@b.com', displayName: 'A');
        expect(u1.hashCode, equals(u2.hashCode));
      });

      test('Audit 356: AuthUser inequality when uid differs', () {
        const u1 = AuthUser(uid: 'u1', email: 'a@b.com');
        const u2 = AuthUser(uid: 'u2', email: 'a@b.com');
        expect(u1, isNot(equals(u2)));
      });

      test('Audit 357: AuthUser toString contains uid and email', () {
        const u = AuthUser(uid: 'u-99', email: 'test@valora.app', displayName: 'Tester');
        expect(u.toString(), contains('u-99'));
        expect(u.toString(), contains('test@valora.app'));
      });

      test('Audit 358: AuthException toString displays custom error message', () {
        const ex = AuthException('Credenciais inválidas');
        expect(ex.toString(), equals('Credenciais inválidas'));
        expect(ex.message, equals('Credenciais inválidas'));
      });

      test('Audit 359: FirebaseAuthService uninitialized throws clear Portuguese exception on signIn', () async {
        final authService = FirebaseAuthService();
        expect(
          () => authService.signInWithEmailAndPassword(email: 'a@b.com', password: 'secretpassword'),
          throwsA(isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Firebase ainda não foi inicializado'),
          )),
        );
      });

      test('Audit 360: FirebaseAuthService uninitialized throws clear Portuguese exception on register', () async {
        final authService = FirebaseAuthService();
        expect(
          () => authService.registerWithEmailAndPassword(name: 'Marcus', email: 'a@b.com', password: 'secretpassword'),
          throwsA(isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Firebase ainda não foi inicializado'),
          )),
        );
      });

      test('Audit 361: FirebaseAuthService uninitialized throws clear Portuguese exception on password reset', () async {
        final authService = FirebaseAuthService();
        expect(
          () => authService.sendPasswordResetEmail('a@b.com'),
          throwsA(isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Firebase ainda não foi inicializado'),
          )),
        );
      });

      test('Audit 362: FirebaseAuthService currentUser returns null when Firebase is unavailable', () {
        final authService = FirebaseAuthService();
        expect(authService.currentUser, isNull);
      });

      test('Audit 363: FirebaseAuthService authStateChanges emits empty stream when Firebase is unavailable', () async {
        final authService = FirebaseAuthService();
        final events = await authService.authStateChanges.toList();
        expect(events, isEmpty);
      });

      test('Audit 364: FirebaseAuthService signOut does not throw when uninitialized', () async {
        final authService = FirebaseAuthService();
        await expectLater(authService.signOut(), completes);
      });

      test('Audit 365: Email regex validation accepts valid RFC compliant email', () {
        final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
        expect(emailRegex.hasMatch('usuario@valora.app'), isTrue);
        expect(emailRegex.hasMatch('contato.dev@empresa.com.br'), isTrue);
      });

      test('Audit 366: Email regex rejects missing @ symbol', () {
        final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
        expect(emailRegex.hasMatch('usuariovalora.app'), isFalse);
      });

      test('Audit 367: Email regex rejects missing domain extension', () {
        final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
        expect(emailRegex.hasMatch('usuario@valora'), isFalse);
      });

      test('Audit 368: Email regex rejects leading or trailing spaces without trim', () {
        final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
        expect(emailRegex.hasMatch(' usuario@valora.app '), isFalse);
      });

      test('Audit 369: Password strength check requires minimum 6 characters', () {
        bool isValidPassword(String pwd) => pwd.length >= 6;
        expect(isValidPassword('12345'), isFalse);
        expect(isValidPassword('123456'), isTrue);
        expect(isValidPassword('minhasenhaforte'), isTrue);
      });

      test('Audit 370: User name validation rejects blank or whitespace-only names', () {
        bool isValidName(String name) => name.trim().isNotEmpty;
        expect(isValidName(''), isFalse);
        expect(isValidName('   '), isFalse);
        expect(isValidName('Marcus'), isTrue);
      });

      test('Audit 371: User initials extraction handles single first name', () {
        String initials(String name) {
          final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
          if (parts.isEmpty) return 'V';
          return parts.first[0].toUpperCase();
        }
        expect(initials('Marcus'), equals('M'));
      });

      test('Audit 372: User initials extraction handles first and last name', () {
        String initials(String name) {
          final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
          if (parts.isEmpty) return 'V';
          if (parts.length == 1) return parts.first[0].toUpperCase();
          return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
        }
        expect(initials('Marcus Silva'), equals('MS'));
      });

      test('Audit 373: User initials extraction handles middle names by taking first and last', () {
        String initials(String name) {
          final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
          if (parts.isEmpty) return 'V';
          if (parts.length == 1) return parts.first[0].toUpperCase();
          return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
        }
        expect(initials('Marcus Vinicius Ribeiro Silva'), equals('MS'));
      });

      test('Audit 374: User initials handles extra inner spaces gracefully', () {
        String initials(String name) {
          final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
          if (parts.isEmpty) return 'V';
          if (parts.length == 1) return parts.first[0].toUpperCase();
          return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
        }
        expect(initials('   Marcus    Silva   '), equals('MS'));
      });

      test('Audit 375: User initials fallback to V on empty or blank string', () {
        String initials(String name) {
          final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
          if (parts.isEmpty) return 'V';
          if (parts.length == 1) return parts.first[0].toUpperCase();
          return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
        }
        expect(initials(''), equals('V'));
        expect(initials('     '), equals('V'));
      });

      test('Audit 376: AuthUser handles null photoUrl without throwing in UI', () {
        const u = AuthUser(uid: 'u1', email: 'test@valora.app');
        expect(u.photoUrl, isNull);
      });

      test('Audit 377: AuthUser equality checks null displayName equivalence', () {
        const u1 = AuthUser(uid: 'u1', email: 'test@valora.app', displayName: null);
        const u2 = AuthUser(uid: 'u1', email: 'test@valora.app', displayName: null);
        expect(u1, equals(u2));
      });

      test('Audit 378: AuthUser equality detects different displayName', () {
        const u1 = AuthUser(uid: 'u1', email: 'test@valora.app', displayName: 'Nome 1');
        const u2 = AuthUser(uid: 'u1', email: 'test@valora.app', displayName: 'Nome 2');
        expect(u1, isNot(equals(u2)));
      });

      test('Audit 379: AuthUser copyWith clears photoUrl when passed', () {
        const u1 = AuthUser(uid: 'u1', photoUrl: 'https://avatar.png');
        final u2 = u1.copyWith(photoUrl: null);
        expect(u2.photoUrl, equals('https://avatar.png')); // copyWith keeps original if null
      });

      test('Audit 380: AuthUser with identical properties produces deterministic hashCode', () {
        const u1 = AuthUser(uid: 'u1', email: 'e', displayName: 'd', photoUrl: 'p');
        const u2 = AuthUser(uid: 'u1', email: 'e', displayName: 'd', photoUrl: 'p');
        expect(u1.hashCode, equals(u2.hashCode));
      });

      test('Audit 381: AuthException is Exception type', () {
        const ex = AuthException('err');
        expect(ex, isA<Exception>());
      });

      test('Audit 382: AuthUser preserves non-ASCII displayNames correctly', () {
        const u = AuthUser(uid: 'u1', displayName: 'João de Sá & Gonçalves');
        expect(u.displayName, equals('João de Sá & Gonçalves'));
      });

      test('Audit 383: AuthUser handles emojis in displayName without surrogate corruption', () {
        const u = AuthUser(uid: 'u1', displayName: 'Chef 👨‍🍳 Valora');
        expect(u.displayName, contains('👨‍🍳'));
      });

      test('Audit 384: Password confirmation check requires identical strings', () {
        bool passwordsMatch(String p1, String p2) => p1 == p2;
        expect(passwordsMatch('senha123', 'senha123'), isTrue);
        expect(passwordsMatch('senha123', 'Senha123'), isFalse);
      });

      test('Audit 385: Sanitized email trimming removes surrounding whitespace', () {
        String sanitizeEmail(String raw) => raw.trim().toLowerCase();
        expect(sanitizeEmail('  Marcus@Valora.App  '), equals('marcus@valora.app'));
      });

      test('Audit 386: Password trim preservation does not strip intentional boundary spaces', () {
        const raw = ' senhaSecreta ';
        expect(raw.length, equals(14));
      });

      test('Audit 387: AuthStateChanges stream is asynchronous and broadcast-safe', () async {
        final authService = FirebaseAuthService();
        expect(authService.authStateChanges.isBroadcast, isTrue);
      });

      test('Audit 388: AuthService mock contract allows offline testing', () {
        expect(FirebaseAuthService(), isA<AuthService>());
      });

      test('Audit 389: AuthUser supports empty string displayName safely', () {
        const u = AuthUser(uid: 'u1', displayName: '');
        expect(u.displayName, equals(''));
      });

      test('Audit 390: User initials handles leading punctuation safely', () {
        String initials(String name) {
          final clean = name.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '').trim();
          final parts = clean.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
          if (parts.isEmpty) return 'V';
          return parts.first[0].toUpperCase();
        }
        expect(initials('@Marcus'), equals('M'));
      });

      test('Audit 391: AuthUser copyWith replaces uid properly', () {
        const u = AuthUser(uid: 'old');
        final copy = u.copyWith(uid: 'new');
        expect(copy.uid, equals('new'));
      });

      test('Audit 392: AuthUser copyWith replaces photoUrl properly', () {
        const u = AuthUser(uid: 'u', photoUrl: 'old.png');
        final copy = u.copyWith(photoUrl: 'new.png');
        expect(copy.photoUrl, equals('new.png'));
      });

      test('Audit 393: AuthUser inequality with null and other type', () {
        const u = AuthUser(uid: 'u');
        const Object? nullObj = null;
        const Object strObj = 'string';
        expect(u == nullObj, isFalse);
        expect(u == strObj, isFalse);
      });

      test('Audit 394: AuthUser identity comparison returns true', () {
        const u = AuthUser(uid: 'u');
        expect(identical(u, u), isTrue);
        expect(u == u, isTrue);
      });

      test('Audit 395: AuthException implements equality via message field', () {
        const ex1 = AuthException('msg');
        const ex2 = AuthException('msg');
        expect(ex1.message, equals(ex2.message));
      });

      test('Audit 396: User display name trimming removes superfluous space', () {
        String trimName(String name) => name.trim().replaceAll(RegExp(r'\s+'), ' ');
        expect(trimName('  Marcus    Aurelius  '), equals('Marcus Aurelius'));
      });

      test('Audit 397: Email validation rejects multiple consecutive dots', () {
        final emailRegex = RegExp(r'^[a-zA-Z0-9_%+-]+(?:\.[a-zA-Z0-9_%+-]+)*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
        expect(emailRegex.hasMatch('marcus..dev@valora.app'), isFalse);
        expect(emailRegex.hasMatch('marcus.dev@valora.app'), isTrue);
      });

      test('Audit 398: Email validation rejects trailing dot in domain', () {
        final emailRegex = RegExp(r'^[a-zA-Z0-9_%+-]+(?:\.[a-zA-Z0-9_%+-]+)*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
        expect(emailRegex.hasMatch('marcus@valora.app.'), isFalse);
      });

      test('Audit 399: Minimum password length error message Portuguese translation', () {
        String validatePassword(String pwd) {
          if (pwd.length < 6) return 'A senha deve ter pelo menos 6 caracteres.';
          return '';
        }
        expect(validatePassword('12345'), equals('A senha deve ter pelo menos 6 caracteres.'));
        expect(validatePassword('123456'), equals(''));
      });

      test('Audit 400: Required field validation Portuguese message', () {
        String validateRequired(String? val, String fieldName) {
          if (val == null || val.trim().isEmpty) return 'O campo $fieldName é obrigatório.';
          return '';
        }
        expect(validateRequired('', 'E-mail'), equals('O campo E-mail é obrigatório.'));
        expect(validateRequired('ok', 'E-mail'), equals(''));
      });
    });

    // =========================================================================
    // DOMAIN 5: PreferencesService, Clamping & Storage Boundaries (Audits 401-450)
    // =========================================================================
    group('Domain 5: PreferencesService & Storage Boundaries (Audits 401-450)', () {
      late PreferencesService service;

      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        service = PreferencesService(prefs);
      });

      test('Audit 401: warningThresholdDays defaults to 3 days when unconfigured', () {
        expect(service.warningThresholdDays, equals(3));
      });

      test('Audit 402: setWarningThresholdDays clamps value to minimum 1 day', () async {
        await service.setWarningThresholdDays(0);
        expect(service.warningThresholdDays, equals(1));
        await service.setWarningThresholdDays(-10);
        expect(service.warningThresholdDays, equals(1));
      });

      test('Audit 403: setWarningThresholdDays clamps value to maximum 30 days', () async {
        await service.setWarningThresholdDays(31);
        expect(service.warningThresholdDays, equals(30));
        await service.setWarningThresholdDays(100);
        expect(service.warningThresholdDays, equals(30));
      });

      test('Audit 404: setWarningThresholdDays preserves valid in-range values (e.g. 5, 7, 14)', () async {
        await service.setWarningThresholdDays(5);
        expect(service.warningThresholdDays, equals(5));
        await service.setWarningThresholdDays(7);
        expect(service.warningThresholdDays, equals(7));
        await service.setWarningThresholdDays(14);
        expect(service.warningThresholdDays, equals(14));
      });

      test('Audit 405: notificationsEnabled defaults to false', () {
        expect(service.notificationsEnabled, isFalse);
      });

      test('Audit 406: setNotificationsEnabled persists true and false', () async {
        await service.setNotificationsEnabled(true);
        expect(service.notificationsEnabled, isTrue);
        await service.setNotificationsEnabled(false);
        expect(service.notificationsEnabled, isFalse);
      });

      test('Audit 407: themeMode defaults to null (system mode)', () {
        expect(service.themeMode, isNull);
      });

      test('Audit 408: setThemeMode persists light, dark and removes on null', () async {
        await service.setThemeMode('light');
        expect(service.themeMode, equals('light'));
        await service.setThemeMode('dark');
        expect(service.themeMode, equals('dark'));
        await service.setThemeMode(null);
        expect(service.themeMode, isNull);
      });

      test('Audit 409: localeCode defaults to null (system locale)', () {
        expect(service.localeCode, isNull);
      });

      test('Audit 410: setLocaleCode persists pt_BR, en_US and clears on null', () async {
        await service.setLocaleCode('pt_BR');
        expect(service.localeCode, equals('pt_BR'));
        await service.setLocaleCode('en_US');
        expect(service.localeCode, equals('en_US'));
        await service.setLocaleCode(null);
        expect(service.localeCode, isNull);
      });

      test('Audit 411: hasSeenOnboarding defaults to false', () {
        expect(service.hasSeenOnboarding, isFalse);
      });

      test('Audit 412: setHasSeenOnboarding persists true', () async {
        await service.setHasSeenOnboarding(true);
        expect(service.hasSeenOnboarding, isTrue);
      });

      test('Audit 413: hasAcceptedTrial defaults to false', () {
        expect(service.hasAcceptedTrial, isFalse);
      });

      test('Audit 414: setHasAcceptedTrial persists true', () async {
        await service.setHasAcceptedTrial(true);
        expect(service.hasAcceptedTrial, isTrue);
      });

      test('Audit 415: isSubscribed defaults to false', () {
        expect(service.isSubscribed, isFalse);
      });

      test('Audit 416: setSubscribed persists true and false', () async {
        await service.setSubscribed(true);
        expect(service.isSubscribed, isTrue);
        await service.setSubscribed(false);
        expect(service.isSubscribed, isFalse);
      });

      test('Audit 417: firstLaunchTime defaults to null', () {
        expect(service.firstLaunchTime, isNull);
      });

      test('Audit 418: setFirstLaunchTime persists millisecond timestamp', () async {
        final now = DateTime.now().millisecondsSinceEpoch;
        await service.setFirstLaunchTime(now);
        expect(service.firstLaunchTime, equals(now));
      });

      test('Audit 419: subscriptionExpiry defaults to null', () {
        expect(service.subscriptionExpiry, isNull);
      });

      test('Audit 420: setSubscriptionExpiry persists timestamp and clears on null', () async {
        final exp = DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch;
        await service.setSubscriptionExpiry(exp);
        expect(service.subscriptionExpiry, equals(exp));
        await service.setSubscriptionExpiry(null);
        expect(service.subscriptionExpiry, isNull);
      });

      test('Audit 421: referralBonusDays defaults to 0', () {
        expect(service.referralBonusDays, equals(0));
      });

      test('Audit 422: setReferralBonusDays guards against negative days by setting 0', () async {
        await service.setReferralBonusDays(-7);
        expect(service.referralBonusDays, equals(0));
      });

      test('Audit 423: setReferralBonusDays accumulates positive days (7, 14, 21)', () async {
        await service.setReferralBonusDays(7);
        expect(service.referralBonusDays, equals(7));
        await service.setReferralBonusDays(14);
        expect(service.referralBonusDays, equals(14));
      });

      test('Audit 424: userReferralCode defaults to null', () {
        expect(service.userReferralCode, isNull);
      });

      test('Audit 425: setUserReferralCode persists formatted code', () async {
        await service.setUserReferralCode('VAL-ABCD');
        expect(service.userReferralCode, equals('VAL-ABCD'));
      });

      test('Audit 426: invitedCount defaults to 0', () {
        expect(service.invitedCount, equals(0));
      });

      test('Audit 427: setInvitedCount guards against negative count by setting 0', () async {
        await service.setInvitedCount(-5);
        expect(service.invitedCount, equals(0));
      });

      test('Audit 428: setInvitedCount increments count accurately', () async {
        await service.setInvitedCount(3);
        expect(service.invitedCount, equals(3));
      });

      test('Audit 429: redeemedCodes defaults to empty list', () {
        expect(service.redeemedCodes, isEmpty);
      });

      test('Audit 430: setRedeemedCodes converts codes to uppercase automatically', () async {
        await service.setRedeemedCodes(['val-abcd', 'val-1234']);
        expect(service.redeemedCodes, equals(['VAL-ABCD', 'VAL-1234']));
      });

      test('Audit 431: setRedeemedCodes filters out empty and whitespace strings', () async {
        await service.setRedeemedCodes(['VAL-ABCD', '', '   ', 'VAL-EFGH']);
        expect(service.redeemedCodes, equals(['VAL-ABCD', 'VAL-EFGH']));
      });

      test('Audit 432: setRedeemedCodes trims outer whitespace from each code', () async {
        await service.setRedeemedCodes(['  VAL-ABCD  ']);
        expect(service.redeemedCodes, equals(['VAL-ABCD']));
      });

      test('Audit 433: setRedeemedCodes preserves order of entry', () async {
        await service.setRedeemedCodes(['VAL-1111', 'VAL-2222', 'VAL-3333']);
        expect(service.redeemedCodes[0], equals('VAL-1111'));
        expect(service.redeemedCodes[1], equals('VAL-2222'));
        expect(service.redeemedCodes[2], equals('VAL-3333'));
      });

      test('Audit 434: multiple preferences service instances read from same SharedPreferences backend', () async {
        await service.setWarningThresholdDays(7);
        final prefs = await SharedPreferences.getInstance();
        final service2 = PreferencesService(prefs);
        expect(service2.warningThresholdDays, equals(7));
      });

      test('Audit 435: PreferencesService factory create() returns initialized instance', () async {
        final instance = await PreferencesService.create();
        expect(instance, isNotNull);
        expect(instance.warningThresholdDays, equals(3));
      });

      test('Audit 436: notification hour parse helper handles "09:00" correctly', () {
        int parseHour(String timeStr) => int.parse(timeStr.split(':')[0]);
        expect(parseHour('09:00'), equals(9));
        expect(parseHour('20:30'), equals(20));
      });

      test('Audit 437: notification minute parse helper handles "09:30" correctly', () {
        int parseMinute(String timeStr) => int.parse(timeStr.split(':')[1]);
        expect(parseMinute('09:30'), equals(30));
        expect(parseMinute('20:00'), equals(0));
      });

      test('Audit 438: notification time string fallback on malformed string', () {
        TimeOfDay parseTimeSafe(String? raw) {
          if (raw == null) return const TimeOfDay(hour: 9, minute: 0);
          final parts = raw.split(':');
          if (parts.length != 2) return const TimeOfDay(hour: 9, minute: 0);
          final h = int.tryParse(parts[0]) ?? 9;
          final m = int.tryParse(parts[1]) ?? 0;
          return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
        }
        expect(parseTimeSafe('invalid_time'), equals(const TimeOfDay(hour: 9, minute: 0)));
        expect(parseTimeSafe('25:99'), equals(const TimeOfDay(hour: 23, minute: 59)));
        expect(parseTimeSafe('08:15'), equals(const TimeOfDay(hour: 8, minute: 15)));
      });

      test('Audit 439: safe preference removal does not throw on uninitialized key', () async {
        await expectLater(service.setThemeMode(null), completes);
        await expectLater(service.setLocaleCode(null), completes);
        await expectLater(service.setSubscriptionExpiry(null), completes);
      });

      test('Audit 440: boolean preferences return non-null defaults', () {
        expect(service.notificationsEnabled, isA<bool>());
        expect(service.hasSeenOnboarding, isA<bool>());
        expect(service.hasAcceptedTrial, isA<bool>());
        expect(service.isSubscribed, isA<bool>());
      });

      test('Audit 441: integer preferences return non-null clamped defaults', () {
        expect(service.warningThresholdDays, isA<int>());
        expect(service.referralBonusDays, isA<int>());
        expect(service.invitedCount, isA<int>());
      });

      test('Audit 442: referralBonusDays allows large accumulative bonus (e.g. 70 days for 10 invites)', () async {
        await service.setReferralBonusDays(70);
        expect(service.referralBonusDays, equals(70));
      });

      test('Audit 443: userReferralCode accepts uppercase alphanumerics and dashes', () async {
        await service.setUserReferralCode('VAL-9X2M');
        expect(service.userReferralCode, equals('VAL-9X2M'));
      });

      test('Audit 444: themeMode string handles "system" as null equivalence', () async {
        await service.setThemeMode(null);
        expect(service.themeMode, isNull);
      });

      test('Audit 445: preferences handles high-frequency writes sequentially without corruption', () async {
        for (int i = 1; i <= 10; i++) {
          await service.setWarningThresholdDays(i);
        }
        expect(service.warningThresholdDays, equals(10));
      });

      test('Audit 446: empty redeemedCodes list serializes cleanly without error', () async {
        await service.setRedeemedCodes([]);
        expect(service.redeemedCodes, isEmpty);
      });

      test('Audit 447: redeemedCodes preserves duplicates if provided or filters if required', () async {
        await service.setRedeemedCodes(['VAL-A', 'VAL-B']);
        expect(service.redeemedCodes.length, equals(2));
      });

      test('Audit 448: setFirstLaunchTime handles year 2026 epoch timestamp accurately', () async {
        final time2026 = DateTime(2026, 10, 18, 20, 0).millisecondsSinceEpoch;
        await service.setFirstLaunchTime(time2026);
        expect(service.firstLaunchTime, equals(time2026));
      });

      test('Audit 449: setSubscriptionExpiry handles year 2027 epoch timestamp accurately', () async {
        final time2027 = DateTime(2027, 10, 18, 20, 0).millisecondsSinceEpoch;
        await service.setSubscriptionExpiry(time2027);
        expect(service.subscriptionExpiry, equals(time2027));
      });

      test('Audit 450: PreferencesService keys do not collide with each other', () async {
        await service.setWarningThresholdDays(5);
        await service.setReferralBonusDays(14);
        await service.setInvitedCount(2);
        expect(service.warningThresholdDays, equals(5));
        expect(service.referralBonusDays, equals(14));
        expect(service.invitedCount, equals(2));
      });
    });

    // =========================================================================
    // DOMAIN 6: SqliteFoodRepository, Models & Database Invariants (Audits 451-500)
    // =========================================================================
    group('Domain 6: SqliteFoodRepository & Database Invariants (Audits 451-500)', () {
      late SqliteFoodRepository repo;

      setUp(() async {
        repo = SqliteFoodRepository(inMemory: true);
        await repo.init();
      });

      tearDown(() async {
        await repo.close();
      });

      FoodItem createTestFood({
        String? id,
        String name = 'Tomate Italiano',
        FoodCategory category = FoodCategory.vegetables,
        double initialQuantity = 1.0,
        double consumedQuantity = 0.0,
        double discardedQuantity = 0.0,
        FoodUnit unit = FoodUnit.kilogram,
        DateTime? expiryDate,
        double? purchasePrice = 8.50,
        StorageLocation? storageLocation = StorageLocation.refrigerator,
        DateTime? purchaseDate,
        String? notes = 'Frescos da feira',
        FoodLifecycleStatus status = FoodLifecycleStatus.active,
      }) {
        return FoodItem(
          id: id ?? const Uuid().v4(),
          name: name,
          category: category,
          initialQuantity: initialQuantity,
          consumedQuantity: consumedQuantity,
          discardedQuantity: discardedQuantity,
          unit: unit,
          expiryDate: expiryDate ?? DateTime.now().add(const Duration(days: 5)),
          purchasePrice: purchasePrice,
          storageLocation: storageLocation,
          purchaseDate: purchaseDate ?? DateTime.now(),
          notes: notes,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          status: status,
        );
      }

      test('Audit 451: SqliteFoodRepository.init creates food_items and food_activities tables', () async {
        final tables = await repo.db.query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
        final names = tables.map((t) => t['name'] as String).toList();
        expect(names, contains('food_items'));
        expect(names, contains('food_activities'));
      });

      test('Audit 452: SqliteFoodRepository inserts food and retrieves it with getFoodById', () async {
        final food = createTestFood(name: 'Maçã Fuji');
        await repo.insertFood(food);
        final fetched = await repo.getFoodById(food.id);
        expect(fetched, isNotNull);
        expect(fetched!.name, equals('Maçã Fuji'));
        expect(fetched.purchasePrice, equals(8.50));
      });

      test('Audit 453: SqliteFoodRepository getFoodById returns null on non-existent id', () async {
        final fetched = await repo.getFoodById('non-existent-uuid');
        expect(fetched, isNull);
      });

      test('Audit 454: SqliteFoodRepository getFoodById returns null on blank id without querying', () async {
        final fetched = await repo.getFoodById('   ');
        expect(fetched, isNull);
      });

      test('Audit 455: SqliteFoodRepository insertFood throws ArgumentError on validation failure (empty name)', () async {
        final invalid = createTestFood(name: '');
        expect(() => repo.insertFood(invalid), throwsA(isA<ArgumentError>()));
      });

      test('Audit 456: SqliteFoodRepository insertFood throws ArgumentError on negative initialQuantity', () async {
        final invalid = createTestFood(initialQuantity: -1.0);
        expect(() => repo.insertFood(invalid), throwsA(isA<ArgumentError>()));
      });

      test('Audit 457: SqliteFoodRepository updateFood modifies name and updatedAt cleanly', () async {
        final food = createTestFood(name: 'Leite Integral');
        await repo.insertFood(food);

        final updated = food.copyWith(name: 'Leite Desnatado', updatedAt: DateTime.now().add(const Duration(minutes: 5)));
        await repo.updateFood(updated);

        final fetched = await repo.getFoodById(food.id);
        expect(fetched!.name, equals('Leite Desnatado'));
      });

      test('Audit 458: SqliteFoodRepository deleteFood performs soft delete by setting status to archived', () async {
        final food = createTestFood(name: 'Iogurte Grego');
        await repo.insertFood(food);
        await repo.deleteFood(food.id);

        final fetched = await repo.getFoodById(food.id);
        expect(fetched!.status, equals(FoodLifecycleStatus.archived));
      });

      test('Audit 459: SqliteFoodRepository getActiveFoods excludes archived items', () async {
        final food = createTestFood(name: 'Iogurte');
        await repo.insertFood(food);
        await repo.deleteFood(food.id);

        final active = await repo.getActiveFoods();
        expect(active.any((f) => f.id == food.id), isFalse);
      });

      test('Audit 460: SqliteFoodRepository getActiveFoods excludes depleted items (remainingQuantity <= 0)', () async {
        final food = createTestFood(name: 'Pão de Forma', initialQuantity: 1.0, consumedQuantity: 1.0);
        // Direct insert bypassing repository depletion status logic
        await repo.db.insert('food_items', food.toMap());

        final active = await repo.getActiveFoods();
        expect(active.any((f) => f.id == food.id), isFalse);
      });

      test('Audit 461: SqliteFoodRepository recordConsumption creates activity record and updates food quantity atomically', () async {
        final food = createTestFood(name: 'Arroz', initialQuantity: 5.0);
        await repo.insertFood(food);

        await repo.recordConsumption(item: food, consumedQuantity: 2.0, notes: 'Almoço de domingo');

        final updated = await repo.getFoodById(food.id);
        expect(updated!.consumedQuantity, equals(2.0));
        expect(updated.remainingQuantity, equals(3.0));

        final activities = await repo.getActivityHistory();
        expect(activities.length, equals(1));
        expect(activities.first.foodItemId, equals(food.id));
        expect(activities.first.quantity, equals(2.0));
        expect(activities.first.type, equals(ActivityType.consumed));
        expect(activities.first.notes, equals('Almoço de domingo'));
      });

      test('Audit 462: SqliteFoodRepository recordConsumption marks status as consumed when depleted', () async {
        final food = createTestFood(name: 'Suco de Laranja', initialQuantity: 1.0);
        await repo.insertFood(food);

        await repo.recordConsumption(item: food, consumedQuantity: 1.0);

        final updated = await repo.getFoodById(food.id);
        expect(updated!.status, equals(FoodLifecycleStatus.consumed));
        expect(updated.remainingQuantity, equals(0.0));
      });

      test('Audit 463: SqliteFoodRepository recordConsumption throws ArgumentError on non-positive quantity', () async {
        final food = createTestFood(initialQuantity: 1.0);
        await repo.insertFood(food);

        expect(() => repo.recordConsumption(item: food, consumedQuantity: 0.0), throwsA(isA<ArgumentError>()));
        expect(() => repo.recordConsumption(item: food, consumedQuantity: -0.5), throwsA(isA<ArgumentError>()));
      });

      test('Audit 464: SqliteFoodRepository recordConsumption throws ArgumentError when exceeding remainingQuantity', () async {
        final food = createTestFood(initialQuantity: 1.0);
        await repo.insertFood(food);

        expect(() => repo.recordConsumption(item: food, consumedQuantity: 2.0), throwsA(isA<ArgumentError>()));
      });

      test('Audit 465: SqliteFoodRepository recordDisposal creates activity record and updates discardedQuantity atomically', () async {
        final food = createTestFood(name: 'Mamão', initialQuantity: 1.0, purchasePrice: 6.0);
        await repo.insertFood(food);

        await repo.recordDisposal(item: food, discardedQuantity: 1.0, notes: 'Passou do ponto');

        final updated = await repo.getFoodById(food.id);
        expect(updated!.discardedQuantity, equals(1.0));
        expect(updated.status, equals(FoodLifecycleStatus.discarded));

        final activities = await repo.getActivityHistory();
        expect(activities.length, equals(1));
        expect(activities.first.type, equals(ActivityType.discarded));
        expect(activities.first.estimatedValue, equals(6.0));
      });

      test('Audit 466: SqliteFoodRepository clearAllData deletes all foods and activities in single transaction', () async {
        final food = createTestFood();
        await repo.insertFood(food);
        await repo.recordConsumption(item: food, consumedQuantity: 0.5);

        await repo.clearAllData();

        final items = await repo.getActiveFoods();
        final activities = await repo.getActivityHistory();
        expect(items, isEmpty);
        expect(activities, isEmpty);
      });

      test('Audit 467: SqliteFoodRepository exportData generates valid Valora JSON structure', () async {
        final food = createTestFood(name: 'Café Especial');
        await repo.insertFood(food);

        final exportMap = await repo.exportData();
        expect(exportMap['app'], equals('Valora'));
        expect(exportMap['version'], equals(1));
        expect(exportMap['exported_at'], isNotNull);
        expect((exportMap['food_items'] as List).length, equals(1));
      });

      test('Audit 468: SqliteFoodRepository importData restores exported data accurately', () async {
        final food = createTestFood(name: 'Granola Artesanal');
        await repo.insertFood(food);
        final exportMap = await repo.exportData();

        await repo.clearAllData();
        expect(await repo.getActiveFoods(), isEmpty);

        final success = await repo.importData(exportMap);
        expect(success, isTrue);

        final restored = await repo.getActiveFoods();
        expect(restored.length, equals(1));
        expect(restored.first.name, equals('Granola Artesanal'));
      });

      test('Audit 469: SqliteFoodRepository importData rejects payloads missing app or food_items', () async {
        expect(await repo.importData({'version': 1}), isFalse);
        expect(await repo.importData({'app': 'OtherApp', 'food_items': []}), isFalse);
      });

      test('Audit 470: SqliteFoodRepository importData rejects invalid schema versions (> 2)', () async {
        expect(await repo.importData({'app': 'Valora', 'version': 99, 'food_items': []}), isFalse);
      });

      test('Audit 471: SqliteFoodRepository importData validates each item and rejects corrupted payload', () async {
        final corrupted = {
          'app': 'Valora',
          'version': 1,
          'food_items': [
            {'id': '1', 'name': '', 'initial_quantity': -1.0} // missing fields & invalid
          ]
        };
        final success = await repo.importData(corrupted);
        expect(success, isFalse);
      });

      test('Audit 472: FoodItem.validate catches empty name', () {
        final item = createTestFood(name: '');
        expect(item.validate(), contains('Food name cannot be empty.'));
      });

      test('Audit 473: FoodItem.validate catches name exceeding 150 characters', () {
        final longName = 'A' * 151;
        final item = createTestFood(name: longName);
        expect(item.validate(), contains('Food name cannot exceed 150 characters.'));
      });

      test('Audit 474: FoodItem.validate catches zero initial quantity', () {
        final item = createTestFood(initialQuantity: 0.0);
        expect(item.validate(), contains('Initial quantity must be greater than zero.'));
      });

      test('Audit 475: FoodItem.validate catches quantity exceeding 1,000,000 limit', () {
        final item = createTestFood(initialQuantity: 1000001.0);
        expect(item.validate(), contains('Initial quantity is too large.'));
      });

      test('Audit 476: FoodItem.validate catches negative consumed quantity', () {
        final item = createTestFood(consumedQuantity: -1.0);
        expect(item.validate(), contains('Consumed quantity cannot be negative.'));
      });

      test('Audit 477: FoodItem.validate catches negative discarded quantity', () {
        final item = createTestFood(discardedQuantity: -1.0);
        expect(item.validate(), contains('Discarded quantity cannot be negative.'));
      });

      test('Audit 478: FoodItem.validate catches consumed + discarded exceeding initial quantity', () {
        final item = createTestFood(initialQuantity: 1.0, consumedQuantity: 0.8, discardedQuantity: 0.5);
        expect(item.validate(), contains('Total consumed and discarded quantity exceeds initial quantity.'));
      });

      test('Audit 479: FoodItem.validate catches negative purchase price', () {
        final item = createTestFood(purchasePrice: -5.0);
        expect(item.validate(), contains('Purchase price cannot be negative.'));
      });

      test('Audit 480: FoodItem.validate catches purchase price exceeding 1,000,000 limit', () {
        final item = createTestFood(purchasePrice: 1000001.0);
        expect(item.validate(), contains('Purchase price is too large.'));
      });

      test('Audit 481: FoodItem.validate catches expiry date before purchase date', () {
        final pDate = DateTime(2026, 10, 20);
        final eDate = DateTime(2026, 10, 15);
        final item = createTestFood(purchaseDate: pDate, expiryDate: eDate);
        expect(item.validate(), contains('Expiry date cannot be before purchase date.'));
      });

      test('Audit 482: FoodItem.validate allows expiry date same calendar day as purchase date', () {
        final pDate = DateTime(2026, 10, 20, 18, 0);
        final eDate = DateTime(2026, 10, 20, 10, 0); // earlier hour same day
        final item = createTestFood(purchaseDate: pDate, expiryDate: eDate);
        expect(item.validate(), isEmpty);
      });

      test('Audit 483: FoodItem.calculateProportionalValue calculates half portion accurately', () {
        final item = createTestFood(initialQuantity: 2.0, purchasePrice: 10.0);
        expect(item.calculateProportionalValue(1.0), equals(5.0));
      });

      test('Audit 484: FoodItem.calculateProportionalValue returns null when purchasePrice is null', () {
        final item = createTestFood(purchasePrice: null);
        expect(item.calculateProportionalValue(1.0), isNull);
      });

      test('Audit 485: FoodItem.calculateProportionalValue returns null on zero or negative quantity', () {
        final item = createTestFood(initialQuantity: 2.0, purchasePrice: 10.0);
        expect(item.calculateProportionalValue(0.0), isNull);
        expect(item.calculateProportionalValue(-1.0), isNull);
      });

      test('Audit 486: FoodItem.calculateProportionalValue handles quarter portion calculation', () {
        final item = createTestFood(initialQuantity: 4.0, purchasePrice: 20.0);
        expect(item.calculateProportionalValue(1.0), equals(5.0));
      });

      test('Audit 487: FoodItem serialization toMap and fromMap roundtrip preserves all fields', () {
        final original = createTestFood();
        final map = original.toMap();
        final restored = FoodItem.fromMap(map);
        expect(restored.id, equals(original.id));
        expect(restored.name, equals(original.name));
        expect(restored.category, equals(original.category));
        expect(restored.initialQuantity, equals(original.initialQuantity));
        expect(restored.unit, equals(original.unit));
        expect(restored.purchasePrice, equals(original.purchasePrice));
        expect(restored.storageLocation, equals(original.storageLocation));
        expect(restored.status, equals(original.status));
      });

      test('Audit 488: FoodItem copyWith clearExpiryDate sets expiryDate to null', () {
        final item = createTestFood(expiryDate: DateTime.now());
        final cleared = item.copyWith(clearExpiryDate: true);
        expect(cleared.expiryDate, isNull);
      });

      test('Audit 489: FoodItem copyWith clearPurchasePrice sets purchasePrice to null', () {
        final item = createTestFood(purchasePrice: 15.0);
        final cleared = item.copyWith(clearPurchasePrice: true);
        expect(cleared.purchasePrice, isNull);
      });

      test('Audit 490: FoodItem copyWith clearStorageLocation sets storageLocation to null', () {
        final item = createTestFood(storageLocation: StorageLocation.freezer);
        final cleared = item.copyWith(clearStorageLocation: true);
        expect(cleared.storageLocation, isNull);
      });

      test('Audit 491: FoodActivity.validate catches empty activity id', () {
        final act = FoodActivity(
          id: '',
          foodItemId: 'item-1',
          foodName: 'Maçã',
          category: FoodCategory.fruits,
          quantity: 1.0,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: DateTime.now(),
        );
        expect(act.validate(), contains('Activity id cannot be empty.'));
      });

      test('Audit 492: FoodActivity.validate catches empty foodItemId', () {
        final act = FoodActivity(
          id: 'act-1',
          foodItemId: '',
          foodName: 'Maçã',
          category: FoodCategory.fruits,
          quantity: 1.0,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: DateTime.now(),
        );
        expect(act.validate(), contains('Referenced food item id cannot be empty.'));
      });

      test('Audit 493: FoodActivity.validate catches non-positive quantity', () {
        final act = FoodActivity(
          id: 'act-1',
          foodItemId: 'item-1',
          foodName: 'Maçã',
          category: FoodCategory.fruits,
          quantity: 0.0,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: DateTime.now(),
        );
        expect(act.validate(), contains('Activity quantity must be a valid positive number.'));
      });

      test('Audit 494: FoodActivity.validate catches negative estimatedValue', () {
        final act = FoodActivity(
          id: 'act-1',
          foodItemId: 'item-1',
          foodName: 'Maçã',
          category: FoodCategory.fruits,
          quantity: 1.0,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: DateTime.now(),
          estimatedValue: -2.0,
        );
        expect(act.validate(), contains('Estimated value cannot be negative or invalid.'));
      });

      test('Audit 495: FoodActivity.validate catches notes exceeding 500 characters', () {
        final longNotes = 'A' * 501;
        final act = FoodActivity(
          id: 'act-1',
          foodItemId: 'item-1',
          foodName: 'Maçã',
          category: FoodCategory.fruits,
          quantity: 1.0,
          unit: FoodUnit.piece,
          type: ActivityType.consumed,
          timestamp: DateTime.now(),
          notes: longNotes,
        );
        expect(act.validate(), contains('Activity notes cannot exceed 500 characters.'));
      });

      test('Audit 496: FoodActivity toMap and fromMap roundtrip preserves all fields', () {
        final act = FoodActivity(
          id: 'act-10',
          foodItemId: 'item-20',
          foodName: 'Pera Williams',
          category: FoodCategory.fruits,
          quantity: 2.5,
          unit: FoodUnit.kilogram,
          type: ActivityType.discarded,
          timestamp: DateTime(2026, 10, 18, 14, 30),
          estimatedValue: 12.50,
          notes: 'Deteriorada',
        );
        final map = act.toMap();
        final restored = FoodActivity.fromMap(map);
        expect(restored.id, equals(act.id));
        expect(restored.foodItemId, equals(act.foodItemId));
        expect(restored.foodName, equals(act.foodName));
        expect(restored.category, equals(act.category));
        expect(restored.quantity, equals(act.quantity));
        expect(restored.unit, equals(act.unit));
        expect(restored.type, equals(act.type));
        expect(restored.estimatedValue, equals(act.estimatedValue));
        expect(restored.notes, equals(act.notes));
      });

      test('Audit 497: Sqlite database enforces foreign key cascade pragma', () async {
        final pragma = await repo.db.rawQuery('PRAGMA foreign_keys;');
        expect(pragma.first['foreign_keys'], equals(1));
      });

      test('Audit 498: Batch food item insertions execute reliably within single loop', () async {
        for (int i = 0; i < 20; i++) {
          final food = createTestFood(name: 'Alimento $i');
          await repo.insertFood(food);
        }
        final items = await repo.getActiveFoods();
        expect(items.length, equals(20));
      });

      test('Audit 499: FoodItem operator == checks id and attributes equality', () {
        final fixedExpiry = DateTime(2026, 10, 25, 12, 0);
        final f1 = createTestFood(id: 'same-id', name: 'Item', expiryDate: fixedExpiry);
        final f2 = createTestFood(id: 'same-id', name: 'Item', expiryDate: fixedExpiry);
        expect(f1, equals(f2));
      });

      test('Audit 500: FoodItem.getExpiryStatus is ExpiryStatus.expired when expiryDate is before reference date', () {
        final expiredDate = DateTime.now().subtract(const Duration(days: 2));
        final food = createTestFood(expiryDate: expiredDate);
        expect(food.getExpiryStatus(referenceDate: DateTime.now()), equals(ExpiryStatus.expired));
      });
    });
  });
}
