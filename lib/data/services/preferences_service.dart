import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyLocale = 'valora_pref_locale';
  static const String _keyWarningDays = 'valora_pref_warning_days';
  static const String _keyNotificationsEnabled = 'valora_pref_notifications_enabled';
  static const String _keyThemeMode = 'valora_pref_theme_mode';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static Future<PreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  String? get localeCode => _prefs.getString(_keyLocale);

  Future<void> setLocaleCode(String? code) async {
    if (code == null) {
      await _prefs.remove(_keyLocale);
    } else {
      await _prefs.setString(_keyLocale, code);
    }
  }

  int get warningThresholdDays => _prefs.getInt(_keyWarningDays) ?? 3;

  Future<void> setWarningThresholdDays(int days) async {
    final clamped = days.clamp(1, 30);
    await _prefs.setInt(_keyWarningDays, clamped);
  }

  bool get notificationsEnabled => _prefs.getBool(_keyNotificationsEnabled) ?? false;

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  String? get themeMode => _prefs.getString(_keyThemeMode);

  Future<void> setThemeMode(String? mode) async {
    if (mode == null || mode == 'system') {
      await _prefs.remove(_keyThemeMode);
    } else {
      await _prefs.setString(_keyThemeMode, mode);
    }
  }

  static const String _keyFirstLaunchTime = 'valora_pref_first_launch_time';
  static const String _keyHasSeenOnboarding = 'valora_pref_has_seen_onboarding';
  static const String _keyHasAcceptedTrial = 'valora_pref_has_accepted_trial';
  static const String _keyIsSubscribed = 'valora_pref_is_subscribed';

  bool get hasSeenOnboarding => _prefs.getBool(_keyHasSeenOnboarding) ?? false;
  Future<void> setHasSeenOnboarding(bool seen) async =>
      _prefs.setBool(_keyHasSeenOnboarding, seen);

  bool get hasAcceptedTrial => _prefs.getBool(_keyHasAcceptedTrial) ?? false;
  Future<void> setHasAcceptedTrial(bool accepted) async =>
      _prefs.setBool(_keyHasAcceptedTrial, accepted);
  static const String _keySubscriptionExpiry = 'valora_pref_subscription_expiry';
  static const String _keyReferralBonusDays = 'valora_pref_referral_bonus_days';
  static const String _keyUserReferralCode = 'valora_pref_user_referral_code';
  static const String _keyInvitedCount = 'valora_pref_invited_count';
  static const String _keyRedeemedCodes = 'valora_pref_redeemed_codes';

  int? get firstLaunchTime => _prefs.getInt(_keyFirstLaunchTime);
  Future<void> setFirstLaunchTime(int timestamp) async =>
      _prefs.setInt(_keyFirstLaunchTime, timestamp);

  bool get isSubscribed => _prefs.getBool(_keyIsSubscribed) ?? false;
  Future<void> setSubscribed(bool subscribed) async =>
      _prefs.setBool(_keyIsSubscribed, subscribed);

  int? get subscriptionExpiry => _prefs.getInt(_keySubscriptionExpiry);
  Future<void> setSubscriptionExpiry(int? timestamp) async {
    if (timestamp == null) {
      await _prefs.remove(_keySubscriptionExpiry);
    } else {
      await _prefs.setInt(_keySubscriptionExpiry, timestamp);
    }
  }

  int get referralBonusDays => _prefs.getInt(_keyReferralBonusDays) ?? 0;
  Future<void> setReferralBonusDays(int days) async =>
      _prefs.setInt(_keyReferralBonusDays, days < 0 ? 0 : days);

  String? get userReferralCode => _prefs.getString(_keyUserReferralCode);
  Future<void> setUserReferralCode(String code) async =>
      _prefs.setString(_keyUserReferralCode, code);

  int get invitedCount => _prefs.getInt(_keyInvitedCount) ?? 0;
  Future<void> setInvitedCount(int count) async =>
      _prefs.setInt(_keyInvitedCount, count < 0 ? 0 : count);

  List<String> get redeemedCodes => (_prefs.getStringList(_keyRedeemedCodes) ?? [])
      .map((c) => c.trim().toUpperCase())
      .where((c) => c.isNotEmpty)
      .toSet()
      .toList();
  Future<void> setRedeemedCodes(List<String> codes) async {
    final sanitized = codes
        .map((c) => c.trim().toUpperCase())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    await _prefs.setStringList(_keyRedeemedCodes, sanitized);
  }

  // User Auth & Profile Preferences
  static const String _keyUserName = 'valora_pref_user_name';
  static const String _keyUserEmail = 'valora_pref_user_email';
  static const String _keyIsLoggedIn = 'valora_pref_is_logged_in';
  static const String _keyUserAvatar = 'valora_pref_user_avatar';

  String get userName => _prefs.getString(_keyUserName) ?? '';
  Future<void> setUserName(String name) async =>
      _prefs.setString(_keyUserName, name);

  String get userEmail => _prefs.getString(_keyUserEmail) ?? '';
  Future<void> setUserEmail(String email) async =>
      _prefs.setString(_keyUserEmail, email);

  bool get isLoggedIn => _prefs.getBool(_keyIsLoggedIn) ?? false;
  Future<void> setIsLoggedIn(bool loggedIn) async =>
      _prefs.setBool(_keyIsLoggedIn, loggedIn);

  String? get userAvatar => _prefs.getString(_keyUserAvatar);
  Future<void> setUserAvatar(String? avatar) async {
    if (avatar == null) {
      await _prefs.remove(_keyUserAvatar);
    } else {
      await _prefs.setString(_keyUserAvatar, avatar);
    }
  }

  Future<void> clearAuth() async {
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserAvatar);
  }

  // Smart Shopping List Preferences
  static const String _keyShoppingList = 'valora_pref_shopping_list';

  List<String> get shoppingListJson =>
      _prefs.getStringList(_keyShoppingList) ?? [];

  Future<void> setShoppingListJson(List<String> jsonList) async =>
      _prefs.setStringList(_keyShoppingList, jsonList);

  // Cloud Database & Sync Management
  static const String _keyLastCloudSyncTime = 'valora_pref_last_cloud_sync_time';
  static const String _keyCloudSyncEnabled = 'valora_pref_cloud_sync_enabled';
  static const String _keyCloudBackupSnapshot = 'valora_pref_cloud_backup_snapshot';

  DateTime? get lastCloudSyncTime {
    final raw = _prefs.getString(_keyLastCloudSyncTime);
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  Future<void> setLastCloudSyncTime(DateTime time) async =>
      _prefs.setString(_keyLastCloudSyncTime, time.toIso8601String());

  bool get cloudSyncEnabled => _prefs.getBool(_keyCloudSyncEnabled) ?? true;
  Future<void> setCloudSyncEnabled(bool enabled) async =>
      _prefs.setBool(_keyCloudSyncEnabled, enabled);

  String? get cloudBackupSnapshot => _prefs.getString(_keyCloudBackupSnapshot);
  Future<void> setCloudBackupSnapshot(String? snapshot) async {
    if (snapshot == null) {
      await _prefs.remove(_keyCloudBackupSnapshot);
    } else {
      await _prefs.setString(_keyCloudBackupSnapshot, snapshot);
    }
  }
}
