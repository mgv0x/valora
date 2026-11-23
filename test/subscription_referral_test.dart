import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valora/data/services/preferences_service.dart';
import 'package:valora/state/subscription_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Subscription & Referral Program Tests (Android Model)', () {
    late PreferencesService prefs;
    late SubscriptionProvider subscription;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      prefs = PreferencesService(sp);
      subscription = SubscriptionProvider(prefs: prefs);
    });

    test('1. Initial launch grants 7 days free trial and generates referral code', () {
      expect(SubscriptionProvider.baseTrialDays, equals(7));
      expect(SubscriptionProvider.bonusDaysPerInvite, equals(7));
      expect(SubscriptionProvider.monthlyPrice, equals(9.90));
      expect(SubscriptionProvider.formattedPrice, equals('R\$ 9,90 / mês'));

      expect(subscription.isTrialActive, isTrue);
      expect(subscription.daysRemainingInTrial, inInclusiveRange(6, 7));
      expect(subscription.referralBonusDays, equals(0));
      expect(subscription.totalTrialDays, equals(7));
      expect(subscription.isSubscribed, isFalse);

      expect(subscription.userReferralCode, startsWith('VAL-'));
      expect(subscription.userReferralCode.length, equals(8));
      expect(subscription.invitedCount, equals(0));
      expect(subscription.redeemedCodes, isEmpty);
    });

    test('2. Subscribing for R\$ 9,90/month activates subscription for 30 days', () async {
      expect(subscription.isSubscribed, isFalse);

      await subscription.subscribe(durationDays: 30);

      expect(subscription.isSubscribed, isTrue);
      expect(subscription.hasActiveAccess, isTrue);
      expect(subscription.subscriptionExpiresAt, isNotNull);
      expect(
        subscription.subscriptionExpiresAt!.isAfter(DateTime.now().add(const Duration(days: 28))),
        isTrue,
      );

      // Verify cancellation
      await subscription.cancelSubscription();
      expect(subscription.isSubscribed, isFalse);
      expect(subscription.subscriptionExpiresAt, isNull);
    });

    test('3. Each invited friend adds +7 extra days of free trial', () async {
      final initialDays = subscription.totalTrialDays;
      expect(initialDays, equals(7));
      expect(subscription.invitedCount, equals(0));
      expect(subscription.referralBonusDays, equals(0));

      // Invite first person
      await subscription.recordInviteSuccess();
      expect(subscription.invitedCount, equals(1));
      expect(subscription.referralBonusDays, equals(7));
      expect(subscription.totalTrialDays, equals(14));

      // Invite second person
      await subscription.recordInviteSuccess();
      expect(subscription.invitedCount, equals(2));
      expect(subscription.referralBonusDays, equals(14));
      expect(subscription.totalTrialDays, equals(21));

      // Invite third person
      await subscription.recordInviteSuccess();
      expect(subscription.invitedCount, equals(3));
      expect(subscription.referralBonusDays, equals(21));
      expect(subscription.totalTrialDays, equals(28));
    });

    test('4. Redeeming a friend referral code adds +7 days and prevents reuse or self-referral', () {
      final ownCode = subscription.userReferralCode;

      // Cannot redeem own code
      final selfResult = subscription.redeemInviteCode(ownCode);
      expect(selfResult, equals(RedemptionResult.selfCode));
      expect(subscription.referralBonusDays, equals(0));

      // Cannot redeem empty code
      final emptyResult = subscription.redeemInviteCode('   ');
      expect(emptyResult, equals(RedemptionResult.empty));

      // Redeem valid friend code
      const friendCode = 'VAL-AMIG';
      final successResult = subscription.redeemInviteCode(friendCode);
      expect(successResult, equals(RedemptionResult.success));
      expect(subscription.referralBonusDays, equals(7));
      expect(subscription.redeemedCodes, contains(friendCode));

      // Cannot redeem same code twice
      final duplicateResult = subscription.redeemInviteCode(friendCode);
      expect(duplicateResult, equals(RedemptionResult.alreadyUsed));
      expect(subscription.referralBonusDays, equals(7));
    });

    test('5. Trial expiration enforces paywall when required', () async {
      subscription.setEnforceOnNonAndroid(true);
      expect(subscription.hasActiveAccess, isTrue);

      // Expire trial
      await subscription.expireTrialForDemo();
      expect(subscription.isTrialActive, isFalse);
      expect(subscription.hasActiveAccess, isFalse);

      // Regain access by inviting a friend (+7 days)
      await subscription.recordInviteSuccess();
      expect(subscription.isTrialActive, isTrue);
      expect(subscription.hasActiveAccess, isTrue);

      // Or by subscribing (R$ 9,90)
      await subscription.expireTrialForDemo();
      expect(subscription.hasActiveAccess, isFalse);

      await subscription.subscribe();
      expect(subscription.hasActiveAccess, isTrue);
    });

    test('6. Share message contains app instructions and user referral code', () {
      final msg = subscription.shareMessage;
      expect(msg, contains(subscription.userReferralCode));
      expect(msg, contains('7 dias extras grátis'));
      expect(msg, contains('Valora'));
    });

    test('7. First launch hasAcceptedTrial starts false and acceptTrial updates state and persistence', () async {
      expect(subscription.hasAcceptedTrial, isFalse);

      await subscription.acceptTrial();

      expect(subscription.hasAcceptedTrial, isTrue);
      expect(prefs.hasAcceptedTrial, isTrue);

      // Reset for demo resets hasAcceptedTrial
      await subscription.resetTrialForDemo();
      expect(subscription.hasAcceptedTrial, isFalse);
      expect(prefs.hasAcceptedTrial, isFalse);
    });
  });
}
