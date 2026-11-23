// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Valora';

  @override
  String get tagline => 'कम बर्बादी। बेहतर जीवन।';

  @override
  String get homeTitle => 'होम';

  @override
  String get pantryTitle => 'रसोई भंडार';

  @override
  String get expiryCenterTitle => 'समाप्ति केंद्र';

  @override
  String get impactTitle => 'मेरा प्रभाव';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get greetingMorning => 'सुप्रभात';

  @override
  String get greetingAfternoon => 'शुभ दोपहर';

  @override
  String get greetingEvening => 'शुभ संध्या';

  @override
  String activeItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count उपलब्ध खाद्य सामग्रियां',
      one: '1 उपलब्ध खाद्य सामग्री',
      zero: 'कोई खाद्य सामग्री नहीं',
    );
    return '$_temp0';
  }

  @override
  String needsAttentionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सामग्रियों पर ध्यान देने की आवश्यकता है',
      one: '1 सामग्री पर ध्यान देने की आवश्यकता है',
      zero: 'किसी पर ध्यान देने की आवश्यकता नहीं',
    );
    return '$_temp0';
  }

  @override
  String expiringSoonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सामग्रियां जल्द समाप्त होने वाली हैं',
      one: '1 सामग्री जल्द समाप्त होने वाली है',
      zero: 'कोई जल्द समाप्त नहीं हो रहा',
    );
    return '$_temp0';
  }

  @override
  String get priorityItems => 'प्राथमिकता वाली सामग्रियां';

  @override
  String get consumeFirstTitle => 'पहले उपभोग करें';

  @override
  String get insightNoneUrgent =>
      'वर्तमान में किसी खाद्य सामग्री पर तत्काल ध्यान देने की आवश्यकता नहीं है।';

  @override
  String insightExpired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count खाद्य सामग्रियों की समय सीमा समाप्त हो चुकी है। बर्बादी रोकने के लिए इन्हें प्राथमिकता दें।',
      one:
          '1 खाद्य सामग्री की समय सीमा समाप्त हो चुकी है। बर्बादी रोकने के लिए इसे प्राथमिकता दें।',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count खाद्य सामग्रियों की मियाद आज समाप्त हो रही है। कृपया इन्हें आज ही उपयोग करें।',
      one:
          '1 खाद्य सामग्री की मियाद आज समाप्त हो रही है। कृपया इसे आज ही उपयोग करें।',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringTomorrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ये $count सामग्रियां कल समाप्त हो रही हैं।',
      one: 'यह सामग्री कल समाप्त हो रही है।',
    );
    return '$_temp0';
  }

  @override
  String get insightGeneralPriority =>
      'भोजन की बर्बादी कम करने के लिए इन सामग्रियों को पहले इस्तेमाल करें।';

  @override
  String get priorityHigh => 'उच्च प्राथमिकता';

  @override
  String get priorityAttention => 'ध्यान दें';

  @override
  String get priorityOnTrack => 'सुरक्षित';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get addFood => 'खाद्य सामग्री जोड़ें';

  @override
  String get editFood => 'सामग्री संपादित करें';

  @override
  String get foodDetails => 'सामग्री का विवरण';

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get consume => 'उपभोग करें';

  @override
  String get discard => 'त्यागें';

  @override
  String get markConsumed => 'उपभोग किया गया चिह्नित करें';

  @override
  String get markDiscarded => 'त्यागा गया चिह्नित करें';

  @override
  String get all => 'सभी';

  @override
  String get foodName => 'खाद्य सामग्री का नाम';

  @override
  String get foodNameHint => 'उदा. जैविक दूध, ताजे सेब';

  @override
  String get foodNameRequired => 'कृपया खाद्य सामग्री का नाम दर्ज करें';

  @override
  String get category => 'श्रेणी';

  @override
  String get categoryRequired => 'कृपया एक श्रेणी चुनें';

  @override
  String get quantity => 'मात्रा';

  @override
  String get quantityRequired => 'कृपया 0 से अधिक मात्रा दर्ज करें';

  @override
  String get unit => 'इकाई';

  @override
  String get expiryDate => 'समाप्ति तिथि';

  @override
  String get unknownExpiry => 'अज्ञात समाप्ति तिथि';

  @override
  String get expiryDateRequired =>
      'कृपया समाप्ति तिथि चुनें या अज्ञात चिह्नित करें';

  @override
  String get purchasePrice => 'खरीद मूल्य';

  @override
  String get purchasePriceOptional => 'खरीद मूल्य (वैकल्पिक)';

  @override
  String get purchasePriceInvalid => 'मूल्य नकारात्मक नहीं हो सकता';

  @override
  String get storageLocation => 'भंडारण स्थान';

  @override
  String get storageLocationOptional => 'भंडारण स्थान (वैकल्पिक)';

  @override
  String get purchaseDate => 'खरीद तिथि';

  @override
  String get purchaseDateOptional => 'खरीद तिथि (वैकल्पिक)';

  @override
  String get notes => 'टिप्पणियाँ';

  @override
  String get notesOptional => 'टिप्पणियाँ (वैकल्पिक)';

  @override
  String get notesHint => 'ब्रांड, रैक, बैच संख्या आदि';

  @override
  String get catFruits => 'फल';

  @override
  String get catVegetables => 'सब्जियां';

  @override
  String get catDairy => 'डेयरी उत्पाद';

  @override
  String get catMeatFish => 'मांस और मछली';

  @override
  String get catBakery => 'बेकरी और ब्रेड';

  @override
  String get catPantryStaples => 'किराना और अनाज';

  @override
  String get catFrozen => 'जमे हुए खाद्य पदार्थ';

  @override
  String get catDrinks => 'पेय पदार्थ';

  @override
  String get catOther => 'अन्य';

  @override
  String get locRefrigerator => 'फ्रिज';

  @override
  String get locFreezer => 'फ्रीजर';

  @override
  String get locPantry => 'रसोई भंडार';

  @override
  String get locOther => 'अन्य स्थान';

  @override
  String get unitPiece => 'नग/इकाई';

  @override
  String get unitGram => 'ग्राम';

  @override
  String get unitKilogram => 'किग्रा';

  @override
  String get unitMilliliter => 'मिली';

  @override
  String get unitLiter => 'लीटर';

  @override
  String get unitPackage => 'पैकेट';

  @override
  String get statusExpired => 'समाप्त हो चुका';

  @override
  String get statusExpiringToday => 'आज समाप्त हो रहा';

  @override
  String get statusExpiringSoon => 'जल्द समाप्त होगा';

  @override
  String get statusFresh => 'ताजा और सुरक्षित';

  @override
  String get statusUnknown => 'अज्ञात स्थिति';

  @override
  String daysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिन शेष',
      one: '1 दिन शेष',
      zero: 'आज समाप्त हो रहा है',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days दिन पहले समाप्त हुआ',
      one: 'कल समाप्त हुआ',
      zero: 'आज समाप्त हुआ',
    );
    return '$_temp0';
  }

  @override
  String get searchPlaceholder => 'नाम से खाद्य सामग्री खोजें...';

  @override
  String get filterAll => 'सभी';

  @override
  String get sortBy => 'क्रमबद्ध करें';

  @override
  String get sortExpirySoonest => 'समाप्ति: पहले समाप्त होने वाले';

  @override
  String get sortExpiryLatest => 'समाप्ति: बाद में समाप्त होने वाले';

  @override
  String get sortNameAZ => 'नाम: अ से ज्ञ';

  @override
  String get sortNameZA => 'नाम: ज्ञ से अ';

  @override
  String get emptyPantryTitle => 'आपका रसोई भंडार खाली है';

  @override
  String get emptyPantrySubtitle =>
      'भोजन की बर्बादी रोकने और बेहतर भोजन बनाने के लिए अपनी घरेलू सामग्रियों को जोड़ना शुरू करें।';

  @override
  String get emptySearchTitle =>
      'आपकी खोज से मेल खाने वाली कोई सामग्री नहीं मिली';

  @override
  String get emptySearchSubtitle =>
      'कृपया कोई अन्य शब्द खोजें या फ़िल्टर समायोजित करें।';

  @override
  String get emptyExpiryTitle => 'सब कुछ नियंत्रण में है!';

  @override
  String get emptyExpirySubtitle =>
      'वर्तमान समय सीमा में कोई भी सामग्री समाप्त या जल्द समाप्त होने वाली नहीं है।';

  @override
  String get emptyImpactTitle => 'अभी तक कोई गतिविधि दर्ज नहीं की गई';

  @override
  String get emptyImpactSubtitle =>
      'जैसे ही आप सामग्रियों का उपभोग या त्याग दर्ज करेंगे, Valora यहां वास्तविक आंकड़े तैयार करेगा।';

  @override
  String get groupExpired => 'समाप्त हो चुके';

  @override
  String get groupExpiringToday => 'आज समाप्त हो रहे';

  @override
  String get groupExpiringSoon => 'जल्द समाप्त होने वाले';

  @override
  String get groupLater => 'पर्याप्त समय शेष';

  @override
  String get groupUnknown => 'अज्ञात समाप्ति';

  @override
  String get consumeDialogTitle => 'उपभोग दर्ज करें';

  @override
  String get consumeDialogPrompt => 'आपने इस सामग्री का कितना उपभोग किया?';

  @override
  String get discardDialogTitle => 'त्याग दर्ज करें';

  @override
  String get discardDialogPrompt => 'इस सामग्री की कितनी मात्रा व्यर्थ गई?';

  @override
  String get resetFilters => 'फ़िल्टर रीसेट करें';

  @override
  String quantityRemaining(String qty, String unit) {
    return 'उपलब्ध: $qty $unit';
  }

  @override
  String quantityOriginal(String qty, String unit) {
    return 'प्रारंभिक: $qty $unit';
  }

  @override
  String quantityConsumed(String qty, String unit) {
    return 'उपभोग किया: $qty $unit';
  }

  @override
  String quantityDiscarded(String qty, String unit) {
    return 'त्यागा गया: $qty $unit';
  }

  @override
  String get deleteConfirmTitle => 'खाद्य सामग्री हटाएं?';

  @override
  String deleteConfirmContent(String name) {
    return 'क्या आप वाकई \"$name\" को हटाना चाहते हैं? ऐतिहासिक गतिविधियों का रिकॉर्ड सुरक्षित रहेगा।';
  }

  @override
  String get actionSuccessSaved => 'खाद्य सामग्री सफलतापूर्वक सहेजी गई।';

  @override
  String get actionSuccessConsumed => 'उपभोग के रूप में दर्ज किया गया।';

  @override
  String get actionSuccessDiscarded => 'त्याग के रूप में दर्ज किया गया।';

  @override
  String get actionSuccessDeleted => 'सामग्री भंडार से हटा दी गई।';

  @override
  String get impactSummary => 'गतिविधि सारांश';

  @override
  String get itemsConsumed => 'उपभोग की गई सामग्रियां';

  @override
  String get itemsDiscarded => 'व्यर्थ हुई सामग्रियां';

  @override
  String get valueConsumed => 'उपभोग किया गया अनुमानित मूल्य';

  @override
  String get valueDiscarded => 'व्यर्थ हुआ अनुमानित मूल्य';

  @override
  String get consumptionRate => 'उपभोग दर';

  @override
  String get impactDisclaimer =>
      'सभी आंकड़े आपके वास्तविक दर्ज रिकॉर्ड से गणना किए जाते हैं। Valora कोई मनगढ़ंत बचत या आंकड़े नहीं दिखाता।';

  @override
  String get impactHistoryTitle => 'हाल की गतिविधि लॉग';

  @override
  String get settingsLanguage => 'भाषा (Language)';

  @override
  String get settingsNotifications => 'सूचनाएं';

  @override
  String get settingsEnableNotifications => 'समाप्ति अनुस्मारक';

  @override
  String get settingsNotificationDesc =>
      'खाद्य सामग्री की मियाद समाप्त होने से पहले सूचना प्राप्त करें।';

  @override
  String get settingsNotificationThreshold => 'चेतावनी सीमा';

  @override
  String get settingsNotificationThresholdDesc =>
      'समाप्ति से कितने दिन पहले सूचित करें';

  @override
  String daysUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन',
      one: '1 दिन',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataManagement => 'डेटा प्रबंधन';

  @override
  String get settingsExportData => 'डेटा निर्यात करें (JSON)';

  @override
  String get settingsExportSuccess => 'डेटा सफलतापूर्वक निर्यात किया गया।';

  @override
  String get settingsImportData => 'डेटा आयात करें (JSON)';

  @override
  String get settingsImportSuccess => 'डेटा सफलतापूर्वक आयात किया गया।';

  @override
  String get settingsImportInvalid => 'अमान्य JSON डेटा फ़ाइल।';

  @override
  String get settingsClearData => 'सभी डेटा साफ़ करें';

  @override
  String get settingsClearDataConfirm =>
      'यह क्रिया पूर्ववत नहीं की जा सकती। भंडार की सभी सामग्रियां और पिछला इतिहास हमेशा के लिए हटा दिया जाएगा।';

  @override
  String get settingsClearDataSuccess => 'सभी स्थानीय डेटा मिटा दिया गया है।';

  @override
  String get settingsAbout => 'Valora के बारे में';

  @override
  String get settingsAboutDesc =>
      'Valora एक स्वच्छ, ऑफलाइन-प्राथमिक खाद्य सूची और समाप्ति ट्रैकिंग ऐप है, जिसे Hack Club Cider चुनौती के लिए बनाया गया है।';

  @override
  String get settingsPrivacy => 'गोपनीयता और डेटा भंडारण';

  @override
  String get settingsPrivacyDesc =>
      'आपका सारा डेटा 100% आपके डिवाइस पर ही सुरक्षित रहता है। कोई ट्रैकर नहीं, कोई खाता आवश्यक नहीं, कोई क्लाउड बाध्यता नहीं।';

  @override
  String get settingsLicense => 'ओपन सोर्स लाइसेंस';

  @override
  String get settingsLicenseDesc => 'MIT लाइसेंस के तहत जारी किया गया।';

  @override
  String get unsavedChangesTitle => 'परिवर्तन छोड़ें?';

  @override
  String get unsavedChangesMessage =>
      'आपके पास असहेजे गए परिवर्तन हैं। क्या आप बिना सहेजे बाहर निकलना चाहते हैं?';

  @override
  String get expirySafetyDisclaimerTitle => 'समाप्ति सूचना एवं खाद्य सुरक्षा';

  @override
  String get expirySafetyDisclaimerContent =>
      'समाप्ति तिथियां गुणवत्ता और ताजगी के लिए दिशानिर्देश हैं। हमेशा भोजन की गंध, रूप और बनावट की जांच करें। जिन सामग्रियों की समाप्ति तिथि दर्ज नहीं है, उन्हें मैन्युअल रूप से जांचना आवश्यक है।';

  @override
  String get partial => 'आंशिक';

  @override
  String quantityExceedsRemaining(String qty, String unit) {
    return 'शेष मात्रा ($qty $unit) से अधिक नहीं हो सकता';
  }

  @override
  String get discardConfirmPermanent => 'त्यागने की पुष्टि करें';

  @override
  String discardConfirmPermanentPrompt(String qty, String unit, String name) {
    return 'क्या आप वाकई \"$name\" की $qty $unit मात्रा को त्यागना चाहते हैं? यह क्रिया भोजन की बर्बादी के रूप में दर्ज की जाएगी और इसे बदला नहीं जा सकता।';
  }

  @override
  String get consumeNotesHint => 'उदा. रात का खाना बनाया, टिफिन पैक किया';

  @override
  String get discardNotesHint => 'उदा. खराब हो गया, तारीख निकल गई';

  @override
  String get homeNeedsAction => 'कार्रवाई आवश्यक';

  @override
  String get homeAddFoodDesc =>
      'बर्बादी रोकने के लिए नई खरीदारी तुरंत दर्ज करें';

  @override
  String get activityDetailsTitle => 'गतिविधि का विवरण';

  @override
  String get activityDate => 'दिनांक और समय';

  @override
  String get activityType => 'कार्रवाई का प्रकार';

  @override
  String get activityEstimatedValue => 'अनुमानित मूल्य';

  @override
  String get activityValueFormulaNotice =>
      'दर्ज किए गए खरीद मूल्य से आनुपातिक रूप से गणना की गई।';

  @override
  String get filterPeriod => 'अवधि';

  @override
  String get filterPeriodAll => 'संपूर्ण समय';

  @override
  String get filterPeriod7Days => 'पिछले 7 दिन';

  @override
  String get filterPeriod30Days => 'पिछले 30 दिन';

  @override
  String get filterType => 'प्रकार';

  @override
  String get filterTypeAll => 'सभी कार्रवाइयां';

  @override
  String get filterTypeConsumed => 'केवल उपभोग किया गया';

  @override
  String get filterTypeDiscarded => 'केवल त्यागा गया';

  @override
  String get unitBreakdownTitle => 'इकाई द्वारा दर्ज मात्रा';

  @override
  String get consumedUnits => 'उपभोग किया गया';

  @override
  String get discardedUnits => 'व्यर्थ हुआ';

  @override
  String get fromPricedItems => 'मूल्य दर्ज की गई सामग्रियों से';

  @override
  String get settingsPreferences => 'प्राथमिकताएं';

  @override
  String get settingsTheme => 'थीम (दिखावट)';

  @override
  String get themeSystem => 'सिस्टम के अनुसार';

  @override
  String get themeLight => 'लाइट मोड';

  @override
  String get themeDark => 'डार्क मोड';

  @override
  String get themeSystemOption => 'सिस्टम';

  @override
  String get themeLightOption => 'लाइट';

  @override
  String get themeDarkOption => 'डार्क';

  @override
  String get copyToClipboard => 'क्लिपबोर्ड पर कॉपी करें';

  @override
  String get dataCopiedToClipboard => 'डेटा क्लिपबोर्ड पर कॉपी हो गया!';

  @override
  String exportFailed(String error) {
    return 'निर्यात विफल: $error';
  }

  @override
  String get importPastePrompt =>
      'नीचे अपना निर्यात किया गया Valora JSON बैकअप पेस्ट करें:';

  @override
  String get notificationPermissionDenied =>
      'डिवाइस सेटिंग्स में सूचना अनुमति नहीं दी गई थी।';

  @override
  String get appVersionDetails => 'संस्करण 1.0.0 • Hack Club Cider प्रस्तुति';

  @override
  String get selectLanguage => 'भाषा चुनें / Select Language';

  @override
  String get langPortuguese => 'Português (पुर्तगाली/ब्राजील)';

  @override
  String get langEnglish => 'English (अंग्रेजी)';

  @override
  String get langSpanish => 'Español (स्पैनिश)';

  @override
  String get langFrench => 'Français (फ्रेंच)';

  @override
  String get langGerman => 'Deutsch (जर्मन)';

  @override
  String get langItalian => 'Italiano (इतालवी)';

  @override
  String get langChinese => '中文 (चीनी सरलीकृत)';

  @override
  String get langJapanese => '日本語 (जापानी)';

  @override
  String get langRussian => 'Русский (रूसी)';

  @override
  String get langArabic => 'العربية (अरबी)';

  @override
  String get langHindi => 'हिन्दी';

  @override
  String get langSystem => 'सिस्टम डिफ़ॉल्ट / System Default';

  @override
  String get subscriptionTitle => 'सदस्यता और रेफरल';

  @override
  String get subscriptionMonthlyPrice => '₹799 / माह';

  @override
  String get subscriptionFreeTrial => '7 दिनों का निःशुल्क परीक्षण';

  @override
  String get subscriptionTrialActive => 'निःशुल्क परीक्षण अवधि';

  @override
  String subscriptionTrialDaysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'परीक्षण में $days दिन शेष',
      one: 'परीक्षण में 1 दिन शेष',
      zero: 'निःशुल्क परीक्षण का अंतिम दिन',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionExpired => 'परीक्षण अवधि समाप्त';

  @override
  String get subscriptionExpiredDesc =>
      'Android पर Valora का उपयोग जारी रखने के लिए, ₹799/माह पर सदस्यता लें या मित्रों को आमंत्रित करके निःशुल्क दिन प्राप्त करें।';

  @override
  String get subscriptionActive => 'सदस्यता सक्रिय है';

  @override
  String get subscribeButton => '₹799 / माह पर सदस्यता लें';

  @override
  String get referralTitle => 'मित्रों को जोड़ें और कमाएं (+7 दिन)';

  @override
  String get referralDesc =>
      'प्रत्येक आमंत्रित मित्र के लिए, आपको +7 अतिरिक्त दिनों की निःशुल्क पहुंच मिलती है!';

  @override
  String get referralYourCode => 'आपका रेफरल कोड';

  @override
  String get referralEnterCode => 'रेफरल कोड दर्ज करें';

  @override
  String get referralEnterCodePrompt =>
      '+7 अतिरिक्त दिन पाने के लिए मित्र का रेफरल कोड दर्ज करें:';

  @override
  String get referralApply => 'कोड लागू करें';

  @override
  String get referralSuccess =>
      'बधाई हो! आपने +7 अतिरिक्त दिनों का निःशुल्क उपयोग अर्जित किया!';

  @override
  String get referralAlreadyUsed =>
      'आप पहले ही इस रेफरल कोड का उपयोग कर चुके हैं।';

  @override
  String get referralSelfCode =>
      'आप अपने स्वयं के रेफरल कोड का उपयोग नहीं कर सकते।';

  @override
  String get referralInvalidCode => 'अमान्य रेफरल कोड।';

  @override
  String get referralSimulateInvite => 'मित्र आमंत्रण सिम्युलेट करें (+7 दिन)';

  @override
  String get referralShareText => 'आमंत्रण साझा करें';

  @override
  String get referralInvitedCount => 'आमंत्रित किए गए मित्र';

  @override
  String get referralBonusDaysCount => 'अर्जित बोनस दिन';
}
