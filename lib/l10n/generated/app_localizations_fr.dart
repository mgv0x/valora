// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Valora';

  @override
  String get tagline => 'Gaspillez moins. Vivez mieux.';

  @override
  String get homeTitle => 'Accueil';

  @override
  String get pantryTitle => 'Garde-manger';

  @override
  String get expiryCenterTitle => 'Dates limites';

  @override
  String get impactTitle => 'Mon Impact';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get greetingMorning => 'Bonjour';

  @override
  String get greetingAfternoon => 'Bon après-midi';

  @override
  String get greetingEvening => 'Bonsoir';

  @override
  String activeItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aliments actifs',
      one: '1 aliment actif',
      zero: 'Aucun aliment actif',
    );
    return '$_temp0';
  }

  @override
  String needsAttentionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aliments requièrent votre attention',
      one: '1 aliment requiert votre attention',
      zero: 'Aucun aliment à surveiller',
    );
    return '$_temp0';
  }

  @override
  String expiringSoonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aliments expirent bientôt',
      one: '1 aliment expire bientôt',
      zero: 'Aucun aliment n\'expire bientôt',
    );
    return '$_temp0';
  }

  @override
  String get priorityItems => 'Aliments prioritaires';

  @override
  String get consumeFirstTitle => 'À consommer en premier';

  @override
  String get insightNoneUrgent =>
      'Aucun aliment ne nécessite d\'attention urgente.';

  @override
  String insightExpired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count aliments sont déjà périmés. Consommez ou triez ces produits pour limiter le gaspillage.',
      one:
          '1 aliment est déjà périmé. Consommez ou triez ces produits pour limiter le gaspillage.',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count aliments expirent aujourd\'hui. Consommez-les en priorité pour éviter le gaspillage.',
      one:
          '1 aliment expire aujourd\'hui. Consommez-le en priorité pour éviter le gaspillage.',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringTomorrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ces $count aliments expirent demain.',
      one: 'Cet aliment expire demain.',
    );
    return '$_temp0';
  }

  @override
  String get insightGeneralPriority =>
      'Consommez ces aliments en priorité pour éviter le gaspillage.';

  @override
  String get priorityHigh => 'Priorité haute';

  @override
  String get priorityAttention => 'Attention';

  @override
  String get priorityOnTrack => 'À jour';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get addFood => 'Ajouter un aliment';

  @override
  String get editFood => 'Modifier l\'aliment';

  @override
  String get foodDetails => 'Détails de l\'aliment';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get consume => 'Consommer';

  @override
  String get discard => 'Jeter';

  @override
  String get markConsumed => 'Marquer comme consommé';

  @override
  String get markDiscarded => 'Marquer comme jeté';

  @override
  String get all => 'Tous';

  @override
  String get foodName => 'Nom de l\'aliment';

  @override
  String get foodNameHint => 'Ex. : Lait demi-écrémé, Pommes Gala';

  @override
  String get foodNameRequired => 'Veuillez saisir le nom de l\'aliment';

  @override
  String get category => 'Catégorie';

  @override
  String get categoryRequired => 'Veuillez sélectionner une catégorie';

  @override
  String get quantity => 'Quantité';

  @override
  String get quantityRequired => 'Veuillez saisir une quantité supérieure à 0';

  @override
  String get unit => 'Unité';

  @override
  String get expiryDate => 'Date de péremption';

  @override
  String get unknownExpiry => 'Date non renseignée';

  @override
  String get expiryDateRequired =>
      'Sélectionnez une date ou cochez non renseignée';

  @override
  String get purchasePrice => 'Prix d\'achat';

  @override
  String get purchasePriceOptional => 'Prix d\'achat (facultatif)';

  @override
  String get purchasePriceInvalid => 'Le prix ne peut pas être négatif';

  @override
  String get storageLocation => 'Lieu de stockage';

  @override
  String get storageLocationOptional => 'Lieu de stockage (facultatif)';

  @override
  String get purchaseDate => 'Date d\'achat';

  @override
  String get purchaseDateOptional => 'Date d\'achat (facultatif)';

  @override
  String get notes => 'Remarques';

  @override
  String get notesOptional => 'Remarques (facultatif)';

  @override
  String get notesHint => 'Marque, étagère spécifique, lot, etc.';

  @override
  String get catFruits => 'Fruits';

  @override
  String get catVegetables => 'Légumes';

  @override
  String get catDairy => 'Produits laitiers';

  @override
  String get catMeatFish => 'Viandes & Poissons';

  @override
  String get catBakery => 'Boulangerie & Pâtisserie';

  @override
  String get catPantryStaples => 'Épicerie & Céréales';

  @override
  String get catFrozen => 'Surgelés';

  @override
  String get catDrinks => 'Boissons';

  @override
  String get catOther => 'Autres';

  @override
  String get locRefrigerator => 'Réfrigérateur';

  @override
  String get locFreezer => 'Congélateur';

  @override
  String get locPantry => 'Garde-manger';

  @override
  String get locOther => 'Autre lieu';

  @override
  String get unitPiece => 'pièce';

  @override
  String get unitGram => 'g';

  @override
  String get unitKilogram => 'kg';

  @override
  String get unitMilliliter => 'ml';

  @override
  String get unitLiter => 'L';

  @override
  String get unitPackage => 'paquet';

  @override
  String get statusExpired => 'Périmé';

  @override
  String get statusExpiringToday => 'Expire aujourd\'hui';

  @override
  String get statusExpiringSoon => 'Expire bientôt';

  @override
  String get statusFresh => 'Frais';

  @override
  String get statusUnknown => 'Inconnu';

  @override
  String daysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Reste $days jours',
      one: 'Reste 1 jour',
      zero: 'Expire aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Périmé depuis $days jours',
      one: 'Périmé hier',
      zero: 'Périmé aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String get searchPlaceholder => 'Rechercher un aliment par son nom...';

  @override
  String get filterAll => 'Tous';

  @override
  String get sortBy => 'Trier par';

  @override
  String get sortExpirySoonest => 'Péremption : Plus proche en premier';

  @override
  String get sortExpiryLatest => 'Péremption : Plus éloignée en premier';

  @override
  String get sortNameAZ => 'Nom : A à Z';

  @override
  String get sortNameZA => 'Nom : Z à A';

  @override
  String get emptyPantryTitle => 'Votre garde-manger est vide';

  @override
  String get emptyPantrySubtitle =>
      'Commencez à inventorier vos provisions pour cuisiner sans gaspiller.';

  @override
  String get emptySearchTitle =>
      'Aucun aliment ne correspond à votre recherche';

  @override
  String get emptySearchSubtitle =>
      'Essayez un autre mot-clé ou modifiez les filtres sélectionnés.';

  @override
  String get emptyExpiryTitle => 'Tout est sous contrôle !';

  @override
  String get emptyExpirySubtitle =>
      'Aucun aliment n\'est périmé ou sur le point de l\'être selon vos seuils d\'alerte.';

  @override
  String get emptyImpactTitle => 'Aucune activité enregistrée';

  @override
  String get emptyImpactSubtitle =>
      'À mesure que vous consommerez ou jetterez des aliments, Valora affichera ici votre bilan réel.';

  @override
  String get groupExpired => 'Périmés';

  @override
  String get groupExpiringToday => 'Expirent Aujourd\'hui';

  @override
  String get groupExpiringSoon => 'Expirent Bientôt';

  @override
  String get groupLater => 'Bon pour plus tard';

  @override
  String get groupUnknown => 'Date Inconnue';

  @override
  String get consumeDialogTitle => 'Enregistrer la consommation';

  @override
  String get consumeDialogPrompt => 'Quelle quantité avez-vous consommée ?';

  @override
  String get discardDialogTitle => 'Enregistrer le gaspillage';

  @override
  String get discardDialogPrompt => 'Quelle quantité a été jetée ?';

  @override
  String get resetFilters => 'Réinitialiser les filtres';

  @override
  String quantityRemaining(String qty, String unit) {
    return 'Disponible : $qty $unit';
  }

  @override
  String quantityOriginal(String qty, String unit) {
    return 'Initial : $qty $unit';
  }

  @override
  String quantityConsumed(String qty, String unit) {
    return 'Consommé : $qty $unit';
  }

  @override
  String quantityDiscarded(String qty, String unit) {
    return 'Jeté : $qty $unit';
  }

  @override
  String get deleteConfirmTitle => 'Supprimer l\'aliment ?';

  @override
  String deleteConfirmContent(String name) {
    return 'Êtes-vous sûr de vouloir supprimer \"$name\" ? L\'historique des activités sera conservé.';
  }

  @override
  String get actionSuccessSaved => 'Aliment enregistré avec succès.';

  @override
  String get actionSuccessConsumed => 'Consommation enregistrée.';

  @override
  String get actionSuccessDiscarded => 'Élimination enregistrée.';

  @override
  String get actionSuccessDeleted => 'Aliment retiré du garde-manger actif.';

  @override
  String get impactSummary => 'Bilan d\'activité';

  @override
  String get itemsConsumed => 'Aliments consommés enregistrés';

  @override
  String get itemsDiscarded => 'Aliments jetés enregistrés';

  @override
  String get valueConsumed => 'Valeur estimée consommée';

  @override
  String get valueDiscarded => 'Valeur estimée jetée';

  @override
  String get consumptionRate => 'Taux d\'utilisation';

  @override
  String get impactDisclaimer =>
      'Ces indicateurs sont calculés directement à partir de vos saisies réelles. Valora ne formule aucune estimation artificielle.';

  @override
  String get impactHistoryTitle => 'Journal des activités récentes';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsEnableNotifications => 'Rappels de péremption';

  @override
  String get settingsNotificationDesc =>
      'Soyez averti avant que vos aliments n\'atteignent leur date limite.';

  @override
  String get settingsNotificationThreshold => 'Délai de prévenance';

  @override
  String get settingsNotificationThresholdDesc =>
      'M\'avertir ce nombre de jours à l\'avance';

  @override
  String daysUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataManagement => 'Gestion des données';

  @override
  String get settingsExportData => 'Exporter les données (JSON)';

  @override
  String get settingsExportSuccess => 'Données exportées avec succès.';

  @override
  String get settingsImportData => 'Importer les données (JSON)';

  @override
  String get settingsImportSuccess => 'Données importées avec succès.';

  @override
  String get settingsImportInvalid => 'Fichier JSON invalide ou corrompu.';

  @override
  String get settingsClearData => 'Effacer toutes les données';

  @override
  String get settingsClearDataConfirm =>
      'Cette action est irréversible. Tous vos aliments et l\'historique d\'activité seront supprimés.';

  @override
  String get settingsClearDataSuccess =>
      'Toutes les données locales ont été effacées.';

  @override
  String get settingsAbout => 'À propos de Valora';

  @override
  String get settingsAboutDesc =>
      'Valora est une application offline-first pour organiser vos provisions et éviter le gaspillage alimentaire.';

  @override
  String get settingsPrivacy => 'Confidentialité & Stockage';

  @override
  String get settingsPrivacyDesc =>
      '100% de vos données restent sur cet appareil. Aucun traceur ni compte obligatoire.';

  @override
  String get settingsLicense => 'Licence Open Source';

  @override
  String get settingsLicenseDesc => 'Distribué sous licence open source MIT.';

  @override
  String get unsavedChangesTitle => 'Ignorer les modifications ?';

  @override
  String get unsavedChangesMessage =>
      'Des modifications n\'ont pas été enregistrées. Souhaitez-vous vraiment quitter ?';

  @override
  String get expirySafetyDisclaimerTitle =>
      'Avertissement et sécurité alimentaire';

  @override
  String get expirySafetyDisclaimerContent =>
      'Les dates indiquées sont des repères pour une conservation optimale. Vérifiez toujours l\'aspect, l\'odeur et la texture. Les aliments sans date nécessitent une vérification manuelle.';

  @override
  String get partial => 'Partiel';

  @override
  String quantityExceedsRemaining(String qty, String unit) {
    return 'Ne peut pas dépasser la quantité restante ($qty $unit)';
  }

  @override
  String get discardConfirmPermanent => 'Confirmer la mise au rebut';

  @override
  String discardConfirmPermanentPrompt(String qty, String unit, String name) {
    return 'Êtes-vous sûr de vouloir jeter $qty $unit de \"$name\" ? Cette action enregistre du gaspillage alimentaire.';
  }

  @override
  String get consumeNotesHint =>
      'Ex. : Dîner en famille, préparation culinaire';

  @override
  String get discardNotesHint => 'Ex. : Moisissure, date largement dépassée';

  @override
  String get homeNeedsAction => 'Action requise';

  @override
  String get homeAddFoodDesc => 'Enregistrez vos achats pour éviter les pertes';

  @override
  String get activityDetailsTitle => 'Détails de l\'activité';

  @override
  String get activityDate => 'Date et heure';

  @override
  String get activityType => 'Type d\'action';

  @override
  String get activityEstimatedValue => 'Valeur estimée';

  @override
  String get activityValueFormulaNotice =>
      'Calculé proportionnellement au prix d\'achat renseigné.';

  @override
  String get filterPeriod => 'Période';

  @override
  String get filterPeriodAll => 'Tout l\'historique';

  @override
  String get filterPeriod7Days => '7 derniers jours';

  @override
  String get filterPeriod30Days => '30 derniers jours';

  @override
  String get filterType => 'Type';

  @override
  String get filterTypeAll => 'Toutes les actions';

  @override
  String get filterTypeConsumed => 'Consommés uniquement';

  @override
  String get filterTypeDiscarded => 'Jetés uniquement';

  @override
  String get unitBreakdownTitle => 'Volume enregistré par unité';

  @override
  String get consumedUnits => 'Consommé';

  @override
  String get discardedUnits => 'Jeté';

  @override
  String get fromPricedItems => 'Provenant d\'articles avec prix renseigné';

  @override
  String get settingsPreferences => 'Préférences';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get themeSystem => 'Selon le système';

  @override
  String get themeLight => 'Mode clair';

  @override
  String get themeDark => 'Mode sombre';

  @override
  String get themeSystemOption => 'Système';

  @override
  String get themeLightOption => 'Clair';

  @override
  String get themeDarkOption => 'Sombre';

  @override
  String get copyToClipboard => 'Copier dans le presse-papiers';

  @override
  String get dataCopiedToClipboard =>
      'Données copiées dans le presse-papiers !';

  @override
  String exportFailed(String error) {
    return 'Échec de l\'exportation : $error';
  }

  @override
  String get importPastePrompt =>
      'Collez votre sauvegarde JSON Valora ci-dessous :';

  @override
  String get notificationPermissionDenied =>
      'L\'autorisation de notification n\'a pas été accordée dans les paramètres de l\'appareil.';

  @override
  String get appVersionDetails => 'Version 1.0.0 • Hack Club Cider Submission';

  @override
  String get selectLanguage => 'Choisir la langue / Select Language';

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
  String get langSystem => 'Par défaut du système';

  @override
  String get subscriptionTitle => 'Abonnement & Parrainage';

  @override
  String get subscriptionMonthlyPrice => '9,90 € / mois';

  @override
  String get subscriptionFreeTrial => '7 jours d\'essai gratuit';

  @override
  String get subscriptionTrialActive => 'Période d\'essai gratuit';

  @override
  String subscriptionTrialDaysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Il reste $days jours d\'essai',
      one: 'Il reste 1 jour d\'essai',
      zero: 'Dernier jour d\'essai gratuit',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionExpired => 'Période d\'essai expirée';

  @override
  String get subscriptionExpiredDesc =>
      'Pour continuer à utiliser Valora sur Android, abonnez-vous pour 9,90 €/mois ou invitez des amis.';

  @override
  String get subscriptionActive => 'Abonnement actif';

  @override
  String get subscribeButton => 'S\'abonner pour 9,90 € / mois';

  @override
  String get referralTitle => 'Parrainez et gagnez (+7 jours)';

  @override
  String get referralDesc =>
      'Pour chaque personne invitée, recevez +7 jours d\'accès gratuit supplémentaire !';

  @override
  String get referralYourCode => 'Votre code de parrainage';

  @override
  String get referralEnterCode => 'Entrer un code de parrainage';

  @override
  String get referralEnterCodePrompt =>
      'Saisissez le code d\'un ami pour recevoir +7 jours gratuits :';

  @override
  String get referralApply => 'Valider le code';

  @override
  String get referralSuccess =>
      'Félicitations ! Vous avez obtenu 7 jours gratuits supplémentaires !';

  @override
  String get referralAlreadyUsed => 'Ce code a déjà été utilisé.';

  @override
  String get referralSelfCode =>
      'Vous ne pouvez pas utiliser votre propre code.';

  @override
  String get referralInvalidCode => 'Code de parrainage non valide.';

  @override
  String get referralSimulateInvite => 'Simuler un ami invité (+7 jours)';

  @override
  String get referralShareText => 'Partager l\'invitation';

  @override
  String get referralInvitedCount => 'Amis invités';

  @override
  String get referralBonusDaysCount => 'Jours bonus cumulés';
}
