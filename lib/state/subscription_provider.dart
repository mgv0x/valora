import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/services/preferences_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  final PreferencesService prefs;

  static const double monthlyPrice = 9.90;
  static const String formattedPrice = 'R\$ 9,90 / mês';
  static const int baseTrialDays = 7;
  static const int bonusDaysPerInvite = 7;

  double get price => monthlyPrice;
  String get priceFormatted => formattedPrice;
  int get trialBaseDays => baseTrialDays;
  int get inviteBonusDays => bonusDaysPerInvite;

  late DateTime _firstLaunchDate;
  bool _isSubscribed = false;
  bool _hasAcceptedTrial = false;
  DateTime? _subscriptionExpiresAt;
  int _referralBonusDays = 0;
  late String _userReferralCode;
  int _invitedCount = 0;
  List<String> _redeemedCodes = [];

  // Setting to allow testing paywall on any platform (default true on Android)
  bool _enforceOnNonAndroid = false;

  SubscriptionProvider({required this.prefs}) {
    _init();
  }

  void _init() {
    // 1. First launch timestamp
    final storedLaunch = prefs.firstLaunchTime;
    if (storedLaunch == null) {
      final now = DateTime.now();
      _firstLaunchDate = now;
      prefs.setFirstLaunchTime(now.millisecondsSinceEpoch);
    } else {
      _firstLaunchDate = DateTime.fromMillisecondsSinceEpoch(storedLaunch);
    }

    // 2. User referral code
    final storedCode = prefs.userReferralCode;
    if (storedCode == null || storedCode.isEmpty) {
      _userReferralCode = _generateReferralCode();
      prefs.setUserReferralCode(_userReferralCode);
    } else {
      _userReferralCode = storedCode;
    }

    // 3. Subscription & Referrals state
    _isSubscribed = prefs.isSubscribed;
    final expiryTimestamp = prefs.subscriptionExpiry;
    if (expiryTimestamp != null) {
      _subscriptionExpiresAt =
          DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
      if (_subscriptionExpiresAt!.isBefore(DateTime.now())) {
        _isSubscribed = false;
        _subscriptionExpiresAt = null;
        prefs.setSubscribed(false);
        prefs.setSubscriptionExpiry(null);
      }
    }

    _referralBonusDays = prefs.referralBonusDays;
    _invitedCount = prefs.invitedCount;
    _redeemedCodes = List.from(prefs.redeemedCodes);
    _hasAcceptedTrial = prefs.hasAcceptedTrial;
  }

  String _generateReferralCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    final buffer = StringBuffer('VAL-');
    for (int i = 0; i < 4; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  // Getters
  bool get isAndroidPlatform => !kIsWeb && Platform.isAndroid;
  bool get isMobilePlatform => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  bool get isSubscriptionRequired => isMobilePlatform || _enforceOnNonAndroid;

  bool get enforceOnNonAndroid => _enforceOnNonAndroid;

  void setEnforceOnNonAndroid(bool enforce) {
    _enforceOnNonAndroid = enforce;
    notifyListeners();
  }

  DateTime get firstLaunchDate => _firstLaunchDate;

  bool get isSubscribed => _isSubscribed;

  DateTime? get subscriptionExpiresAt => _subscriptionExpiresAt;

  int get referralBonusDays => _referralBonusDays;

  int get totalTrialDays => baseTrialDays + _referralBonusDays;

  DateTime get trialExpiresAt =>
      _firstLaunchDate.add(Duration(days: totalTrialDays));

  bool get isTrialActive => DateTime.now().isBefore(trialExpiresAt);

  int get daysRemainingInTrial {
    if (!isTrialActive) return 0;
    final diff = trialExpiresAt.difference(DateTime.now());
    final days = diff.inDays + 1;
    if (days > totalTrialDays) return totalTrialDays;
    return days;
  }

  bool get hasActiveAccess {
    if (!isSubscriptionRequired) return true;
    return _isSubscribed || isTrialActive;
  }

  String get userReferralCode => _userReferralCode;

  bool get hasAcceptedTrial => _hasAcceptedTrial;

  int get invitedCount => _invitedCount;

  List<String> get redeemedCodes => List.unmodifiable(_redeemedCodes);

  String get shareMessage =>
      'Use o app Valora para gerenciar alimentos e evitar desperdício! Use meu código de convite $_userReferralCode e ganhe 7 dias extras grátis: https://valora.app/convite/$_userReferralCode';

  // Actions
  Future<void> acceptTrial() async {
    _hasAcceptedTrial = true;
    await prefs.setHasAcceptedTrial(true);
    notifyListeners();
  }

  Future<void> subscribe({int durationDays = 30}) async {
    _isSubscribed = true;
    _subscriptionExpiresAt = DateTime.now().add(Duration(days: durationDays));
    await prefs.setSubscribed(true);
    await prefs
        .setSubscriptionExpiry(_subscriptionExpiresAt!.millisecondsSinceEpoch);
    notifyListeners();
  }

  Future<void> cancelSubscription() async {
    _isSubscribed = false;
    _subscriptionExpiresAt = null;
    await prefs.setSubscribed(false);
    await prefs.setSubscriptionExpiry(null);
    notifyListeners();
  }

  /// Adds +7 days when the user invites a friend
  Future<void> recordInviteSuccess() async {
    _invitedCount += 1;
    _referralBonusDays += bonusDaysPerInvite;
    await prefs.setInvitedCount(_invitedCount);
    await prefs.setReferralBonusDays(_referralBonusDays);
    notifyListeners();
  }

  /// Redeems a friend's referral code to gain +7 days
  RedemptionResult redeemInviteCode(String rawCode) {
    final code = rawCode.trim().toUpperCase();
    if (code.isEmpty) {
      return RedemptionResult.empty;
    }
    final codeRegex = RegExp(r'^VAL-[A-Z0-9]{4}$');
    if (!codeRegex.hasMatch(code)) {
      return RedemptionResult.invalidFormat;
    }
    if (code == _userReferralCode.toUpperCase()) {
      return RedemptionResult.selfCode;
    }
    if (_redeemedCodes.any((c) => c.trim().toUpperCase() == code)) {
      return RedemptionResult.alreadyUsed;
    }

    _redeemedCodes.add(code);
    _referralBonusDays += bonusDaysPerInvite;
    prefs.setRedeemedCodes(_redeemedCodes);
    prefs.setReferralBonusDays(_referralBonusDays);
    notifyListeners();
    return RedemptionResult.success;
  }

  // Testing / Demo Helpers
  Future<void> expireTrialForDemo() async {
    _isSubscribed = false;
    _firstLaunchDate =
        DateTime.now().subtract(Duration(days: totalTrialDays + 1));
    await prefs.setSubscribed(false);
    await prefs.setSubscriptionExpiry(null);
    await prefs.setFirstLaunchTime(_firstLaunchDate.millisecondsSinceEpoch);
    notifyListeners();
  }

  Future<void> resetTrialForDemo() async {
    _isSubscribed = false;
    _hasAcceptedTrial = false;
    _firstLaunchDate = DateTime.now();
    _referralBonusDays = 0;
    _invitedCount = 0;
    _redeemedCodes.clear();
    await prefs.setSubscribed(false);
    await prefs.setHasAcceptedTrial(false);
    await prefs.setSubscriptionExpiry(null);
    await prefs.setFirstLaunchTime(_firstLaunchDate.millisecondsSinceEpoch);
    await prefs.setReferralBonusDays(0);
    await prefs.setInvitedCount(0);
    await prefs.setRedeemedCodes([]);
    notifyListeners();
  }
}

enum RedemptionResult {
  success,
  empty,
  invalidFormat,
  selfCode,
  alreadyUsed,
}
