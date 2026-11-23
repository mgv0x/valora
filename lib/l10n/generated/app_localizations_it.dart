// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Valora';

  @override
  String get tagline => 'Spreco zero. Vivere meglio.';

  @override
  String get homeTitle => 'Home';

  @override
  String get pantryTitle => 'Dispensa';

  @override
  String get expiryCenterTitle => 'Scadenze';

  @override
  String get impactTitle => 'Il mio Impatto';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get greetingMorning => 'Buongiorno';

  @override
  String get greetingAfternoon => 'Buon pomeriggio';

  @override
  String get greetingEvening => 'Buonasera';

  @override
  String activeItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alimenti attivi',
      one: '1 alimento attivo',
      zero: 'Nessun alimento attivo',
    );
    return '$_temp0';
  }

  @override
  String needsAttentionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alimenti richiedono attenzione',
      one: '1 alimento richiede attenzione',
      zero: 'Nessun alimento da controllare',
    );
    return '$_temp0';
  }

  @override
  String expiringSoonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count in scadenza a breve',
      one: '1 in scadenza a breve',
      zero: 'Nessuno in scadenza',
    );
    return '$_temp0';
  }

  @override
  String get priorityItems => 'Alimenti prioritari';

  @override
  String get consumeFirstTitle => 'Da consumare per primi';

  @override
  String get insightNoneUrgent =>
      'Nessun alimento richiede attenzione urgente.';

  @override
  String insightExpired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count alimenti sono già scaduti. Dai priorità a questi alimenti per ridurre gli sprechi.',
      one:
          '1 alimento è già scaduto. Dai priorità a questi alimenti per ridurre gli sprechi.',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count alimenti scadono oggi. Consumali prima per evitare sprechi.',
      one: '1 alimento scade oggi. Consumalo prima per evitare sprechi.',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringTomorrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Questi $count alimenti scadono domani.',
      one: 'Questo alimento scade domani.',
    );
    return '$_temp0';
  }

  @override
  String get insightGeneralPriority =>
      'Dai priorità a questi alimenti per evitare sprechi.';

  @override
  String get priorityHigh => 'Priorità alta';

  @override
  String get priorityAttention => 'Attenzione';

  @override
  String get priorityOnTrack => 'In regola';

  @override
  String get viewAll => 'Vedi tutti';

  @override
  String get addFood => 'Aggiungi Alimento';

  @override
  String get editFood => 'Modifica Alimento';

  @override
  String get foodDetails => 'Dettagli Alimento';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get confirm => 'Conferma';

  @override
  String get consume => 'Consuma';

  @override
  String get discard => 'Getta';

  @override
  String get markConsumed => 'Segna come Consumato';

  @override
  String get markDiscarded => 'Segna come Gettato';

  @override
  String get all => 'Tutti';

  @override
  String get foodName => 'Nome Alimento';

  @override
  String get foodNameHint => 'Es.: Latte Intero, Mele Gala';

  @override
  String get foodNameRequired => 'Inserisci il nome dell\'alimento';

  @override
  String get category => 'Categoria';

  @override
  String get categoryRequired => 'Seleziona una categoria';

  @override
  String get quantity => 'Quantità';

  @override
  String get quantityRequired => 'Inserisci una quantità maggiore di 0';

  @override
  String get unit => 'Unità';

  @override
  String get expiryDate => 'Data di Scadenza';

  @override
  String get unknownExpiry => 'Scadenza non specificata';

  @override
  String get expiryDateRequired =>
      'Scegli una data o indica che non è specificata';

  @override
  String get purchasePrice => 'Prezzo d\'acquisto';

  @override
  String get purchasePriceOptional => 'Prezzo d\'acquisto (opzionale)';

  @override
  String get purchasePriceInvalid => 'Il prezzo non può essere negativo';

  @override
  String get storageLocation => 'Luogo di conservazione';

  @override
  String get storageLocationOptional => 'Luogo di conservazione (opzionale)';

  @override
  String get purchaseDate => 'Data d\'acquisto';

  @override
  String get purchaseDateOptional => 'Data d\'acquisto (opzionale)';

  @override
  String get notes => 'Note';

  @override
  String get notesOptional => 'Note (opzionale)';

  @override
  String get notesHint => 'Marca, ripiano, lotto, ecc.';

  @override
  String get catFruits => 'Frutta';

  @override
  String get catVegetables => 'Verdura';

  @override
  String get catDairy => 'Latticini';

  @override
  String get catMeatFish => 'Carne & Pesce';

  @override
  String get catBakery => 'Panetteria';

  @override
  String get catPantryStaples => 'Dispensa & Cereali';

  @override
  String get catFrozen => 'Surgelati';

  @override
  String get catDrinks => 'Bevande';

  @override
  String get catOther => 'Altro';

  @override
  String get locRefrigerator => 'Frigorifero';

  @override
  String get locFreezer => 'Congelatore';

  @override
  String get locPantry => 'Dispensa';

  @override
  String get locOther => 'Altro posto';

  @override
  String get unitPiece => 'pz.';

  @override
  String get unitGram => 'g';

  @override
  String get unitKilogram => 'kg';

  @override
  String get unitMilliliter => 'ml';

  @override
  String get unitLiter => 'L';

  @override
  String get unitPackage => 'conf.';

  @override
  String get statusExpired => 'Scaduto';

  @override
  String get statusExpiringToday => 'Scade oggi';

  @override
  String get statusExpiringSoon => 'In scadenza';

  @override
  String get statusFresh => 'Fresco';

  @override
  String get statusUnknown => 'Non nota';

  @override
  String daysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Restano $days giorni',
      one: 'Resta 1 giorno',
      zero: 'Scade oggi',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Scaduto da $days giorni',
      one: 'Scaduto ieri',
      zero: 'Scaduto oggi',
    );
    return '$_temp0';
  }

  @override
  String get searchPlaceholder => 'Cerca alimento per nome...';

  @override
  String get filterAll => 'Tutti';

  @override
  String get sortBy => 'Ordina per';

  @override
  String get sortExpirySoonest => 'Scadenza: Prima i più vicini';

  @override
  String get sortExpiryLatest => 'Scadenza: Prima i più lontani';

  @override
  String get sortNameAZ => 'Nome: A - Z';

  @override
  String get sortNameZA => 'Nome: Z - A';

  @override
  String get emptyPantryTitle => 'La tua dispensa è vuota';

  @override
  String get emptyPantrySubtitle =>
      'Inizia a registrare gli alimenti per pianificare i tuoi pasti ed evitare gli sprechi.';

  @override
  String get emptySearchTitle => 'Nessun alimento trovato';

  @override
  String get emptySearchSubtitle =>
      'Prova un altro termine o modifica i filtri impostati.';

  @override
  String get emptyExpiryTitle => 'Tutto sotto controllo!';

  @override
  String get emptyExpirySubtitle =>
      'Nessun alimento è scaduto o in scadenza imminente.';

  @override
  String get emptyImpactTitle => 'Nessuna attività registrata';

  @override
  String get emptyImpactSubtitle =>
      'Consumando o gettando alimenti, Valora mostrerà qui statistiche reali.';

  @override
  String get groupExpired => 'Scaduti';

  @override
  String get groupExpiringToday => 'Scadono Oggi';

  @override
  String get groupExpiringSoon => 'In Scadenza a Breve';

  @override
  String get groupLater => 'Buoni per più avanti';

  @override
  String get groupUnknown => 'Data non specificata';

  @override
  String get consumeDialogTitle => 'Registra Consumo';

  @override
  String get consumeDialogPrompt => 'Quanto alimento hai consumato?';

  @override
  String get discardDialogTitle => 'Registra Spreco';

  @override
  String get discardDialogPrompt => 'Quanto alimento è stato gettato?';

  @override
  String get resetFilters => 'Reimposta filtri';

  @override
  String quantityRemaining(String qty, String unit) {
    return 'Disponibile: $qty $unit';
  }

  @override
  String quantityOriginal(String qty, String unit) {
    return 'Iniziale: $qty $unit';
  }

  @override
  String quantityConsumed(String qty, String unit) {
    return 'Consumato: $qty $unit';
  }

  @override
  String quantityDiscarded(String qty, String unit) {
    return 'Gettato: $qty $unit';
  }

  @override
  String get deleteConfirmTitle => 'Eliminare l\'alimento?';

  @override
  String deleteConfirmContent(String name) {
    return 'Confermi di voler eliminare \"$name\"? Lo storico delle attività sarà conservato.';
  }

  @override
  String get actionSuccessSaved => 'Alimento salvato con successo.';

  @override
  String get actionSuccessConsumed => 'Consumo registrato con successo.';

  @override
  String get actionSuccessDiscarded => 'Scarto registrato con successo.';

  @override
  String get actionSuccessDeleted => 'Alimento rimosso dalla dispensa attiva.';

  @override
  String get impactSummary => 'Riepilogo Attività';

  @override
  String get itemsConsumed => 'Alimenti consumati registrati';

  @override
  String get itemsDiscarded => 'Alimenti gettati registrati';

  @override
  String get valueConsumed => 'Valore stimato consumato';

  @override
  String get valueDiscarded => 'Valore stimato gettato';

  @override
  String get consumptionRate => 'Tasso di utilizzo';

  @override
  String get impactDisclaimer =>
      'Dati calcolati unicamente dalle attività reali registrate. Valora non inventa stime ambientali artificiali.';

  @override
  String get impactHistoryTitle => 'Cronologia Attività Recente';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsNotifications => 'Notifiche';

  @override
  String get settingsEnableNotifications => 'Avvisi di Scadenza';

  @override
  String get settingsNotificationDesc =>
      'Ricevi avvisi prima che gli alimenti scadano.';

  @override
  String get settingsNotificationThreshold => 'Preavviso';

  @override
  String get settingsNotificationThresholdDesc =>
      'Quanti giorni prima avvisare';

  @override
  String daysUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataManagement => 'Gestione Dati';

  @override
  String get settingsExportData => 'Esporta Dati (JSON)';

  @override
  String get settingsExportSuccess => 'Dati esportati con successo.';

  @override
  String get settingsImportData => 'Importa Dati (JSON)';

  @override
  String get settingsImportSuccess => 'Dati importati con successo.';

  @override
  String get settingsImportInvalid => 'File JSON non valido o corrotto.';

  @override
  String get settingsClearData => 'Cancella Tutti i Dati';

  @override
  String get settingsClearDataConfirm =>
      'Azione irreversibile. Tutti gli alimenti e la cronologia saranno eliminati.';

  @override
  String get settingsClearDataSuccess =>
      'Tutti i dati locali sono stati eliminati.';

  @override
  String get settingsAbout => 'Informazioni su Valora';

  @override
  String get settingsAboutDesc =>
      'Valora è un\'app offline-first per gestire la dispensa e contrastare lo spreco alimentare.';

  @override
  String get settingsPrivacy => 'Privacy & Archiviazione';

  @override
  String get settingsPrivacyDesc =>
      'Il 100% dei dati rimane sul dispositivo. Nessun tracciatore né account obbligatorio.';

  @override
  String get settingsLicense => 'Licenza Open Source';

  @override
  String get settingsLicenseDesc => 'Rilasciato sotto licenza MIT.';

  @override
  String get unsavedChangesTitle => 'Annullare le modifiche?';

  @override
  String get unsavedChangesMessage =>
      'Ci sono modifiche non salvate. Vuoi uscire senza salvare?';

  @override
  String get expirySafetyDisclaimerTitle => 'Avviso di Scadenza e Sicurezza';

  @override
  String get expirySafetyDisclaimerContent =>
      'Le date di scadenza sono linee guida per una conservazione ideale. Controlla sempre aspetto, odore e sapore.';

  @override
  String get partial => 'Parziale';

  @override
  String quantityExceedsRemaining(String qty, String unit) {
    return 'Non può superare la quantità residua ($qty $unit)';
  }

  @override
  String get discardConfirmPermanent => 'Conferma eliminazione';

  @override
  String discardConfirmPermanentPrompt(String qty, String unit, String name) {
    return 'Vuoi davvero gettare $qty $unit di \"$name\"? L\'operazione registrerà spreco alimentare.';
  }

  @override
  String get consumeNotesHint => 'Es.: Cena in famiglia, pranzo preparato';

  @override
  String get discardNotesHint => 'Es.: Deteriorato, data oltrepassata';

  @override
  String get homeNeedsAction => 'Richiede attenzione';

  @override
  String get homeAddFoodDesc => 'Registra le tue spese per prevenire lo spreco';

  @override
  String get activityDetailsTitle => 'Dettagli Attività';

  @override
  String get activityDate => 'Data e ora';

  @override
  String get activityType => 'Tipo di azione';

  @override
  String get activityEstimatedValue => 'Valore stimato';

  @override
  String get activityValueFormulaNotice =>
      'Calcolato in proporzione al prezzo di acquisto indicato.';

  @override
  String get filterPeriod => 'Periodo';

  @override
  String get filterPeriodAll => 'Tutto il periodo';

  @override
  String get filterPeriod7Days => 'Ultimi 7 giorni';

  @override
  String get filterPeriod30Days => 'Ultimi 30 giorni';

  @override
  String get filterType => 'Tipo';

  @override
  String get filterTypeAll => 'Tutte le azioni';

  @override
  String get filterTypeConsumed => 'Solo consumo';

  @override
  String get filterTypeDiscarded => 'Solo gettati';

  @override
  String get unitBreakdownTitle => 'Volume registrato per unità';

  @override
  String get consumedUnits => 'Consumato';

  @override
  String get discardedUnits => 'Gettato';

  @override
  String get fromPricedItems => 'Da alimenti con prezzo indicato';

  @override
  String get settingsPreferences => 'Preferenze';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeSystem => 'Predefinito di sistema';

  @override
  String get themeLight => 'Modalità Chiara';

  @override
  String get themeDark => 'Modalità Scura';

  @override
  String get themeSystemOption => 'Sistema';

  @override
  String get themeLightOption => 'Chiaro';

  @override
  String get themeDarkOption => 'Scuro';

  @override
  String get copyToClipboard => 'Copia negli Appunti';

  @override
  String get dataCopiedToClipboard => 'Dati copiati negli appunti!';

  @override
  String exportFailed(String error) {
    return 'Esportazione non riuscita: $error';
  }

  @override
  String get importPastePrompt => 'Incolla qui sotto il backup JSON di Valora:';

  @override
  String get notificationPermissionDenied =>
      'Permesso di notifica non concesso nelle impostazioni del dispositivo.';

  @override
  String get appVersionDetails => 'Versione 1.0.0 • Hack Club Cider Submission';

  @override
  String get selectLanguage => 'Seleziona Lingua / Select Language';

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
  String get langSystem => 'Predefinito di sistema';

  @override
  String get subscriptionTitle => 'Abbonamento & Inviti';

  @override
  String get subscriptionMonthlyPrice => '9,90 € / mese';

  @override
  String get subscriptionFreeTrial => '7 giorni di prova gratuita';

  @override
  String get subscriptionTrialActive => 'Periodo di Prova Gratuito';

  @override
  String subscriptionTrialDaysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni rimasti di prova',
      one: '1 giorno rimasto di prova',
      zero: 'Ultimo giorno di prova gratuita',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionExpired => 'Periodo di Prova Terminato';

  @override
  String get subscriptionExpiredDesc =>
      'Per continuare a usare Valora su Android, abbonati a 9,90 €/mese o invita amici.';

  @override
  String get subscriptionActive => 'Abbonamento attivo';

  @override
  String get subscribeButton => 'Abbonati a 9,90 € / mese';

  @override
  String get referralTitle => 'Invita e Guadagna (+7 Giorni)';

  @override
  String get referralDesc =>
      'Per ogni persona che inviti, ricevi 7 giorni di accesso gratuito in più!';

  @override
  String get referralYourCode => 'Il tuo codice invito';

  @override
  String get referralEnterCode => 'Inserisci codice';

  @override
  String get referralEnterCodePrompt =>
      'Inserisci il codice di un amico per ottenere 7 giorni gratis:';

  @override
  String get referralApply => 'Applica codice';

  @override
  String get referralSuccess =>
      'Congratulazioni! Hai ottenuto 7 giorni gratuiti in più!';

  @override
  String get referralAlreadyUsed => 'Hai già riscattato questo codice.';

  @override
  String get referralSelfCode => 'Non puoi usare il tuo stesso codice invito.';

  @override
  String get referralInvalidCode => 'Codice invito non valido.';

  @override
  String get referralSimulateInvite => 'Simula amico invitato (+7 giorni)';

  @override
  String get referralShareText => 'Condividi invito';

  @override
  String get referralInvitedCount => 'Amici invitati';

  @override
  String get referralBonusDaysCount => 'Giorni bonus ottenuti';
}
