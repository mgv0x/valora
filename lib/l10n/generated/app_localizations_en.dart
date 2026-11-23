// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Valora';

  @override
  String get tagline => 'Waste less. Live better.';

  @override
  String get homeTitle => 'Home';

  @override
  String get pantryTitle => 'Pantry';

  @override
  String get expiryCenterTitle => 'Expiry Center';

  @override
  String get impactTitle => 'My Impact';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String activeItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active items',
      one: '1 active item',
      zero: 'No active items',
    );
    return '$_temp0';
  }

  @override
  String needsAttentionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items need attention',
      one: '1 item needs attention',
      zero: 'None needs attention',
    );
    return '$_temp0';
  }

  @override
  String expiringSoonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items expiring soon',
      one: '1 item expiring soon',
      zero: 'None expiring soon',
    );
    return '$_temp0';
  }

  @override
  String get priorityItems => 'Priority Items';

  @override
  String get consumeFirstTitle => 'Consume first';

  @override
  String get insightNoneUrgent => 'No food needs urgent attention.';

  @override
  String insightExpired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count foods are already expired. Prioritize these items to reduce waste.',
      one: '1 food is already expired. Prioritize these items to reduce waste.',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count foods expire today. Prioritize these items to reduce waste.',
      one: '1 food expires today. Prioritize these items to reduce waste.',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringTomorrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'These $count foods expire tomorrow.',
      one: 'This food expires tomorrow.',
    );
    return '$_temp0';
  }

  @override
  String get insightGeneralPriority =>
      'Prioritize these items to reduce waste.';

  @override
  String get priorityHigh => 'High priority';

  @override
  String get priorityAttention => 'Attention';

  @override
  String get priorityOnTrack => 'On track';

  @override
  String get viewAll => 'View all';

  @override
  String get addFood => 'Add Food';

  @override
  String get editFood => 'Edit Food';

  @override
  String get foodDetails => 'Food Details';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get consume => 'Consume';

  @override
  String get discard => 'Discard';

  @override
  String get markConsumed => 'Mark as Consumed';

  @override
  String get markDiscarded => 'Mark as Discarded';

  @override
  String get all => 'All';

  @override
  String get foodName => 'Food Name';

  @override
  String get foodNameHint => 'e.g., Organic Milk, Fresh Apples';

  @override
  String get foodNameRequired => 'Please enter a food name';

  @override
  String get category => 'Category';

  @override
  String get categoryRequired => 'Please select a category';

  @override
  String get quantity => 'Quantity';

  @override
  String get quantityRequired => 'Please enter a quantity greater than 0';

  @override
  String get unit => 'Unit';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get unknownExpiry => 'Unknown expiry date';

  @override
  String get expiryDateRequired =>
      'Please select an expiry date or mark as unknown';

  @override
  String get purchasePrice => 'Purchase Price';

  @override
  String get purchasePriceOptional => 'Purchase Price (optional)';

  @override
  String get purchasePriceInvalid => 'Price cannot be negative';

  @override
  String get storageLocation => 'Storage Location';

  @override
  String get storageLocationOptional => 'Storage Location (optional)';

  @override
  String get purchaseDate => 'Purchase Date';

  @override
  String get purchaseDateOptional => 'Purchase Date (optional)';

  @override
  String get notes => 'Notes';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get notesHint => 'Brand, specific shelf, batch, etc.';

  @override
  String get catFruits => 'Fruits';

  @override
  String get catVegetables => 'Vegetables';

  @override
  String get catDairy => 'Dairy';

  @override
  String get catMeatFish => 'Meat & Fish';

  @override
  String get catBakery => 'Bakery';

  @override
  String get catPantryStaples => 'Pantry Staples';

  @override
  String get catFrozen => 'Frozen Foods';

  @override
  String get catDrinks => 'Drinks';

  @override
  String get catOther => 'Other';

  @override
  String get locRefrigerator => 'Refrigerator';

  @override
  String get locFreezer => 'Freezer';

  @override
  String get locPantry => 'Pantry';

  @override
  String get locOther => 'Other';

  @override
  String get unitPiece => 'unit';

  @override
  String get unitGram => 'g';

  @override
  String get unitKilogram => 'kg';

  @override
  String get unitMilliliter => 'ml';

  @override
  String get unitLiter => 'L';

  @override
  String get unitPackage => 'pack';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusExpiringToday => 'Expires today';

  @override
  String get statusExpiringSoon => 'Expiring soon';

  @override
  String get statusFresh => 'Fresh';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String daysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
      zero: 'Expires today',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Expired $days days ago',
      one: 'Expired yesterday',
      zero: 'Expired today',
    );
    return '$_temp0';
  }

  @override
  String get searchPlaceholder => 'Search food by name...';

  @override
  String get filterAll => 'All';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortExpirySoonest => 'Expiry: Earliest first';

  @override
  String get sortExpiryLatest => 'Expiry: Latest first';

  @override
  String get sortNameAZ => 'Name: A to Z';

  @override
  String get sortNameZA => 'Name: Z to A';

  @override
  String get emptyPantryTitle => 'Your pantry is empty';

  @override
  String get emptyPantrySubtitle =>
      'Start organizing what you have at home to avoid waste and make better meals.';

  @override
  String get emptySearchTitle => 'No items match your search';

  @override
  String get emptySearchSubtitle =>
      'Try searching for a different keyword or adjusting the filters.';

  @override
  String get emptyExpiryTitle => 'Everything is on track!';

  @override
  String get emptyExpirySubtitle =>
      'No foods are expired or expiring soon within your current threshold.';

  @override
  String get emptyImpactTitle => 'No activity recorded yet';

  @override
  String get emptyImpactSubtitle =>
      'As you consume or discard foods, Valora will build genuine insights here.';

  @override
  String get groupExpired => 'Expired';

  @override
  String get groupExpiringToday => 'Expiring Today';

  @override
  String get groupExpiringSoon => 'Expiring Soon';

  @override
  String get groupLater => 'Good for Later';

  @override
  String get groupUnknown => 'Unknown Expiry';

  @override
  String get consumeDialogTitle => 'Record Consumption';

  @override
  String get consumeDialogPrompt => 'How much of this food did you consume?';

  @override
  String get discardDialogTitle => 'Record Disposal';

  @override
  String get discardDialogPrompt => 'How much of this food was discarded?';

  @override
  String get resetFilters => 'Reset filters';

  @override
  String quantityRemaining(String qty, String unit) {
    return 'Available: $qty $unit';
  }

  @override
  String quantityOriginal(String qty, String unit) {
    return 'Original: $qty $unit';
  }

  @override
  String quantityConsumed(String qty, String unit) {
    return 'Consumed: $qty $unit';
  }

  @override
  String quantityDiscarded(String qty, String unit) {
    return 'Discarded: $qty $unit';
  }

  @override
  String get deleteConfirmTitle => 'Delete Food Item?';

  @override
  String deleteConfirmContent(String name) {
    return 'Are you sure you want to delete \"$name\"? Historical activity records will be preserved.';
  }

  @override
  String get actionSuccessSaved => 'Food item saved successfully.';

  @override
  String get actionSuccessConsumed => 'Recorded as consumed.';

  @override
  String get actionSuccessDiscarded => 'Recorded as discarded.';

  @override
  String get actionSuccessDeleted => 'Item removed from active pantry.';

  @override
  String get impactSummary => 'Activity Summary';

  @override
  String get itemsConsumed => 'Recorded items consumed';

  @override
  String get itemsDiscarded => 'Recorded items discarded';

  @override
  String get valueConsumed => 'Estimated value consumed';

  @override
  String get valueDiscarded => 'Estimated value discarded';

  @override
  String get consumptionRate => 'Consumption rate';

  @override
  String get impactDisclaimer =>
      'Metrics are calculated directly from recorded activity. Valora never invents savings or carbon estimates.';

  @override
  String get impactHistoryTitle => 'Recent Activity Log';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsEnableNotifications => 'Expiry Reminders';

  @override
  String get settingsNotificationDesc =>
      'Get notified before food items reach their expiry date.';

  @override
  String get settingsNotificationThreshold => 'Warning threshold';

  @override
  String get settingsNotificationThresholdDesc =>
      'Alert me this many days in advance';

  @override
  String daysUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataManagement => 'Data Management';

  @override
  String get settingsExportData => 'Export Data (JSON)';

  @override
  String get settingsExportSuccess => 'Data exported successfully.';

  @override
  String get settingsImportData => 'Import Data (JSON)';

  @override
  String get settingsImportSuccess => 'Data imported successfully.';

  @override
  String get settingsImportInvalid => 'Invalid JSON data file.';

  @override
  String get settingsClearData => 'Clear All Data';

  @override
  String get settingsClearDataConfirm =>
      'This action cannot be undone. All active pantry items and activity history will be deleted.';

  @override
  String get settingsClearDataSuccess => 'All local data has been erased.';

  @override
  String get settingsAbout => 'About Valora';

  @override
  String get settingsAboutDesc =>
      'Valora is a clean, offline-first food inventory & expiry tracking application built for the Hack Club Cider challenge.';

  @override
  String get settingsPrivacy => 'Privacy & Data Storage';

  @override
  String get settingsPrivacyDesc =>
      'All your data stays 100% on this device. No trackers, no accounts, no cloud sync.';

  @override
  String get settingsLicense => 'Open Source License';

  @override
  String get settingsLicenseDesc => 'Released under the MIT License.';

  @override
  String get unsavedChangesTitle => 'Discard changes?';

  @override
  String get unsavedChangesMessage =>
      'You have unsaved changes. Are you sure you want to exit without saving?';

  @override
  String get expirySafetyDisclaimerTitle => 'Expiry Notice & Food Safety';

  @override
  String get expirySafetyDisclaimerContent =>
      'Expiry dates are guidelines for optimal preservation and quality. Always check appearance, aroma, and texture. Foods without an entered expiry date require manual inspection and are never assumed to be automatically safe or expired.';

  @override
  String get partial => 'Partial';

  @override
  String quantityExceedsRemaining(String qty, String unit) {
    return 'Cannot exceed remaining quantity ($qty $unit)';
  }

  @override
  String get discardConfirmPermanent => 'Confirm Discard';

  @override
  String discardConfirmPermanentPrompt(String qty, String unit, String name) {
    return 'Are you sure you want to discard $qty $unit of \"$name\"? This action records food waste and cannot be undone.';
  }

  @override
  String get consumeNotesHint => 'e.g., Prepared dinner, lunchbox';

  @override
  String get discardNotesHint => 'e.g., Spoiled, past date';

  @override
  String get homeNeedsAction => 'Needs Action';

  @override
  String get homeAddFoodDesc => 'Keep track of new purchases to prevent waste';

  @override
  String get activityDetailsTitle => 'Activity Details';

  @override
  String get activityDate => 'Date & Time';

  @override
  String get activityType => 'Action Type';

  @override
  String get activityEstimatedValue => 'Estimated Value';

  @override
  String get activityValueFormulaNotice =>
      'Calculated proportionally from entered purchase price.';

  @override
  String get filterPeriod => 'Period';

  @override
  String get filterPeriodAll => 'All time';

  @override
  String get filterPeriod7Days => 'Last 7 days';

  @override
  String get filterPeriod30Days => 'Last 30 days';

  @override
  String get filterType => 'Type';

  @override
  String get filterTypeAll => 'All actions';

  @override
  String get filterTypeConsumed => 'Consumed only';

  @override
  String get filterTypeDiscarded => 'Discarded only';

  @override
  String get unitBreakdownTitle => 'Recorded Volume by Unit';

  @override
  String get consumedUnits => 'Consumed';

  @override
  String get discardedUnits => 'Discarded';

  @override
  String get fromPricedItems => 'From items with purchase prices';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'Follow System';

  @override
  String get themeLight => 'Light Mode';

  @override
  String get themeDark => 'Dark Mode';

  @override
  String get themeSystemOption => 'System';

  @override
  String get themeLightOption => 'Light';

  @override
  String get themeDarkOption => 'Dark';

  @override
  String get copyToClipboard => 'Copy to Clipboard';

  @override
  String get dataCopiedToClipboard => 'Data copied to clipboard!';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get importPastePrompt =>
      'Paste your exported Valora JSON backup below:';

  @override
  String get notificationPermissionDenied =>
      'Notification permission was not granted by device settings.';

  @override
  String get appVersionDetails => 'Version 1.0.0 • Hack Club Cider Submission';

  @override
  String get selectLanguage => 'Select Language / Escolha o Idioma';

  @override
  String get langPortuguese => 'Português (Brasil)';

  @override
  String get langEnglish => 'English';

  @override
  String get langSpanish => 'Español';

  @override
  String get langFrench => 'Français';

  @override
  String get langGerman => 'Deutsch';

  @override
  String get langItalian => 'Italiano';

  @override
  String get langChinese => '中文 (简体)';

  @override
  String get langJapanese => '日本語';

  @override
  String get langRussian => 'Русский';

  @override
  String get langArabic => 'العربية';

  @override
  String get langHindi => 'हिन्दी';

  @override
  String get langSystem => 'System Default / Padrão do Sistema';

  @override
  String get subscriptionTitle => 'Subscription & Referrals';

  @override
  String get subscriptionMonthlyPrice => '\$9.90 / month';

  @override
  String get subscriptionFreeTrial => '7 Days Free Trial';

  @override
  String get subscriptionTrialActive => 'Free Trial Period';

  @override
  String subscriptionTrialDaysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days remaining in trial',
      one: '1 day remaining in trial',
      zero: 'Last day of free trial',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionExpired => 'Trial Period Expired';

  @override
  String get subscriptionExpiredDesc =>
      'To continue using Valora on Android, subscribe for \$9.90/month or invite friends to get free days.';

  @override
  String get subscriptionActive => 'Subscription Active';

  @override
  String get subscribeButton => 'Subscribe for \$9.90 / month';

  @override
  String get referralTitle => 'Refer & Earn (+7 Days)';

  @override
  String get referralDesc =>
      'For every person you invite, you get +7 extra days of free access!';

  @override
  String get referralYourCode => 'Your Referral Code';

  @override
  String get referralEnterCode => 'Enter Referral Code';

  @override
  String get referralEnterCodePrompt =>
      'Enter a friend\'s referral code to get +7 extra days:';

  @override
  String get referralApply => 'Apply Code';

  @override
  String get referralSuccess =>
      'Congratulations! You earned +7 extra days of free access!';

  @override
  String get referralAlreadyUsed =>
      'You have already redeemed this referral code.';

  @override
  String get referralSelfCode => 'You cannot use your own referral code.';

  @override
  String get referralInvalidCode => 'Invalid referral code.';

  @override
  String get referralSimulateInvite => 'Simulate Friend Invited (+7 days)';

  @override
  String get referralShareText => 'Share Invite';

  @override
  String get referralInvitedCount => 'Friends invited';

  @override
  String get referralBonusDaysCount => 'Bonus days earned';
}
