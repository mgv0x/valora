// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Valora';

  @override
  String get tagline => 'Weniger verschwenden. Besser leben.';

  @override
  String get homeTitle => 'Startseite';

  @override
  String get pantryTitle => 'Vorratskammer';

  @override
  String get expiryCenterTitle => 'Haltbarkeit';

  @override
  String get impactTitle => 'Mein Beitrag';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get greetingMorning => 'Guten Morgen';

  @override
  String get greetingAfternoon => 'Guten Tag';

  @override
  String get greetingEvening => 'Guten Abend';

  @override
  String activeItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aktive Lebensmittel',
      one: '1 aktives Lebensmittel',
      zero: 'Keine aktiven Lebensmittel',
    );
    return '$_temp0';
  }

  @override
  String needsAttentionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Lebensmittel erfordern Aufmerksamkeit',
      one: '1 Lebensmittel erfordert Aufmerksamkeit',
      zero: 'Keine Aufmerksamkeit erforderlich',
    );
    return '$_temp0';
  }

  @override
  String expiringSoonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count laufen bald ab',
      one: '1 läuft bald ab',
      zero: 'Keine bald ablaufenden',
    );
    return '$_temp0';
  }

  @override
  String get priorityItems => 'Prioritäre Artikel';

  @override
  String get consumeFirstTitle => 'Zuerst verbrauchen';

  @override
  String get insightNoneUrgent =>
      'Keine Lebensmittel erfordern dringende Aufmerksamkeit.';

  @override
  String insightExpired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Lebensmittel sind bereits abgelaufen. Verbrauchen oder prüfen Sie diese Artikel zuerst.',
      one:
          '1 Lebensmittel ist bereits abgelaufen. Verbrauchen oder prüfen Sie diese Artikel zuerst.',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Lebensmittel laufen heute ab. Verbrauchen Sie diese vorrangig.',
      one: '1 Lebensmittel läuft heute ab. Verbrauchen Sie es vorrangig.',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringTomorrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Diese $count Lebensmittel laufen morgen ab.',
      one: 'Dieses Lebensmittel läuft morgen ab.',
    );
    return '$_temp0';
  }

  @override
  String get insightGeneralPriority =>
      'Priorisieren Sie diese Lebensmittel, um Verschwendung zu vermeiden.';

  @override
  String get priorityHigh => 'Hohe Priorität';

  @override
  String get priorityAttention => 'Aufmerksamkeit';

  @override
  String get priorityOnTrack => 'Im Plan';

  @override
  String get viewAll => 'Alle anzeigen';

  @override
  String get addFood => 'Lebensmittel hinzufügen';

  @override
  String get editFood => 'Lebensmittel bearbeiten';

  @override
  String get foodDetails => 'Lebensmitteldetails';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get consume => 'Verbrauchen';

  @override
  String get discard => 'Entsorgen';

  @override
  String get markConsumed => 'Als verbraucht markieren';

  @override
  String get markDiscarded => 'Als entsorgt markieren';

  @override
  String get all => 'Alle';

  @override
  String get foodName => 'Name des Lebensmittels';

  @override
  String get foodNameHint => 'z. B. Vollmilch, Frische Äpfel';

  @override
  String get foodNameRequired => 'Bitte geben Sie einen Namen ein';

  @override
  String get category => 'Kategorie';

  @override
  String get categoryRequired => 'Bitte wählen Sie eine Kategorie';

  @override
  String get quantity => 'Menge';

  @override
  String get quantityRequired => 'Bitte geben Sie eine Menge größer als 0 ein';

  @override
  String get unit => 'Einheit';

  @override
  String get expiryDate => 'Mindesthaltbarkeitsdatum';

  @override
  String get unknownExpiry => 'Kein Ablaufdatum bekannt';

  @override
  String get expiryDateRequired =>
      'Bitte wählen Sie ein Datum oder markieren Sie es als unbekannt';

  @override
  String get purchasePrice => 'Kaufpreis';

  @override
  String get purchasePriceOptional => 'Kaufpreis (optional)';

  @override
  String get purchasePriceInvalid => 'Der Preis darf nicht negativ sein';

  @override
  String get storageLocation => 'Lagerort';

  @override
  String get storageLocationOptional => 'Lagerort (optional)';

  @override
  String get purchaseDate => 'Kaufdatum';

  @override
  String get purchaseDateOptional => 'Kaufdatum (optional)';

  @override
  String get notes => 'Notizen';

  @override
  String get notesOptional => 'Notizen (optional)';

  @override
  String get notesHint => 'Marke, Regal, Charge usw.';

  @override
  String get catFruits => 'Obst';

  @override
  String get catVegetables => 'Gemüse';

  @override
  String get catDairy => 'Milchprodukte';

  @override
  String get catMeatFish => 'Fleisch & Fisch';

  @override
  String get catBakery => 'Backwaren';

  @override
  String get catPantryStaples => 'Vorräte & Grundnahrungsmittel';

  @override
  String get catFrozen => 'Tiefkühlware';

  @override
  String get catDrinks => 'Getränke';

  @override
  String get catOther => 'Sonstiges';

  @override
  String get locRefrigerator => 'Kühlschrank';

  @override
  String get locFreezer => 'Gefrierschrank';

  @override
  String get locPantry => 'Vorratskammer';

  @override
  String get locOther => 'Anderer Ort';

  @override
  String get unitPiece => 'Stk.';

  @override
  String get unitGram => 'g';

  @override
  String get unitKilogram => 'kg';

  @override
  String get unitMilliliter => 'ml';

  @override
  String get unitLiter => 'L';

  @override
  String get unitPackage => 'Pck.';

  @override
  String get statusExpired => 'Abgelaufen';

  @override
  String get statusExpiringToday => 'Läuft heute ab';

  @override
  String get statusExpiringSoon => 'Läuft bald ab';

  @override
  String get statusFresh => 'Frisch';

  @override
  String get statusUnknown => 'Unbekannt';

  @override
  String daysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Noch $days Tage',
      one: 'Noch 1 Tag',
      zero: 'Läuft heute ab',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Vor $days Tagen abgelaufen',
      one: 'Gestern abgelaufen',
      zero: 'Heute abgelaufen',
    );
    return '$_temp0';
  }

  @override
  String get searchPlaceholder => 'Lebensmittel nach Namen suchen...';

  @override
  String get filterAll => 'Alle';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get sortExpirySoonest => 'Ablauf: Früheste zuerst';

  @override
  String get sortExpiryLatest => 'Ablauf: Späteste zuerst';

  @override
  String get sortNameAZ => 'Name: A bis Z';

  @override
  String get sortNameZA => 'Name: Z bis A';

  @override
  String get emptyPantryTitle => 'Ihre Vorratskammer ist leer';

  @override
  String get emptyPantrySubtitle =>
      'Erfassen Sie Ihre Vorräte, um Lebensmittelverschwendung zu vermeiden und Mahlzeiten besser zu planen.';

  @override
  String get emptySearchTitle => 'Keine Treffer für Ihre Suche';

  @override
  String get emptySearchSubtitle =>
      'Versuchen Sie einen anderen Begriff oder passen Sie die Filter an.';

  @override
  String get emptyExpiryTitle => 'Alles im grünen Bereich!';

  @override
  String get emptyExpirySubtitle =>
      'Keine Lebensmittel sind abgelaufen oder laufen in Kürze ab.';

  @override
  String get emptyImpactTitle => 'Noch keine Aktivitäten aufgezeichnet';

  @override
  String get emptyImpactSubtitle =>
      'Sobald Sie Lebensmittel verbrauchen oder entsorgen, zeigt Valora hier Ihre Statistiken an.';

  @override
  String get groupExpired => 'Abgelaufen';

  @override
  String get groupExpiringToday => 'Läuft heute ab';

  @override
  String get groupExpiringSoon => 'Läuft bald ab';

  @override
  String get groupLater => 'Noch länger haltbar';

  @override
  String get groupUnknown => 'Unbekanntes Datum';

  @override
  String get consumeDialogTitle => 'Verbrauch erfassen';

  @override
  String get consumeDialogPrompt => 'Wie viel haben Sie verbraucht?';

  @override
  String get discardDialogTitle => 'Entsorgung erfassen';

  @override
  String get discardDialogPrompt => 'Wie viel wurde entsorgt?';

  @override
  String get resetFilters => 'Filter zurücksetzen';

  @override
  String quantityRemaining(String qty, String unit) {
    return 'Verfügbar: $qty $unit';
  }

  @override
  String quantityOriginal(String qty, String unit) {
    return 'Ursprünglich: $qty $unit';
  }

  @override
  String quantityConsumed(String qty, String unit) {
    return 'Verbraucht: $qty $unit';
  }

  @override
  String quantityDiscarded(String qty, String unit) {
    return 'Entsorgt: $qty $unit';
  }

  @override
  String get deleteConfirmTitle => 'Lebensmittel löschen?';

  @override
  String deleteConfirmContent(String name) {
    return 'Möchten Sie \"$name\" wirklich löschen? Bisherige Aktivitäten bleiben erhalten.';
  }

  @override
  String get actionSuccessSaved => 'Lebensmittel erfolgreich gespeichert.';

  @override
  String get actionSuccessConsumed => 'Verbrauch erfasst.';

  @override
  String get actionSuccessDiscarded => 'Entsorgung erfasst.';

  @override
  String get actionSuccessDeleted =>
      'Artikel aus der aktiven Vorratskammer entfernt.';

  @override
  String get impactSummary => 'Aktivitätsübersicht';

  @override
  String get itemsConsumed => 'Erfasste verbrauchte Artikel';

  @override
  String get itemsDiscarded => 'Erfasste entsorgte Artikel';

  @override
  String get valueConsumed => 'Geschätzter verbrauchter Wert';

  @override
  String get valueDiscarded => 'Geschätzter entsorgter Wert';

  @override
  String get consumptionRate => 'Nutzungsquote';

  @override
  String get impactDisclaimer =>
      'Alle Werte basieren ausschließlich auf Ihren real erfassten Daten. Valora erfindet keine Schätzungen.';

  @override
  String get impactHistoryTitle => 'Aktivitätsprotokoll';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsNotifications => 'Benachrichtigungen';

  @override
  String get settingsEnableNotifications => 'Ablauferinnerungen';

  @override
  String get settingsNotificationDesc =>
      'Erhalten Sie Erinnerungen, bevor Lebensmittel ablaufen.';

  @override
  String get settingsNotificationThreshold => 'Vorwarnzeit';

  @override
  String get settingsNotificationThresholdDesc =>
      'Wie viele Tage im Voraus erinnern';

  @override
  String daysUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataManagement => 'Datenverwaltung';

  @override
  String get settingsExportData => 'Daten exportieren (JSON)';

  @override
  String get settingsExportSuccess => 'Daten erfolgreich exportiert.';

  @override
  String get settingsImportData => 'Daten importieren (JSON)';

  @override
  String get settingsImportSuccess => 'Daten erfolgreich importiert.';

  @override
  String get settingsImportInvalid => 'Ungültige oder beschädigte JSON-Datei.';

  @override
  String get settingsClearData => 'Alle Daten löschen';

  @override
  String get settingsClearDataConfirm =>
      'Dies kann nicht rückgängig gemacht werden. Alle Vorräte und Historien werden gelöscht.';

  @override
  String get settingsClearDataSuccess => 'Alle lokalen Daten wurden gelöscht.';

  @override
  String get settingsAbout => 'Über Valora';

  @override
  String get settingsAboutDesc =>
      'Valora ist eine Offline-First-App für Vorratsmanagement und gegen Lebensmittelverschwendung.';

  @override
  String get settingsPrivacy => 'Datenschutz & Speicher';

  @override
  String get settingsPrivacyDesc =>
      '100 % Ihrer Daten verbleiben auf Ihrem Gerät. Keine Tracker, keine Kontopflicht.';

  @override
  String get settingsLicense => 'Open-Source-Lizenz';

  @override
  String get settingsLicenseDesc => 'Veröffentlicht unter der MIT-Lizenz.';

  @override
  String get unsavedChangesTitle => 'Änderungen verwerfen?';

  @override
  String get unsavedChangesMessage =>
      'Sie haben ungespeicherte Änderungen. Möchten Sie wirklich abbrechen?';

  @override
  String get expirySafetyDisclaimerTitle =>
      'Haltbarkeit & Lebensmittelsicherheit';

  @override
  String get expirySafetyDisclaimerContent =>
      'Mindesthaltbarkeitsdaten sind Richtwerte. Prüfen Sie Lebensmittel stets mit Geruch, Aussehen und Geschmack.';

  @override
  String get partial => 'Teilweise';

  @override
  String quantityExceedsRemaining(String qty, String unit) {
    return 'Kann Restmenge ($qty $unit) nicht überschreiten';
  }

  @override
  String get discardConfirmPermanent => 'Entsorgung bestätigen';

  @override
  String discardConfirmPermanentPrompt(String qty, String unit, String name) {
    return 'Möchten Sie wirklich $qty $unit von \"$name\" entsorgen? Dies wird als Lebensmittelabfall erfasst.';
  }

  @override
  String get consumeNotesHint => 'z. B. Abendessen gekocht, Brotdose';

  @override
  String get discardNotesHint => 'z. B. Verschimmelt, verdorben';

  @override
  String get homeNeedsAction => 'Handlungsbedarf';

  @override
  String get homeAddFoodDesc =>
      'Neue Vorräte eintragen, um Verschwendung vorzubeugen';

  @override
  String get activityDetailsTitle => 'Aktivitätsdetails';

  @override
  String get activityDate => 'Datum & Uhrzeit';

  @override
  String get activityType => 'Aktionstyp';

  @override
  String get activityEstimatedValue => 'Geschätzter Wert';

  @override
  String get activityValueFormulaNotice =>
      'Proportional zum erfassten Kaufpreis berechnet.';

  @override
  String get filterPeriod => 'Zeitraum';

  @override
  String get filterPeriodAll => 'Gesamter Zeitraum';

  @override
  String get filterPeriod7Days => 'Letzte 7 Tage';

  @override
  String get filterPeriod30Days => 'Letzte 30 Tage';

  @override
  String get filterType => 'Typ';

  @override
  String get filterTypeAll => 'Alle Aktionen';

  @override
  String get filterTypeConsumed => 'Nur Verbrauch';

  @override
  String get filterTypeDiscarded => 'Nur Entsorgung';

  @override
  String get unitBreakdownTitle => 'Erfasstes Volumen nach Einheit';

  @override
  String get consumedUnits => 'Verbraucht';

  @override
  String get discardedUnits => 'Entsorgt';

  @override
  String get fromPricedItems => 'Von Artikeln mit Preisangabe';

  @override
  String get settingsPreferences => 'Präferenzen';

  @override
  String get settingsTheme => 'Design';

  @override
  String get themeSystem => 'Systemstandard';

  @override
  String get themeLight => 'Heller Modus';

  @override
  String get themeDark => 'Dunkler Modus';

  @override
  String get themeSystemOption => 'System';

  @override
  String get themeLightOption => 'Hell';

  @override
  String get themeDarkOption => 'Dunkel';

  @override
  String get copyToClipboard => 'In Zwischenablage kopieren';

  @override
  String get dataCopiedToClipboard => 'Daten in Zwischenablage kopiert!';

  @override
  String exportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get importPastePrompt => 'Fügen Sie Ihr Valora-JSON-Backup hier ein:';

  @override
  String get notificationPermissionDenied =>
      'Benachrichtigungsberechtigung in den Geräteeinstellungen nicht erteilt.';

  @override
  String get appVersionDetails => 'Version 1.0.0 • Hack Club Cider Submission';

  @override
  String get selectLanguage => 'Sprache wählen / Select Language';

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
  String get langSystem => 'Systemstandard';

  @override
  String get subscriptionTitle => 'Abonnement & Einladungen';

  @override
  String get subscriptionMonthlyPrice => '9,90 € / Monat';

  @override
  String get subscriptionFreeTrial => '7 Tage kostenlos testen';

  @override
  String get subscriptionTrialActive => 'Kostenloser Testzeitraum';

  @override
  String subscriptionTrialDaysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Noch $days Tage Testphase',
      one: 'Noch 1 Tag Testphase',
      zero: 'Letzter Tag der Testphase',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionExpired => 'Testphase abgelaufen';

  @override
  String get subscriptionExpiredDesc =>
      'Um Valora auf Android weiter zu nutzen, abonnieren Sie für 9,90 €/Monat oder laden Sie Freunde ein.';

  @override
  String get subscriptionActive => 'Abonnement aktiv';

  @override
  String get subscribeButton => 'Abonnieren für 9,90 € / Monat';

  @override
  String get referralTitle => 'Freunde einladen (+7 Tage)';

  @override
  String get referralDesc =>
      'Für jeden eingeladenen Freund erhalten Sie +7 zusätzliche Tage kostenlosen Zugang!';

  @override
  String get referralYourCode => 'Ihr Einladungscode';

  @override
  String get referralEnterCode => 'Code eingeben';

  @override
  String get referralEnterCodePrompt =>
      'Code eines Freundes eingeben für +7 Tage gratis:';

  @override
  String get referralApply => 'Code anwenden';

  @override
  String get referralSuccess =>
      'Glückwunsch! Sie haben 7 Tage Gratiszugang erhalten!';

  @override
  String get referralAlreadyUsed => 'Dieser Code wurde bereits eingelöst.';

  @override
  String get referralSelfCode =>
      'Sie können Ihren eigenen Code nicht verwenden.';

  @override
  String get referralInvalidCode => 'Ungültiger Einladungscode.';

  @override
  String get referralSimulateInvite => 'Freund eingeladen simulieren (+7 Tage)';

  @override
  String get referralShareText => 'Einladung teilen';

  @override
  String get referralInvitedCount => 'Eingeladene Freunde';

  @override
  String get referralBonusDaysCount => 'Erhaltene Bonustage';
}
