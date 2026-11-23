import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';
import '../data/services/preferences_service.dart';
import '../data/services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  final PreferencesService prefs;
  final NotificationService notifications;
  final AuthService authService;

  Locale? _locale;
  int _warningThresholdDays;
  bool _notificationsEnabled;
  ThemeMode _themeMode;
  String _userName;
  String _userEmail;
  bool _isLoggedIn;
  String? _userAvatar;

  SettingsProvider({
    required this.prefs,
    required this.notifications,
    AuthService? authService,
  })  : authService = authService ?? FirebaseAuthService(),
        _warningThresholdDays = prefs.warningThresholdDays,
        _notificationsEnabled = prefs.notificationsEnabled,
        _themeMode = _parseThemeMode(prefs.themeMode),
        _userName = prefs.userName,
        _userEmail = prefs.userEmail,
        _isLoggedIn = prefs.isLoggedIn,
        _userAvatar = prefs.userAvatar {
    final code = prefs.localeCode;
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
    }
  }

  Locale? get locale => _locale;
  int get warningThresholdDays => _warningThresholdDays;
  bool get notificationsEnabled => _notificationsEnabled;
  ThemeMode get themeMode => _themeMode;

  String get userName => _userName;
  String get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;
  String? get userAvatar => _userAvatar;

  String get userFirstName {
    final trimmed = _userName.trim();
    if (trimmed.isEmpty) return 'Amigo';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  String get userInitials {
    final trimmed = _userName.trim();
    if (trimmed.isEmpty) return 'V';
    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'V';
    try {
      if (parts.length == 1) {
        final runes = parts[0].runes.toList();
        if (runes.isEmpty) return 'V';
        final count = runes.length >= 2 ? 2 : 1;
        return String.fromCharCodes(runes.take(count)).toUpperCase();
      }
      final firstRunes = parts.first.runes.toList();
      final lastRunes = parts.last.runes.toList();
      if (firstRunes.isEmpty) return 'V';
      if (lastRunes.isEmpty) return String.fromCharCode(firstRunes.first).toUpperCase();
      return '${String.fromCharCode(firstRunes.first)}${String.fromCharCode(lastRunes.first)}'.toUpperCase();
    } catch (_) {
      return 'V';
    }
  }

  static ThemeMode _parseThemeMode(String? mode) {
    if (mode == 'dark') return ThemeMode.dark;
    if (mode == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  Future<void> setLocale(String? code) async {
    await prefs.setLocaleCode(code);
    _locale = code != null ? Locale(code) : null;
    notifyListeners();
  }

  Future<void> setWarningThresholdDays(int days) async {
    if (days < 1 || days > 30) return;
    await prefs.setWarningThresholdDays(days);
    _warningThresholdDays = days;
    notifyListeners();
  }

  Future<bool> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      final granted = await notifications.requestPermission();
      await prefs.setNotificationsEnabled(granted);
      _notificationsEnabled = granted;
      notifyListeners();
      return granted;
    } else {
      await prefs.setNotificationsEnabled(false);
      await notifications.cancelAll();
      _notificationsEnabled = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String? val;
    if (mode == ThemeMode.dark) val = 'dark';
    if (mode == ThemeMode.light) val = 'light';
    await prefs.setThemeMode(val);
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
    String? name,
  }) async {
    final trimmedEmail = email.trim();
    String finalName = name?.trim() ?? '';
    if (finalName.isEmpty) {
      final handle = trimmedEmail.split('@').first;
      finalName = handle
          .replaceAll('.', ' ')
          .replaceAll('_', ' ')
          .replaceAll('-', ' ')
          .split(' ')
          .where((p) => p.isNotEmpty)
          .map((w) => w[0].toUpperCase() + (w.length > 1 ? w.substring(1) : ''))
          .join(' ');
      if (finalName.isEmpty) finalName = 'Usuário Valora';
    }

    if (authService.isFirebaseAvailable) {
      final firebaseUser = await authService.signInWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      if (firebaseUser?.displayName != null && firebaseUser!.displayName!.isNotEmpty) {
        finalName = firebaseUser.displayName!;
      }
    }

    _userName = finalName;
    _userEmail = trimmedEmail;
    _isLoggedIn = true;

    await prefs.setUserName(_userName);
    await prefs.setUserEmail(_userEmail);
    await prefs.setIsLoggedIn(true);
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedName = name.trim().isEmpty ? 'Usuário Valora' : name.trim();
    final trimmedEmail = email.trim();

    if (authService.isFirebaseAvailable) {
      await authService.registerWithEmailAndPassword(
        name: trimmedName,
        email: trimmedEmail,
        password: password,
      );
    }

    _userName = trimmedName;
    _userEmail = trimmedEmail;
    _isLoggedIn = true;

    await prefs.setUserName(_userName);
    await prefs.setUserEmail(_userEmail);
    await prefs.setIsLoggedIn(true);
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (authService.isFirebaseAvailable) {
      await authService.sendPasswordResetEmail(email.trim());
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    String? avatar,
  }) async {
    _userName = name.trim().isEmpty ? _userName : name.trim();
    _userEmail = email.trim().isEmpty ? _userEmail : email.trim();
    _userAvatar = avatar;

    await prefs.setUserName(_userName);
    await prefs.setUserEmail(_userEmail);
    await prefs.setUserAvatar(avatar);
    notifyListeners();
  }

  Future<void> logout() async {
    if (authService.isFirebaseAvailable) {
      await authService.signOut();
    }
    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    _userAvatar = null;
    await prefs.clearAuth();
    notifyListeners();
  }

  Future<void> continueAsGuest() async {
    _userName = 'Convidado';
    _userEmail = 'convidado@valora.app';
    _isLoggedIn = true;

    await prefs.setUserName(_userName);
    await prefs.setUserEmail(_userEmail);
    await prefs.setIsLoggedIn(true);
    notifyListeners();
  }
}
