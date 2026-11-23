// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Valora';

  @override
  String get tagline => 'هدر أقل. حياة أفضل.';

  @override
  String get homeTitle => 'الرئيسية';

  @override
  String get pantryTitle => 'المؤونة';

  @override
  String get expiryCenterTitle => 'مركز الصلاحية';

  @override
  String get impactTitle => 'أثري وإنجازاتي';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get greetingMorning => 'صباح الخير';

  @override
  String get greetingAfternoon => 'مساء الخير';

  @override
  String get greetingEvening => 'مساء النور';

  @override
  String activeItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صنف غذائي',
      many: '$count صنفاً غذائياً',
      few: '$count أصناف غذائية',
      two: 'صنفان غذائيان',
      one: 'صنف غذائي واحد',
      zero: 'لا توجد أطعمة في المؤونة',
    );
    return '$_temp0';
  }

  @override
  String needsAttentionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صنف يحتاج إلى الانتباه',
      many: '$count صنفاً يحتاج إلى الانتباه',
      few: '$count أصناف تحتاج إلى الانتباه',
      two: 'صنفان يحتاجان إلى الانتباه',
      one: 'صنف واحد يحتاج إلى الانتباه',
      zero: 'لا توجد عناصر تتطلب الانتباه',
    );
    return '$_temp0';
  }

  @override
  String expiringSoonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صنف ينتهي قريباً',
      many: '$count صنفاً ينتهي قريباً',
      few: '$count أصناف تنتهي قريباً',
      two: 'صنفان ينتهيان قريباً',
      one: 'صنف واحد ينتهي قريباً',
      zero: 'لا توجد عناصر قريبة من الانتهاء',
    );
    return '$_temp0';
  }

  @override
  String get priorityItems => 'أطعمة ذات أولوية';

  @override
  String get consumeFirstTitle => 'استهلكها أولاً';

  @override
  String get insightNoneUrgent =>
      'لا توجد أطعمة تحتاج إلى تصرف عاجل، كل شيء على ما يرام.';

  @override
  String insightExpired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'انتهت صلاحية $count صنف غذائي. ننصح بالفرز للحد من الهدر.',
      many: 'انتهت صلاحية $count صنفاً غذائياً. ننصح بالفرز للحد من الهدر.',
      few: 'انتهت صلاحية $count أصناف غذائية. ننصح بالفرز للحد من الهدر.',
      two: 'انتهت صلاحية صنفين غذائيين. ننصح بمعالجتهما للحد من الهدر.',
      one: 'انتهت صلاحية صنف غذائي واحد. ننصح بمعالجته للحد من الهدر.',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ينتهي $count صنف اليوم. استهلكها أولاً لتجنب الهدر.',
      many: 'ينتهي $count صنفاً اليوم. استهلكها أولاً لتجنب الهدر.',
      few: 'تنتهي $count أصناف اليوم. استهلكها أولاً لتجنب الهدر.',
      two: 'ينتهي صنفان اليوم. استهلكهما ضمن وجبات اليوم.',
      one: 'ينتهي صنف واحد اليوم. استهلكه ضمن وجبات اليوم.',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringTomorrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ينتهي هذا العدد ($count) غداً.',
      many: 'ينتهي هذا العدد ($count) غداً.',
      few: 'تنتهي هذه الأصناف الـ $count غداً.',
      two: 'ينتهي هذان الصنفان غداً.',
      one: 'ينتهي هذا الصنف غداً.',
    );
    return '$_temp0';
  }

  @override
  String get insightGeneralPriority =>
      'امنح هذه الأصناف الأولوية لتقليل هدر الطعام في منزلك.';

  @override
  String get priorityHigh => 'أولوية قصوى';

  @override
  String get priorityAttention => 'انتباه';

  @override
  String get priorityOnTrack => 'سليم';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get addFood => 'إضافة طعام';

  @override
  String get editFood => 'تعديل الطعام';

  @override
  String get foodDetails => 'تفاصيل الطعام';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get confirm => 'تأكيد';

  @override
  String get consume => 'استهلاك';

  @override
  String get discard => 'إتلاف';

  @override
  String get markConsumed => 'تحديد كمستهلك';

  @override
  String get markDiscarded => 'تحديد كتالف ومستبعد';

  @override
  String get all => 'الكل';

  @override
  String get foodName => 'اسم الطعام';

  @override
  String get foodNameHint => 'مثال: حليب عضوي، تفاح طازج';

  @override
  String get foodNameRequired => 'يرجى إدخال اسم الطعام';

  @override
  String get category => 'الفئة';

  @override
  String get categoryRequired => 'يرجى تحديد الفئة';

  @override
  String get quantity => 'الكمية';

  @override
  String get quantityRequired => 'يرجى إدخال كمية أكبر من صفر';

  @override
  String get unit => 'الوحدة';

  @override
  String get expiryDate => 'تاريخ انتهاء الصلاحية';

  @override
  String get unknownExpiry => 'تاريخ الصلاحية غير محدد';

  @override
  String get expiryDateRequired =>
      'يرجى تحديد التاريخ أو الإشارة إلى أنه غير محدد';

  @override
  String get purchasePrice => 'سعر الشراء';

  @override
  String get purchasePriceOptional => 'سعر الشراء (اختياري)';

  @override
  String get purchasePriceInvalid => 'لا يمكن أن يكون السعر سالباً';

  @override
  String get storageLocation => 'مكان الحفظ';

  @override
  String get storageLocationOptional => 'مكان الحفظ (اختياري)';

  @override
  String get purchaseDate => 'تاريخ الشراء';

  @override
  String get purchaseDateOptional => 'تاريخ الشراء (اختياري)';

  @override
  String get notes => 'ملاحظات';

  @override
  String get notesOptional => 'ملاحظات (اختياري)';

  @override
  String get notesHint => 'العلامة التجارية، الرف، رقم الدفعة وغيرها';

  @override
  String get catFruits => 'فواكه';

  @override
  String get catVegetables => 'خضروات';

  @override
  String get catDairy => 'منتجات ألبان';

  @override
  String get catMeatFish => 'لحوم وأسماك';

  @override
  String get catBakery => 'مخبوزات';

  @override
  String get catPantryStaples => 'مؤن أساسية وبقوليات';

  @override
  String get catFrozen => 'أطعمة مجمدة';

  @override
  String get catDrinks => 'مشروبات';

  @override
  String get catOther => 'أخرى';

  @override
  String get locRefrigerator => 'الثلاجة';

  @override
  String get locFreezer => 'المجمد (الفريزر)';

  @override
  String get locPantry => 'خزانة المؤونة';

  @override
  String get locOther => 'مكان آخر';

  @override
  String get unitPiece => 'قطعة';

  @override
  String get unitGram => 'غ';

  @override
  String get unitKilogram => 'كغ';

  @override
  String get unitMilliliter => 'مل';

  @override
  String get unitLiter => 'لتر';

  @override
  String get unitPackage => 'عبوة';

  @override
  String get statusExpired => 'منتهي الصلاحية';

  @override
  String get statusExpiringToday => 'ينتهي اليوم';

  @override
  String get statusExpiringSoon => 'ينتهي قريباً';

  @override
  String get statusFresh => 'طازج وصالح';

  @override
  String get statusUnknown => 'غير محدد';

  @override
  String daysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'متبقي $days يوم',
      many: 'متبقي $days يوماً',
      few: 'متبقي $days أيام',
      two: 'متبقي يومان',
      one: 'متبقي يوم واحد',
      zero: 'ينتهي اليوم',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'انتهى منذ $days يوم',
      many: 'انتهى منذ $days يوماً',
      few: 'انتهى منذ $days أيام',
      two: 'انتهى منذ يومين',
      one: 'انتهى بالأمس',
      zero: 'انتهى اليوم',
    );
    return '$_temp0';
  }

  @override
  String get searchPlaceholder => 'البحث عن صنف بالاسم...';

  @override
  String get filterAll => 'الكل';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get sortExpirySoonest => 'تاريخ الصلاحية: الأقرب أولاً';

  @override
  String get sortExpiryLatest => 'تاريخ الصلاحية: الأبعد أولاً';

  @override
  String get sortNameAZ => 'الاسم: أ إلى ي';

  @override
  String get sortNameZA => 'الاسم: ي إلى أ';

  @override
  String get emptyPantryTitle => 'مؤونتك فارغة حالياً';

  @override
  String get emptyPantrySubtitle =>
      'ابدأ بتنظيم وتوثيق أطعمتك المنزلية لتقليل الهدر والاستفادة القصوى منها.';

  @override
  String get emptySearchTitle => 'لا توجد نتائج مطابقة لبحثك';

  @override
  String get emptySearchSubtitle =>
      'جرب البحث بكلمة مختلفة أو قم بتعديل خيارات التصفية.';

  @override
  String get emptyExpiryTitle => 'كل شيء على خير ما يرام!';

  @override
  String get emptyExpirySubtitle =>
      'لا توجد أطعمة منتهية الصلاحية أو وشيكة الانتهاء في الفترة المحددة.';

  @override
  String get emptyImpactTitle => 'لا توجد سجلات نشاط حتى الآن';

  @override
  String get emptyImpactSubtitle =>
      'عندما تسجل استهلاك الأطعمة أو استبعادها، سيقوم Valora بحساب إحصاءاتك الموثوقة هنا.';

  @override
  String get groupExpired => 'منتهية الصلاحية';

  @override
  String get groupExpiringToday => 'تنتهي اليوم';

  @override
  String get groupExpiringSoon => 'تنتهي قريباً';

  @override
  String get groupLater => 'صلاحية ممتدة';

  @override
  String get groupUnknown => 'صلاحية غير محددة';

  @override
  String get consumeDialogTitle => 'تسجيل استهلاك الطعام';

  @override
  String get consumeDialogPrompt =>
      'ما هي الكمية التي تم استهلاكها من هذا الطعام؟';

  @override
  String get discardDialogTitle => 'تسجيل استبعاد الطعام';

  @override
  String get discardDialogPrompt =>
      'ما هي الكمية التي تم إتلافها أو استبعادها؟';

  @override
  String get resetFilters => 'إعادة ضبط التصفية';

  @override
  String quantityRemaining(String qty, String unit) {
    return 'المتاح: $qty $unit';
  }

  @override
  String quantityOriginal(String qty, String unit) {
    return 'الأصلي: $qty $unit';
  }

  @override
  String quantityConsumed(String qty, String unit) {
    return 'المستهلك: $qty $unit';
  }

  @override
  String quantityDiscarded(String qty, String unit) {
    return 'المستبعد: $qty $unit';
  }

  @override
  String get deleteConfirmTitle => 'حذف صنف الطعام؟';

  @override
  String deleteConfirmContent(String name) {
    return 'هل أنت متأكد من رغبتك في حذف \"$name\"؟ سيتم الاحتفاظ بسجل العمليات السابقة.';
  }

  @override
  String get actionSuccessSaved => 'تم حفظ صنف الطعام بنجاح.';

  @override
  String get actionSuccessConsumed => 'تم تسجيله كمستهلك بنجاح.';

  @override
  String get actionSuccessDiscarded => 'تم تسجيله كمستبعد بنجاح.';

  @override
  String get actionSuccessDeleted => 'تمت إزالة الصنف من قائمة المؤونة.';

  @override
  String get impactSummary => 'ملخص النشاط';

  @override
  String get itemsConsumed => 'عدد الأصناف المستهلكة';

  @override
  String get itemsDiscarded => 'عدد الأصناف المستبعدة';

  @override
  String get valueConsumed => 'القيمة التقديرية للمستهلك';

  @override
  String get valueDiscarded => 'القيمة التقديرية للهدر';

  @override
  String get consumptionRate => 'نسبة الاستهلاك';

  @override
  String get impactDisclaimer =>
      'يتم احتساب كافة المؤشرات من نشاطك الفعلي المسجل. لا يقدم Valora أي أرقام بيئية أو مالية وهمية.';

  @override
  String get impactHistoryTitle => 'سجل العمليات الأخير';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsEnableNotifications => 'تنبيهات اقتراب الصلاحية';

  @override
  String get settingsNotificationDesc =>
      'تلقي تنبيهات على جهازك قبل حلول تاريخ انتهاء الصلاحية.';

  @override
  String get settingsNotificationThreshold => 'مهلة الإنذار المسبق';

  @override
  String get settingsNotificationThresholdDesc =>
      'تنبيهي قبل تاريخ الانتهاء بعدد من الأيام';

  @override
  String daysUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم',
      many: '$count يوماً',
      few: '$count أيام',
      two: 'يومان',
      one: 'يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataManagement => 'إدارة البيانات';

  @override
  String get settingsExportData => 'تصدير البيانات (JSON)';

  @override
  String get settingsExportSuccess => 'تم تصدير البيانات بنجاح.';

  @override
  String get settingsImportData => 'استيراد البيانات (JSON)';

  @override
  String get settingsImportSuccess => 'تم استيراد البيانات بنجاح.';

  @override
  String get settingsImportInvalid => 'ملف بيانات JSON غير صالح.';

  @override
  String get settingsClearData => 'مسح كافة البيانات';

  @override
  String get settingsClearDataConfirm =>
      'لا يمكن التراجع عن هذا الإجراء. سيتم حذف جميع أطعمة المؤونة وسجل النشاط نهائياً.';

  @override
  String get settingsClearDataSuccess => 'تم مسح جميع البيانات المخزنة محلياً.';

  @override
  String get settingsAbout => 'عن تطبيق Valora';

  @override
  String get settingsAboutDesc =>
      'Valora تطبيق أنيق يعمل دون اتصال بالإنترنت لإدارة مخزون الأطعمة ومتابعة الصلاحية، صُمم لتحدي Hack Club Cider.';

  @override
  String get settingsPrivacy => 'الخصوصية وتخزين البيانات';

  @override
  String get settingsPrivacyDesc =>
      'تبقى جميع بياناتك بنسبة 100% على جهازك الشخصي. بدون متتبعات أو حسابات إجبارية أو مزامنة سحابية.';

  @override
  String get settingsLicense => 'ترخيص المصدر المفتوح';

  @override
  String get settingsLicenseDesc => 'صادر بموجب ترخيص MIT مفتوح المصدر.';

  @override
  String get unsavedChangesTitle => 'تجاهل التغييرات؟';

  @override
  String get unsavedChangesMessage =>
      'لديك تغييرات غير محفوظة، هل أنت متأكد من رغبتك في المغادرة دون حفظ؟';

  @override
  String get expirySafetyDisclaimerTitle => 'إشعار الصلاحية وسلامة الغذاء';

  @override
  String get expirySafetyDisclaimerContent =>
      'تاريخ الصلاحية إرشادي لجودة وحفظ الطعام. تحقق دائماً من الرائحة والشكل والملمس. الأطعمة التي ليس لها تاريخ صلاحية تتطلب فحصاً يدوياً ولا تُعتبر صالحة أو فاسدة تلقائياً.';

  @override
  String get partial => 'جزئي';

  @override
  String quantityExceedsRemaining(String qty, String unit) {
    return 'لا يمكن أن تتجاوز الكمية المتبقية ($qty $unit)';
  }

  @override
  String get discardConfirmPermanent => 'تأكيد الاستبعاد';

  @override
  String discardConfirmPermanentPrompt(String qty, String unit, String name) {
    return 'هل أنت متأكد من رغبتك في استبعاد $qty $unit من \"$name\"؟ يتم احتساب هذا الإجراء كطعام مهدور ولا يمكن التراجع عنه.';
  }

  @override
  String get consumeNotesHint => 'مثال: طهي وجبة العشاء، علبة الغداء';

  @override
  String get discardNotesHint => 'مثال: تلف، انتهاء مدة الصلاحية';

  @override
  String get homeNeedsAction => 'يحتاج تصرفاً';

  @override
  String get homeAddFoodDesc =>
      'سجل مشترياتك الجديدة باستمرار لتجنب النسيان والهدر';

  @override
  String get activityDetailsTitle => 'تفاصيل العملية';

  @override
  String get activityDate => 'التاريخ والوقت';

  @override
  String get activityType => 'نوع العملية';

  @override
  String get activityEstimatedValue => 'القيمة التقديرية';

  @override
  String get activityValueFormulaNotice =>
      'محسوبة نسبياً بناءً على سعر الشراء المسجل.';

  @override
  String get filterPeriod => 'الفترة الزمنية';

  @override
  String get filterPeriodAll => 'كافة الأوقات';

  @override
  String get filterPeriod7Days => 'آخر 7 أيام';

  @override
  String get filterPeriod30Days => 'آخر 30 يوماً';

  @override
  String get filterType => 'النوع';

  @override
  String get filterTypeAll => 'جميع العمليات';

  @override
  String get filterTypeConsumed => 'المستهلك فقط';

  @override
  String get filterTypeDiscarded => 'المستبعد فقط';

  @override
  String get unitBreakdownTitle => 'الحجم المسجل بحسب الوحدة';

  @override
  String get consumedUnits => 'المستهلك';

  @override
  String get discardedUnits => 'المستبعد';

  @override
  String get fromPricedItems => 'من العناصر التي تم تحديد سعر شرائها';

  @override
  String get settingsPreferences => 'تفضيلات التطبيق';

  @override
  String get settingsTheme => 'المظهر العام';

  @override
  String get themeSystem => 'متابعة مظهر النظام';

  @override
  String get themeLight => 'المظهر الفاتح';

  @override
  String get themeDark => 'المظهر الداكن';

  @override
  String get themeSystemOption => 'تلقائي';

  @override
  String get themeLightOption => 'فاتح';

  @override
  String get themeDarkOption => 'داكن';

  @override
  String get copyToClipboard => 'نسخ إلى الحافظة';

  @override
  String get dataCopiedToClipboard => 'تم نسخ البيانات إلى الحافظة!';

  @override
  String exportFailed(String error) {
    return 'فشل التصدير: $error';
  }

  @override
  String get importPastePrompt =>
      'الصق نسخة Valora الاحتياطية بصيغة JSON أدناه:';

  @override
  String get notificationPermissionDenied =>
      'لم يتم منح إذن الإشعارات من إعدادات النظام.';

  @override
  String get appVersionDetails =>
      'الإصدار 1.0.0 • مشاركة مسابقة Hack Club Cider';

  @override
  String get selectLanguage => 'اختيار اللغة / Select Language';

  @override
  String get langPortuguese => 'Português (البرتغالية/البرازيل)';

  @override
  String get langEnglish => 'English (الإنجليزية)';

  @override
  String get langSpanish => 'Español (الإسبانية)';

  @override
  String get langFrench => 'Français (الفرنسية)';

  @override
  String get langGerman => 'Deutsch (الألمانية)';

  @override
  String get langItalian => 'Italiano (الإيطالية)';

  @override
  String get langChinese => '中文 (الصينية المبسطة)';

  @override
  String get langJapanese => '日本語 (اليابانية)';

  @override
  String get langRussian => 'Русский (الروسية)';

  @override
  String get langArabic => 'العربية';

  @override
  String get langHindi => 'हिन्दी (الهندية)';

  @override
  String get langSystem => 'افتراضي الجهاز / System Default';

  @override
  String get subscriptionTitle => 'الاشتراك ودعوة الأصدقاء';

  @override
  String get subscriptionMonthlyPrice => '\$9.90 / شهرياً';

  @override
  String get subscriptionFreeTrial => 'فترة تجريبية مجانية لمدة 7 أيام';

  @override
  String get subscriptionTrialActive => 'الفترة التجريبية المجانية';

  @override
  String subscriptionTrialDaysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'متبقي $days يوم في الفترة التجريبية',
      many: 'متبقي $days يوماً في الفترة التجريبية',
      few: 'متبقي $days أيام في الفترة التجريبية',
      two: 'متبقي يومان في الفترة التجريبية',
      one: 'متبقي يوم واحد في الفترة التجريبية',
      zero: 'آخر يوم في الفترة التجريبية',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionExpired => 'انتهت الفترة التجريبية';

  @override
  String get subscriptionExpiredDesc =>
      'لمواصلة استخدام تطبيق Valora على أندرويد، اشترك مقابل \$9.90 شهرياً أو ادعُ أصدقاءك للحصول على أيام مجانية إضافية.';

  @override
  String get subscriptionActive => 'الاشتراك مفعل';

  @override
  String get subscribeButton => 'الاشتراك مقابل \$9.90 شهرياً';

  @override
  String get referralTitle => 'ادعُ الأصدقاء واربح (+7 أيام)';

  @override
  String get referralDesc =>
      'لكل صديق تدعوه، تحصل على +7 أيام إضافية من الاستخدام المجاني الكامل!';

  @override
  String get referralYourCode => 'رمز الإحالة الخاص بك';

  @override
  String get referralEnterCode => 'إدخال رمز الإحالة';

  @override
  String get referralEnterCodePrompt =>
      'أدخل رمز إحالة صديقك للحصول على +7 أيام مجانية إضافية:';

  @override
  String get referralApply => 'تطبيق الرمز';

  @override
  String get referralSuccess =>
      'تهانينا! حصلت على +7 أيام إضافية من الاستخدام المجاني!';

  @override
  String get referralAlreadyUsed => 'لقد قمت باستخدام رمز الإحالة هذا مسبقاً.';

  @override
  String get referralSelfCode => 'لا يمكنك استخدام رمز الإحالة الخاص بك.';

  @override
  String get referralInvalidCode => 'رمز إحالة غير صالح.';

  @override
  String get referralSimulateInvite => 'محاكاة دعوة صديق (+7 أيام)';

  @override
  String get referralShareText => 'مشاركة الدعوة';

  @override
  String get referralInvitedCount => 'الأصدقاء المدعوون';

  @override
  String get referralBonusDaysCount => 'أيام المكافأة المكتسبة';
}
