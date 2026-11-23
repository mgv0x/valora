import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Valora'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Waste less. Live better.'**
  String get tagline;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @pantryTitle.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get pantryTitle;

  /// No description provided for @expiryCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Expiry Center'**
  String get expiryCenterTitle;

  /// No description provided for @impactTitle.
  ///
  /// In en, this message translates to:
  /// **'My Impact'**
  String get impactTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @activeItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No active items} =1{1 active item} other{{count} active items}}'**
  String activeItemsCount(int count);

  /// No description provided for @needsAttentionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{None needs attention} =1{1 item needs attention} other{{count} items need attention}}'**
  String needsAttentionCount(int count);

  /// No description provided for @expiringSoonCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{None expiring soon} =1{1 item expiring soon} other{{count} items expiring soon}}'**
  String expiringSoonCount(int count);

  /// No description provided for @priorityItems.
  ///
  /// In en, this message translates to:
  /// **'Priority Items'**
  String get priorityItems;

  /// No description provided for @consumeFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Consume first'**
  String get consumeFirstTitle;

  /// No description provided for @insightNoneUrgent.
  ///
  /// In en, this message translates to:
  /// **'No food needs urgent attention.'**
  String get insightNoneUrgent;

  /// No description provided for @insightExpired.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 food is already expired. Prioritize these items to reduce waste.} other{{count} foods are already expired. Prioritize these items to reduce waste.}}'**
  String insightExpired(int count);

  /// No description provided for @insightExpiringToday.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 food expires today. Prioritize these items to reduce waste.} other{{count} foods expire today. Prioritize these items to reduce waste.}}'**
  String insightExpiringToday(int count);

  /// No description provided for @insightExpiringTomorrow.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This food expires tomorrow.} other{These {count} foods expire tomorrow.}}'**
  String insightExpiringTomorrow(int count);

  /// No description provided for @insightGeneralPriority.
  ///
  /// In en, this message translates to:
  /// **'Prioritize these items to reduce waste.'**
  String get insightGeneralPriority;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High priority'**
  String get priorityHigh;

  /// No description provided for @priorityAttention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get priorityAttention;

  /// No description provided for @priorityOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get priorityOnTrack;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @addFood.
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get addFood;

  /// No description provided for @editFood.
  ///
  /// In en, this message translates to:
  /// **'Edit Food'**
  String get editFood;

  /// No description provided for @foodDetails.
  ///
  /// In en, this message translates to:
  /// **'Food Details'**
  String get foodDetails;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @consume.
  ///
  /// In en, this message translates to:
  /// **'Consume'**
  String get consume;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @markConsumed.
  ///
  /// In en, this message translates to:
  /// **'Mark as Consumed'**
  String get markConsumed;

  /// No description provided for @markDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Mark as Discarded'**
  String get markDiscarded;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @foodName.
  ///
  /// In en, this message translates to:
  /// **'Food Name'**
  String get foodName;

  /// No description provided for @foodNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Organic Milk, Fresh Apples'**
  String get foodNameHint;

  /// No description provided for @foodNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a food name'**
  String get foodNameRequired;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get categoryRequired;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @quantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a quantity greater than 0'**
  String get quantityRequired;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @unknownExpiry.
  ///
  /// In en, this message translates to:
  /// **'Unknown expiry date'**
  String get unknownExpiry;

  /// No description provided for @expiryDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select an expiry date or mark as unknown'**
  String get expiryDateRequired;

  /// No description provided for @purchasePrice.
  ///
  /// In en, this message translates to:
  /// **'Purchase Price'**
  String get purchasePrice;

  /// No description provided for @purchasePriceOptional.
  ///
  /// In en, this message translates to:
  /// **'Purchase Price (optional)'**
  String get purchasePriceOptional;

  /// No description provided for @purchasePriceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Price cannot be negative'**
  String get purchasePriceInvalid;

  /// No description provided for @storageLocation.
  ///
  /// In en, this message translates to:
  /// **'Storage Location'**
  String get storageLocation;

  /// No description provided for @storageLocationOptional.
  ///
  /// In en, this message translates to:
  /// **'Storage Location (optional)'**
  String get storageLocationOptional;

  /// No description provided for @purchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Purchase Date'**
  String get purchaseDate;

  /// No description provided for @purchaseDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Purchase Date (optional)'**
  String get purchaseDateOptional;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Brand, specific shelf, batch, etc.'**
  String get notesHint;

  /// No description provided for @catFruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get catFruits;

  /// No description provided for @catVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get catVegetables;

  /// No description provided for @catDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get catDairy;

  /// No description provided for @catMeatFish.
  ///
  /// In en, this message translates to:
  /// **'Meat & Fish'**
  String get catMeatFish;

  /// No description provided for @catBakery.
  ///
  /// In en, this message translates to:
  /// **'Bakery'**
  String get catBakery;

  /// No description provided for @catPantryStaples.
  ///
  /// In en, this message translates to:
  /// **'Pantry Staples'**
  String get catPantryStaples;

  /// No description provided for @catFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen Foods'**
  String get catFrozen;

  /// No description provided for @catDrinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get catDrinks;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @locRefrigerator.
  ///
  /// In en, this message translates to:
  /// **'Refrigerator'**
  String get locRefrigerator;

  /// No description provided for @locFreezer.
  ///
  /// In en, this message translates to:
  /// **'Freezer'**
  String get locFreezer;

  /// No description provided for @locPantry.
  ///
  /// In en, this message translates to:
  /// **'Pantry'**
  String get locPantry;

  /// No description provided for @locOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get locOther;

  /// No description provided for @unitPiece.
  ///
  /// In en, this message translates to:
  /// **'unit'**
  String get unitPiece;

  /// No description provided for @unitGram.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unitGram;

  /// No description provided for @unitKilogram.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKilogram;

  /// No description provided for @unitMilliliter.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMilliliter;

  /// No description provided for @unitLiter.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get unitLiter;

  /// No description provided for @unitPackage.
  ///
  /// In en, this message translates to:
  /// **'pack'**
  String get unitPackage;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @statusExpiringToday.
  ///
  /// In en, this message translates to:
  /// **'Expires today'**
  String get statusExpiringToday;

  /// No description provided for @statusExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get statusExpiringSoon;

  /// No description provided for @statusFresh.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get statusFresh;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get statusUnknown;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Expires today} =1{1 day left} other{{days} days left}}'**
  String daysLeft(int days);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Expired today} =1{Expired yesterday} other{Expired {days} days ago}}'**
  String daysAgo(int days);

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search food by name...'**
  String get searchPlaceholder;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortExpirySoonest.
  ///
  /// In en, this message translates to:
  /// **'Expiry: Earliest first'**
  String get sortExpirySoonest;

  /// No description provided for @sortExpiryLatest.
  ///
  /// In en, this message translates to:
  /// **'Expiry: Latest first'**
  String get sortExpiryLatest;

  /// No description provided for @sortNameAZ.
  ///
  /// In en, this message translates to:
  /// **'Name: A to Z'**
  String get sortNameAZ;

  /// No description provided for @sortNameZA.
  ///
  /// In en, this message translates to:
  /// **'Name: Z to A'**
  String get sortNameZA;

  /// No description provided for @emptyPantryTitle.
  ///
  /// In en, this message translates to:
  /// **'Your pantry is empty'**
  String get emptyPantryTitle;

  /// No description provided for @emptyPantrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start organizing what you have at home to avoid waste and make better meals.'**
  String get emptyPantrySubtitle;

  /// No description provided for @emptySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'No items match your search'**
  String get emptySearchTitle;

  /// No description provided for @emptySearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try searching for a different keyword or adjusting the filters.'**
  String get emptySearchSubtitle;

  /// No description provided for @emptyExpiryTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything is on track!'**
  String get emptyExpiryTitle;

  /// No description provided for @emptyExpirySubtitle.
  ///
  /// In en, this message translates to:
  /// **'No foods are expired or expiring soon within your current threshold.'**
  String get emptyExpirySubtitle;

  /// No description provided for @emptyImpactTitle.
  ///
  /// In en, this message translates to:
  /// **'No activity recorded yet'**
  String get emptyImpactTitle;

  /// No description provided for @emptyImpactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'As you consume or discard foods, Valora will build genuine insights here.'**
  String get emptyImpactSubtitle;

  /// No description provided for @groupExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get groupExpired;

  /// No description provided for @groupExpiringToday.
  ///
  /// In en, this message translates to:
  /// **'Expiring Today'**
  String get groupExpiringToday;

  /// No description provided for @groupExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring Soon'**
  String get groupExpiringSoon;

  /// No description provided for @groupLater.
  ///
  /// In en, this message translates to:
  /// **'Good for Later'**
  String get groupLater;

  /// No description provided for @groupUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown Expiry'**
  String get groupUnknown;

  /// No description provided for @consumeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Record Consumption'**
  String get consumeDialogTitle;

  /// No description provided for @consumeDialogPrompt.
  ///
  /// In en, this message translates to:
  /// **'How much of this food did you consume?'**
  String get consumeDialogPrompt;

  /// No description provided for @discardDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Record Disposal'**
  String get discardDialogTitle;

  /// No description provided for @discardDialogPrompt.
  ///
  /// In en, this message translates to:
  /// **'How much of this food was discarded?'**
  String get discardDialogPrompt;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get resetFilters;

  /// No description provided for @quantityRemaining.
  ///
  /// In en, this message translates to:
  /// **'Available: {qty} {unit}'**
  String quantityRemaining(String qty, String unit);

  /// No description provided for @quantityOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original: {qty} {unit}'**
  String quantityOriginal(String qty, String unit);

  /// No description provided for @quantityConsumed.
  ///
  /// In en, this message translates to:
  /// **'Consumed: {qty} {unit}'**
  String quantityConsumed(String qty, String unit);

  /// No description provided for @quantityDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Discarded: {qty} {unit}'**
  String quantityDiscarded(String qty, String unit);

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Food Item?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? Historical activity records will be preserved.'**
  String deleteConfirmContent(String name);

  /// No description provided for @actionSuccessSaved.
  ///
  /// In en, this message translates to:
  /// **'Food item saved successfully.'**
  String get actionSuccessSaved;

  /// No description provided for @actionSuccessConsumed.
  ///
  /// In en, this message translates to:
  /// **'Recorded as consumed.'**
  String get actionSuccessConsumed;

  /// No description provided for @actionSuccessDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Recorded as discarded.'**
  String get actionSuccessDiscarded;

  /// No description provided for @actionSuccessDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item removed from active pantry.'**
  String get actionSuccessDeleted;

  /// No description provided for @impactSummary.
  ///
  /// In en, this message translates to:
  /// **'Activity Summary'**
  String get impactSummary;

  /// No description provided for @itemsConsumed.
  ///
  /// In en, this message translates to:
  /// **'Recorded items consumed'**
  String get itemsConsumed;

  /// No description provided for @itemsDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Recorded items discarded'**
  String get itemsDiscarded;

  /// No description provided for @valueConsumed.
  ///
  /// In en, this message translates to:
  /// **'Estimated value consumed'**
  String get valueConsumed;

  /// No description provided for @valueDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Estimated value discarded'**
  String get valueDiscarded;

  /// No description provided for @consumptionRate.
  ///
  /// In en, this message translates to:
  /// **'Consumption rate'**
  String get consumptionRate;

  /// No description provided for @impactDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Metrics are calculated directly from recorded activity. Valora never invents savings or carbon estimates.'**
  String get impactDisclaimer;

  /// No description provided for @impactHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity Log'**
  String get impactHistoryTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsEnableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Expiry Reminders'**
  String get settingsEnableNotifications;

  /// No description provided for @settingsNotificationDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified before food items reach their expiry date.'**
  String get settingsNotificationDesc;

  /// No description provided for @settingsNotificationThreshold.
  ///
  /// In en, this message translates to:
  /// **'Warning threshold'**
  String get settingsNotificationThreshold;

  /// No description provided for @settingsNotificationThresholdDesc.
  ///
  /// In en, this message translates to:
  /// **'Alert me this many days in advance'**
  String get settingsNotificationThresholdDesc;

  /// No description provided for @daysUnit.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysUnit(int count);

  /// No description provided for @settingsDataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get settingsDataManagement;

  /// No description provided for @settingsExportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data (JSON)'**
  String get settingsExportData;

  /// No description provided for @settingsExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully.'**
  String get settingsExportSuccess;

  /// No description provided for @settingsImportData.
  ///
  /// In en, this message translates to:
  /// **'Import Data (JSON)'**
  String get settingsImportData;

  /// No description provided for @settingsImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully.'**
  String get settingsImportSuccess;

  /// No description provided for @settingsImportInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid JSON data file.'**
  String get settingsImportInvalid;

  /// No description provided for @settingsClearData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get settingsClearData;

  /// No description provided for @settingsClearDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All active pantry items and activity history will be deleted.'**
  String get settingsClearDataConfirm;

  /// No description provided for @settingsClearDataSuccess.
  ///
  /// In en, this message translates to:
  /// **'All local data has been erased.'**
  String get settingsClearDataSuccess;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About Valora'**
  String get settingsAbout;

  /// No description provided for @settingsAboutDesc.
  ///
  /// In en, this message translates to:
  /// **'Valora is a clean, offline-first food inventory & expiry tracking application built for the Hack Club Cider challenge.'**
  String get settingsAboutDesc;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data Storage'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacyDesc.
  ///
  /// In en, this message translates to:
  /// **'All your data stays 100% on this device. No trackers, no accounts, no cloud sync.'**
  String get settingsPrivacyDesc;

  /// No description provided for @settingsLicense.
  ///
  /// In en, this message translates to:
  /// **'Open Source License'**
  String get settingsLicense;

  /// No description provided for @settingsLicenseDesc.
  ///
  /// In en, this message translates to:
  /// **'Released under the MIT License.'**
  String get settingsLicenseDesc;

  /// No description provided for @unsavedChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get unsavedChangesTitle;

  /// No description provided for @unsavedChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to exit without saving?'**
  String get unsavedChangesMessage;

  /// No description provided for @expirySafetyDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Expiry Notice & Food Safety'**
  String get expirySafetyDisclaimerTitle;

  /// No description provided for @expirySafetyDisclaimerContent.
  ///
  /// In en, this message translates to:
  /// **'Expiry dates are guidelines for optimal preservation and quality. Always check appearance, aroma, and texture. Foods without an entered expiry date require manual inspection and are never assumed to be automatically safe or expired.'**
  String get expirySafetyDisclaimerContent;

  /// No description provided for @partial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get partial;

  /// No description provided for @quantityExceedsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Cannot exceed remaining quantity ({qty} {unit})'**
  String quantityExceedsRemaining(String qty, String unit);

  /// No description provided for @discardConfirmPermanent.
  ///
  /// In en, this message translates to:
  /// **'Confirm Discard'**
  String get discardConfirmPermanent;

  /// No description provided for @discardConfirmPermanentPrompt.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard {qty} {unit} of \"{name}\"? This action records food waste and cannot be undone.'**
  String discardConfirmPermanentPrompt(String qty, String unit, String name);

  /// No description provided for @consumeNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Prepared dinner, lunchbox'**
  String get consumeNotesHint;

  /// No description provided for @discardNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Spoiled, past date'**
  String get discardNotesHint;

  /// No description provided for @homeNeedsAction.
  ///
  /// In en, this message translates to:
  /// **'Needs Action'**
  String get homeNeedsAction;

  /// No description provided for @homeAddFoodDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep track of new purchases to prevent waste'**
  String get homeAddFoodDesc;

  /// No description provided for @activityDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity Details'**
  String get activityDetailsTitle;

  /// No description provided for @activityDate.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get activityDate;

  /// No description provided for @activityType.
  ///
  /// In en, this message translates to:
  /// **'Action Type'**
  String get activityType;

  /// No description provided for @activityEstimatedValue.
  ///
  /// In en, this message translates to:
  /// **'Estimated Value'**
  String get activityEstimatedValue;

  /// No description provided for @activityValueFormulaNotice.
  ///
  /// In en, this message translates to:
  /// **'Calculated proportionally from entered purchase price.'**
  String get activityValueFormulaNotice;

  /// No description provided for @filterPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get filterPeriod;

  /// No description provided for @filterPeriodAll.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get filterPeriodAll;

  /// No description provided for @filterPeriod7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get filterPeriod7Days;

  /// No description provided for @filterPeriod30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get filterPeriod30Days;

  /// No description provided for @filterType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterType;

  /// No description provided for @filterTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All actions'**
  String get filterTypeAll;

  /// No description provided for @filterTypeConsumed.
  ///
  /// In en, this message translates to:
  /// **'Consumed only'**
  String get filterTypeConsumed;

  /// No description provided for @filterTypeDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Discarded only'**
  String get filterTypeDiscarded;

  /// No description provided for @unitBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Recorded Volume by Unit'**
  String get unitBreakdownTitle;

  /// No description provided for @consumedUnits.
  ///
  /// In en, this message translates to:
  /// **'Consumed'**
  String get consumedUnits;

  /// No description provided for @discardedUnits.
  ///
  /// In en, this message translates to:
  /// **'Discarded'**
  String get discardedUnits;

  /// No description provided for @fromPricedItems.
  ///
  /// In en, this message translates to:
  /// **'From items with purchase prices'**
  String get fromPricedItems;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get themeDark;

  /// No description provided for @themeSystemOption.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystemOption;

  /// No description provided for @themeLightOption.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLightOption;

  /// No description provided for @themeDarkOption.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDarkOption;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get copyToClipboard;

  /// No description provided for @dataCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Data copied to clipboard!'**
  String get dataCopiedToClipboard;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @importPastePrompt.
  ///
  /// In en, this message translates to:
  /// **'Paste your exported Valora JSON backup below:'**
  String get importPastePrompt;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notification permission was not granted by device settings.'**
  String get notificationPermissionDenied;

  /// No description provided for @appVersionDetails.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0 • Hack Club Cider Submission'**
  String get appVersionDetails;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language / Escolha o Idioma'**
  String get selectLanguage;

  /// No description provided for @langPortuguese.
  ///
  /// In en, this message translates to:
  /// **'Português (Brasil)'**
  String get langPortuguese;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get langSpanish;

  /// No description provided for @langFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get langFrench;

  /// No description provided for @langGerman.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get langGerman;

  /// No description provided for @langItalian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get langItalian;

  /// No description provided for @langChinese.
  ///
  /// In en, this message translates to:
  /// **'中文 (简体)'**
  String get langChinese;

  /// No description provided for @langJapanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get langJapanese;

  /// No description provided for @langRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get langRussian;

  /// No description provided for @langArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get langArabic;

  /// No description provided for @langHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get langHindi;

  /// No description provided for @langSystem.
  ///
  /// In en, this message translates to:
  /// **'System Default / Padrão do Sistema'**
  String get langSystem;

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription & Referrals'**
  String get subscriptionTitle;

  /// No description provided for @subscriptionMonthlyPrice.
  ///
  /// In en, this message translates to:
  /// **'\$9.90 / month'**
  String get subscriptionMonthlyPrice;

  /// No description provided for @subscriptionFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'7 Days Free Trial'**
  String get subscriptionFreeTrial;

  /// No description provided for @subscriptionTrialActive.
  ///
  /// In en, this message translates to:
  /// **'Free Trial Period'**
  String get subscriptionTrialActive;

  /// No description provided for @subscriptionTrialDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Last day of free trial} =1{1 day remaining in trial} other{{days} days remaining in trial}}'**
  String subscriptionTrialDaysRemaining(int days);

  /// No description provided for @subscriptionExpired.
  ///
  /// In en, this message translates to:
  /// **'Trial Period Expired'**
  String get subscriptionExpired;

  /// No description provided for @subscriptionExpiredDesc.
  ///
  /// In en, this message translates to:
  /// **'To continue using Valora on Android, subscribe for \$9.90/month or invite friends to get free days.'**
  String get subscriptionExpiredDesc;

  /// No description provided for @subscriptionActive.
  ///
  /// In en, this message translates to:
  /// **'Subscription Active'**
  String get subscriptionActive;

  /// No description provided for @subscribeButton.
  ///
  /// In en, this message translates to:
  /// **'Subscribe for \$9.90 / month'**
  String get subscribeButton;

  /// No description provided for @referralTitle.
  ///
  /// In en, this message translates to:
  /// **'Refer & Earn (+7 Days)'**
  String get referralTitle;

  /// No description provided for @referralDesc.
  ///
  /// In en, this message translates to:
  /// **'For every person you invite, you get +7 extra days of free access!'**
  String get referralDesc;

  /// No description provided for @referralYourCode.
  ///
  /// In en, this message translates to:
  /// **'Your Referral Code'**
  String get referralYourCode;

  /// No description provided for @referralEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Referral Code'**
  String get referralEnterCode;

  /// No description provided for @referralEnterCodePrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter a friend\'s referral code to get +7 extra days:'**
  String get referralEnterCodePrompt;

  /// No description provided for @referralApply.
  ///
  /// In en, this message translates to:
  /// **'Apply Code'**
  String get referralApply;

  /// No description provided for @referralSuccess.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You earned +7 extra days of free access!'**
  String get referralSuccess;

  /// No description provided for @referralAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'You have already redeemed this referral code.'**
  String get referralAlreadyUsed;

  /// No description provided for @referralSelfCode.
  ///
  /// In en, this message translates to:
  /// **'You cannot use your own referral code.'**
  String get referralSelfCode;

  /// No description provided for @referralInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid referral code.'**
  String get referralInvalidCode;

  /// No description provided for @referralSimulateInvite.
  ///
  /// In en, this message translates to:
  /// **'Simulate Friend Invited (+7 days)'**
  String get referralSimulateInvite;

  /// No description provided for @referralShareText.
  ///
  /// In en, this message translates to:
  /// **'Share Invite'**
  String get referralShareText;

  /// No description provided for @referralInvitedCount.
  ///
  /// In en, this message translates to:
  /// **'Friends invited'**
  String get referralInvitedCount;

  /// No description provided for @referralBonusDaysCount.
  ///
  /// In en, this message translates to:
  /// **'Bonus days earned'**
  String get referralBonusDaysCount;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'it',
    'ja',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
