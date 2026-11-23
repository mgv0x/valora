// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Valora';

  @override
  String get tagline => 'Меньше отходов. Лучше жизнь.';

  @override
  String get homeTitle => 'Главная';

  @override
  String get pantryTitle => 'Кладовая';

  @override
  String get expiryCenterTitle => 'Сроки годности';

  @override
  String get impactTitle => 'Мой вклад';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get greetingMorning => 'Доброе утро';

  @override
  String get greetingAfternoon => 'Добрый день';

  @override
  String get greetingEvening => 'Добрый вечер';

  @override
  String activeItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count продуктов в запасе',
      many: '$count продуктов в запасе',
      few: '$count продукта в запасе',
      one: '1 продукт в запасе',
      zero: 'Нет продуктов в запасе',
    );
    return '$_temp0';
  }

  @override
  String needsAttentionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count продуктов требуют внимания',
      many: '$count продуктов требуют внимания',
      few: '$count продукта требуют внимания',
      one: '1 продукт требует внимания',
      zero: 'Все продукты в порядке',
    );
    return '$_temp0';
  }

  @override
  String expiringSoonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'У $count продуктов скоро истекает срок',
      many: 'У $count продуктов скоро истекает срок',
      few: 'У $count продуктов скоро истекает срок',
      one: 'У 1 продукта скоро истекает срок',
      zero: 'Нет продуктов на исходе',
    );
    return '$_temp0';
  }

  @override
  String get priorityItems => 'Приоритетные продукты';

  @override
  String get consumeFirstTitle => 'Употребить в первую очередь';

  @override
  String get insightNoneUrgent => 'Срочных продуктов нет, всё под контролем.';

  @override
  String insightExpired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count продуктов уже просрочены. Разберите эти запасы, чтобы сократить пищевые отходы.',
      many:
          '$count продуктов уже просрочены. Разберите эти запасы, чтобы сократить пищевые отходы.',
      few:
          '$count продукта уже просрочены. Разберите эти запасы, чтобы сократить пищевые отходы.',
      one:
          '1 продукт уже просрочен. Разберите эти запасы, чтобы сократить пищевые отходы.',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'У $count продуктов срок годности истекает сегодня. Рекомендуем использовать их в первую очередь.',
      many:
          'У $count продуктов срок годности истекает сегодня. Рекомендуем использовать их в первую очередь.',
      few:
          'У $count продуктов срок годности истекает сегодня. Рекомендуем использовать их в первую очередь.',
      one:
          'У 1 продукта срок годности истекает сегодня. Рекомендуем использовать его в первую очередь.',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringTomorrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'У этих $count продуктов срок истекает завтра.',
      many: 'У этих $count продуктов срок истекает завтра.',
      few: 'У этих $count продуктов срок истекает завтра.',
      one: 'У этого продукта срок истекает завтра.',
    );
    return '$_temp0';
  }

  @override
  String get insightGeneralPriority =>
      'Употребите эти продукты в первую очередь, чтобы избежать пищевых потерь.';

  @override
  String get priorityHigh => 'Высокий приоритет';

  @override
  String get priorityAttention => 'Внимание';

  @override
  String get priorityOnTrack => 'В норме';

  @override
  String get viewAll => 'Смотреть все';

  @override
  String get addFood => 'Добавить продукт';

  @override
  String get editFood => 'Редактировать продукт';

  @override
  String get foodDetails => 'Карточка продукта';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get consume => 'Употребить';

  @override
  String get discard => 'Выбросить';

  @override
  String get markConsumed => 'Отметить как съеденное';

  @override
  String get markDiscarded => 'Отметить как выброшенное';

  @override
  String get all => 'Все';

  @override
  String get foodName => 'Название продукта';

  @override
  String get foodNameHint => 'напр., Органическое молоко, Свежие яблоки';

  @override
  String get foodNameRequired => 'Пожалуйста, укажите название продукта';

  @override
  String get category => 'Категория';

  @override
  String get categoryRequired => 'Пожалуйста, выберите категорию';

  @override
  String get quantity => 'Количество';

  @override
  String get quantityRequired => 'Укажите количество больше 0';

  @override
  String get unit => 'Ед. изм.';

  @override
  String get expiryDate => 'Срок годности';

  @override
  String get unknownExpiry => 'Срок неизвестен';

  @override
  String get expiryDateRequired =>
      'Укажите срок годности или отметьте как неизвестный';

  @override
  String get purchasePrice => 'Цена покупки';

  @override
  String get purchasePriceOptional => 'Цена покупки (необязательно)';

  @override
  String get purchasePriceInvalid => 'Цена не может быть отрицательной';

  @override
  String get storageLocation => 'Место хранения';

  @override
  String get storageLocationOptional => 'Место хранения (необязательно)';

  @override
  String get purchaseDate => 'Дата покупки';

  @override
  String get purchaseDateOptional => 'Дата покупки (необязательно)';

  @override
  String get notes => 'Заметки';

  @override
  String get notesOptional => 'Заметки (необязательно)';

  @override
  String get notesHint => 'Бренд, полка, номер партии и т.д.';

  @override
  String get catFruits => 'Фрукты';

  @override
  String get catVegetables => 'Овощи';

  @override
  String get catDairy => 'Молочные продукты';

  @override
  String get catMeatFish => 'Мясо и рыба';

  @override
  String get catBakery => 'Выпечка и хлеб';

  @override
  String get catPantryStaples => 'Бакалея и крупы';

  @override
  String get catFrozen => 'Заморозка';

  @override
  String get catDrinks => 'Напитки';

  @override
  String get catOther => 'Другое';

  @override
  String get locRefrigerator => 'Холодильник';

  @override
  String get locFreezer => 'Морозильная камера';

  @override
  String get locPantry => 'Кладовая / шкаф';

  @override
  String get locOther => 'Другое место';

  @override
  String get unitPiece => 'шт.';

  @override
  String get unitGram => 'г';

  @override
  String get unitKilogram => 'кг';

  @override
  String get unitMilliliter => 'мл';

  @override
  String get unitLiter => 'л';

  @override
  String get unitPackage => 'упак.';

  @override
  String get statusExpired => 'Просрочено';

  @override
  String get statusExpiringToday => 'Истекает сегодня';

  @override
  String get statusExpiringSoon => 'Скоро истекает';

  @override
  String get statusFresh => 'Свежее';

  @override
  String get statusUnknown => 'Срок не указан';

  @override
  String daysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Осталось $days дней',
      many: 'Осталось $days дней',
      few: 'Осталось $days дня',
      one: 'Остался 1 день',
      zero: 'Истекает сегодня',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Срок истек $days дней назад',
      many: 'Срок истек $days дней назад',
      few: 'Срок истек $days дня назад',
      one: 'Срок истек вчера',
      zero: 'Срок истек сегодня',
    );
    return '$_temp0';
  }

  @override
  String get searchPlaceholder => 'Поиск по названию продукта...';

  @override
  String get filterAll => 'Все';

  @override
  String get sortBy => 'Сортировка';

  @override
  String get sortExpirySoonest => 'Срок: сначала ранние';

  @override
  String get sortExpiryLatest => 'Срок: сначала поздние';

  @override
  String get sortNameAZ => 'По названию: А-Я';

  @override
  String get sortNameZA => 'По названию: Я-А';

  @override
  String get emptyPantryTitle => 'В вашей кладовой пусто';

  @override
  String get emptyPantrySubtitle =>
      'Начните вести учет домашних запасов, чтобы не выбрасывать еду и готовить с удовольствием.';

  @override
  String get emptySearchTitle => 'Продукты не найдены';

  @override
  String get emptySearchSubtitle =>
      'Попробуйте изменить поисковый запрос или сбросить фильтры.';

  @override
  String get emptyExpiryTitle => 'Всё под контролем!';

  @override
  String get emptyExpirySubtitle =>
      'В выбранном интервале нет просроченных или истекающих продуктов.';

  @override
  String get emptyImpactTitle => 'Пока нет записей';

  @override
  String get emptyImpactSubtitle =>
      'Когда вы отметите продукты съеденными или списанными, Valora сформирует честную статистику.';

  @override
  String get groupExpired => 'Просроченные';

  @override
  String get groupExpiringToday => 'Истекают сегодня';

  @override
  String get groupExpiringSoon => 'Скоро истекают';

  @override
  String get groupLater => 'С хорошим запасом';

  @override
  String get groupUnknown => 'Срок неизвестен';

  @override
  String get consumeDialogTitle => 'Употребление продукта';

  @override
  String get consumeDialogPrompt => 'Какое количество продукта вы употребили?';

  @override
  String get discardDialogTitle => 'Списание продукта';

  @override
  String get discardDialogPrompt =>
      'Какое количество продукта пришлось выбросить?';

  @override
  String get resetFilters => 'Сбросить фильтры';

  @override
  String quantityRemaining(String qty, String unit) {
    return 'Осталось: $qty $unit';
  }

  @override
  String quantityOriginal(String qty, String unit) {
    return 'Было: $qty $unit';
  }

  @override
  String quantityConsumed(String qty, String unit) {
    return 'Съедено: $qty $unit';
  }

  @override
  String quantityDiscarded(String qty, String unit) {
    return 'Выброшено: $qty $unit';
  }

  @override
  String get deleteConfirmTitle => 'Удалить продукт?';

  @override
  String deleteConfirmContent(String name) {
    return 'Вы уверены, что хотите удалить «$name»? История ранее учтенных действий сохранится.';
  }

  @override
  String get actionSuccessSaved => 'Продукт успешно сохранен.';

  @override
  String get actionSuccessConsumed => 'Отмечено как съеденное.';

  @override
  String get actionSuccessDiscarded => 'Отмечено как выброшенное.';

  @override
  String get actionSuccessDeleted => 'Продукт удален из кладовой.';

  @override
  String get impactSummary => 'Сводка активности';

  @override
  String get itemsConsumed => 'Употреблено продуктов';

  @override
  String get itemsDiscarded => 'Списано продуктов';

  @override
  String get valueConsumed => 'Стоимость сохраненной еды';

  @override
  String get valueDiscarded => 'Стоимость выброшенной еды';

  @override
  String get consumptionRate => 'Коэффициент потребления';

  @override
  String get impactDisclaimer =>
      'Все показатели рассчитываются исключительно на базе ваших записей. Valora не придумывает фальшивые экологические данные.';

  @override
  String get impactHistoryTitle => 'Журнал последних действий';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsEnableNotifications => 'Напоминания о сроках';

  @override
  String get settingsNotificationDesc =>
      'Получать напоминания до наступления даты истечения срока годности.';

  @override
  String get settingsNotificationThreshold => 'Предупреждать заранее';

  @override
  String get settingsNotificationThresholdDesc =>
      'За сколько дней присылать предупреждение';

  @override
  String daysUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дней',
      many: '$count дней',
      few: '$count дня',
      one: '1 день',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataManagement => 'Управление данными';

  @override
  String get settingsExportData => 'Экспорт данных (JSON)';

  @override
  String get settingsExportSuccess => 'Данные успешно экспортированы.';

  @override
  String get settingsImportData => 'Импорт данных (JSON)';

  @override
  String get settingsImportSuccess => 'Данные успешно импортированы.';

  @override
  String get settingsImportInvalid => 'Некорректный JSON-файл данных.';

  @override
  String get settingsClearData => 'Очистить все данные';

  @override
  String get settingsClearDataConfirm =>
      'Это действие необратимо. Все продукты и история действий будут безвозвратно удалены.';

  @override
  String get settingsClearDataSuccess => 'Все локальные данные были стерты.';

  @override
  String get settingsAbout => 'О приложении Valora';

  @override
  String get settingsAboutDesc =>
      'Valora — это лаконичное, работающее автономно приложение для учета домашней еды и контроля сроков годности, созданное для челленджа Hack Club Cider.';

  @override
  String get settingsPrivacy => 'Конфиденциальность и хранение данных';

  @override
  String get settingsPrivacyDesc =>
      'Все данные на 100% хранятся только на вашем устройстве. Никаких трекеров, обязательных аккаунтов и скрытой отправки в облако.';

  @override
  String get settingsLicense => 'Лицензия с открытым кодом';

  @override
  String get settingsLicenseDesc => 'Опубликовано под лицензией MIT.';

  @override
  String get unsavedChangesTitle => 'Отменить изменения?';

  @override
  String get unsavedChangesMessage =>
      'У вас есть несохраненные данные. Вы уверены, что хотите выйти без сохранения?';

  @override
  String get expirySafetyDisclaimerTitle =>
      'Сроки годности и безопасность питания';

  @override
  String get expirySafetyDisclaimerContent =>
      'Сроки годности являются ориентиром свежести и вкусовых качеств. Всегда проверяйте внешний вид, запах и консистенцию. Продукты без указанного срока требуют вашего личного осмотра и никогда автоматически не считаются безопасными или испорченными.';

  @override
  String get partial => 'Частично';

  @override
  String quantityExceedsRemaining(String qty, String unit) {
    return 'Не может превышать доступный остаток ($qty $unit)';
  }

  @override
  String get discardConfirmPermanent => 'Подтверждение списания';

  @override
  String discardConfirmPermanentPrompt(String qty, String unit, String name) {
    return 'Вы уверены, что хотите списать $qty $unit продукта «$name»? Это действие будет зафиксировано в статистике отходов и не может быть отменено.';
  }

  @override
  String get consumeNotesHint => 'напр., Приготовили ужин, взяли на работу';

  @override
  String get discardNotesHint => 'напр., Испортилось, истек срок';

  @override
  String get homeNeedsAction => 'Требует внимания';

  @override
  String get homeAddFoodDesc =>
      'Учитывайте новые покупки, чтобы вовремя всё использовать';

  @override
  String get activityDetailsTitle => 'Детали действия';

  @override
  String get activityDate => 'Дата и время';

  @override
  String get activityType => 'Тип операции';

  @override
  String get activityEstimatedValue => 'Оценочная стоимость';

  @override
  String get activityValueFormulaNotice =>
      'Рассчитано пропорционально указанной цене покупки.';

  @override
  String get filterPeriod => 'Период';

  @override
  String get filterPeriodAll => 'За всё время';

  @override
  String get filterPeriod7Days => 'За 7 дней';

  @override
  String get filterPeriod30Days => 'За 30 дней';

  @override
  String get filterType => 'Тип';

  @override
  String get filterTypeAll => 'Все действия';

  @override
  String get filterTypeConsumed => 'Только съеденное';

  @override
  String get filterTypeDiscarded => 'Только списанное';

  @override
  String get unitBreakdownTitle => 'Объем по единицам измерения';

  @override
  String get consumedUnits => 'Съедено';

  @override
  String get discardedUnits => 'Выброшено';

  @override
  String get fromPricedItems => 'По продуктам с указанной ценой покупки';

  @override
  String get settingsPreferences => 'Настройки';

  @override
  String get settingsTheme => 'Тема оформления';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get themeLight => 'Светлая тема';

  @override
  String get themeDark => 'Темная тема';

  @override
  String get themeSystemOption => 'Системная';

  @override
  String get themeLightOption => 'Светлая';

  @override
  String get themeDarkOption => 'Темная';

  @override
  String get copyToClipboard => 'Скопировать в буфер';

  @override
  String get dataCopiedToClipboard => 'Данные скопированы в буфер обмена!';

  @override
  String exportFailed(String error) {
    return 'Ошибка экспорта: $error';
  }

  @override
  String get importPastePrompt =>
      'Вставьте скопированный JSON-бэкап Valora ниже:';

  @override
  String get notificationPermissionDenied =>
      'Разрешение на уведомления не предоставлено в настройках системы.';

  @override
  String get appVersionDetails => 'Версия 1.0.0 • Для конкурса Hack Club Cider';

  @override
  String get selectLanguage => 'Выбор языка / Select Language';

  @override
  String get langPortuguese => 'Português (Португальский/Бразилия)';

  @override
  String get langEnglish => 'English (Английский)';

  @override
  String get langSpanish => 'Español (Испанский)';

  @override
  String get langFrench => 'Français (Французский)';

  @override
  String get langGerman => 'Deutsch (Немецкий)';

  @override
  String get langItalian => 'Italiano (Итальянский)';

  @override
  String get langChinese => '中文 (Китайский упрощенный)';

  @override
  String get langJapanese => '日本語 (Японский)';

  @override
  String get langRussian => 'Русский';

  @override
  String get langArabic => 'العربية (Арабский)';

  @override
  String get langHindi => 'हिन्दी (Хинди)';

  @override
  String get langSystem => 'Системный по умолчанию / System Default';

  @override
  String get subscriptionTitle => 'Подписка и рефералы';

  @override
  String get subscriptionMonthlyPrice => '599 ₽ / месяц';

  @override
  String get subscriptionFreeTrial => '7 дней пробного периода';

  @override
  String get subscriptionTrialActive => 'Пробный бесплатный период';

  @override
  String subscriptionTrialDaysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Осталось $days дней пробного периода',
      many: 'Осталось $days дней пробного периода',
      few: 'Осталось $days дня пробного периода',
      one: 'Остался 1 день пробного периода',
      zero: 'Последний день пробного периода',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionExpired => 'Пробный период завершен';

  @override
  String get subscriptionExpiredDesc =>
      'Чтобы продолжить пользоваться Valora на Android, оформите подписку за 599 ₽/мес или приглашайте друзей и получайте бонусные дни.';

  @override
  String get subscriptionActive => 'Подписка активна';

  @override
  String get subscribeButton => 'Оформить подписку за 599 ₽ / месяц';

  @override
  String get referralTitle => 'Приглашайте друзей (+7 дней)';

  @override
  String get referralDesc =>
      'За каждого приглашенного друга вы получаете +7 дополнительных дней бесплатного доступа!';

  @override
  String get referralYourCode => 'Ваш реферальный код';

  @override
  String get referralEnterCode => 'Ввести реферальный код';

  @override
  String get referralEnterCodePrompt =>
      'Введите код друга, чтобы получить +7 дней доступа:';

  @override
  String get referralApply => 'Применить код';

  @override
  String get referralSuccess =>
      'Поздравляем! Вам начислено +7 дополнительных дней бесплатного доступа!';

  @override
  String get referralAlreadyUsed => 'Вы уже активировали этот реферальный код.';

  @override
  String get referralSelfCode =>
      'Нельзя использовать свой собственный реферальный код.';

  @override
  String get referralInvalidCode => 'Недействительный реферальный код.';

  @override
  String get referralSimulateInvite => 'Симуляция приглашения друга (+7 дней)';

  @override
  String get referralShareText => 'Поделиться приглашением';

  @override
  String get referralInvitedCount => 'Приглашено друзей';

  @override
  String get referralBonusDaysCount => 'Получено бонусных дней';
}
