// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Valora';

  @override
  String get tagline => 'Desperdicia menos. Vive mejor.';

  @override
  String get homeTitle => 'Inicio';

  @override
  String get pantryTitle => 'Despensa';

  @override
  String get expiryCenterTitle => 'Caducidad';

  @override
  String get impactTitle => 'Mi Impacto';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get greetingAfternoon => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String activeItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alimentos activos',
      one: '1 alimento activo',
      zero: 'Sin alimentos activos',
    );
    return '$_temp0';
  }

  @override
  String needsAttentionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alimentos requieren atención',
      one: '1 alimento requiere atención',
      zero: 'Ninguno requiere atención',
    );
    return '$_temp0';
  }

  @override
  String expiringSoonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count por caducar pronto',
      one: '1 por caducar pronto',
      zero: 'Ninguno por caducar',
    );
    return '$_temp0';
  }

  @override
  String get priorityItems => 'Artículos prioritarios';

  @override
  String get consumeFirstTitle => 'Consumir primero';

  @override
  String get insightNoneUrgent => 'Ningún alimento requiere atención urgente.';

  @override
  String insightExpired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count alimentos ya han caducado. Prioriza estos artículos para reducir el desperdicio.',
      one:
          '1 alimento ya ha caducado. Prioriza estos artículos para reducir el desperdicio.',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count alimentos caducan hoy. Prioriza estos artículos para reducir el desperdicio.',
      one:
          '1 alimento caduca hoy. Prioriza estos artículos para reducir el desperdicio.',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringTomorrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Estos $count alimentos caducan mañana.',
      one: 'Este alimento caduca mañana.',
    );
    return '$_temp0';
  }

  @override
  String get insightGeneralPriority =>
      'Prioriza estos artículos para reducir el desperdicio.';

  @override
  String get priorityHigh => 'Prioridad alta';

  @override
  String get priorityAttention => 'Atención';

  @override
  String get priorityOnTrack => 'Al día';

  @override
  String get viewAll => 'Ver todos';

  @override
  String get addFood => 'Añadir Alimento';

  @override
  String get editFood => 'Editar Alimento';

  @override
  String get foodDetails => 'Detalles del Alimento';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get consume => 'Consumir';

  @override
  String get discard => 'Desechar';

  @override
  String get markConsumed => 'Marcar como Consumido';

  @override
  String get markDiscarded => 'Marcar como Desechado';

  @override
  String get all => 'Todos';

  @override
  String get foodName => 'Nombre del Alimento';

  @override
  String get foodNameHint => 'Ej.: Leche entera, Manzanas frescas';

  @override
  String get foodNameRequired => 'Por favor, introduce el nombre del alimento';

  @override
  String get category => 'Categoría';

  @override
  String get categoryRequired => 'Por favor, selecciona una categoría';

  @override
  String get quantity => 'Cantidad';

  @override
  String get quantityRequired => 'Introduce una cantidad mayor que 0';

  @override
  String get unit => 'Unidad';

  @override
  String get expiryDate => 'Fecha de Caducidad';

  @override
  String get unknownExpiry => 'Caducidad no especificada';

  @override
  String get expiryDateRequired =>
      'Selecciona una fecha de caducidad o marca como no especificada';

  @override
  String get purchasePrice => 'Precio de Compra';

  @override
  String get purchasePriceOptional => 'Precio de Compra (opcional)';

  @override
  String get purchasePriceInvalid => 'El precio no puede ser negativo';

  @override
  String get storageLocation => 'Lugar de Conservación';

  @override
  String get storageLocationOptional => 'Lugar de Conservación (opcional)';

  @override
  String get purchaseDate => 'Fecha de Compra';

  @override
  String get purchaseDateOptional => 'Fecha de Compra (opcional)';

  @override
  String get notes => 'Notas';

  @override
  String get notesOptional => 'Notas (opcional)';

  @override
  String get notesHint => 'Marca, estante específico, lote, etc.';

  @override
  String get catFruits => 'Frutas';

  @override
  String get catVegetables => 'Verduras y Hortalizas';

  @override
  String get catDairy => 'Lácteos';

  @override
  String get catMeatFish => 'Carnes y Pescados';

  @override
  String get catBakery => 'Panadería y Repostería';

  @override
  String get catPantryStaples => 'Despensa y Granos';

  @override
  String get catFrozen => 'Congelados';

  @override
  String get catDrinks => 'Bebidas';

  @override
  String get catOther => 'Otros';

  @override
  String get locRefrigerator => 'Refrigerador';

  @override
  String get locFreezer => 'Congelador';

  @override
  String get locPantry => 'Despensa';

  @override
  String get locOther => 'Otro lugar';

  @override
  String get unitPiece => 'ud.';

  @override
  String get unitGram => 'g';

  @override
  String get unitKilogram => 'kg';

  @override
  String get unitMilliliter => 'ml';

  @override
  String get unitLiter => 'L';

  @override
  String get unitPackage => 'paq.';

  @override
  String get statusExpired => 'Caducado';

  @override
  String get statusExpiringToday => 'Caduca hoy';

  @override
  String get statusExpiringSoon => 'Caduca pronto';

  @override
  String get statusFresh => 'Fresco';

  @override
  String get statusUnknown => 'Sin fecha';

  @override
  String daysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Quedan $days días',
      one: 'Queda 1 día',
      zero: 'Caduca hoy',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Caducó hace $days días',
      one: 'Caducó ayer',
      zero: 'Caducó hoy',
    );
    return '$_temp0';
  }

  @override
  String get searchPlaceholder => 'Buscar alimento por nombre...';

  @override
  String get filterAll => 'Todos';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get sortExpirySoonest => 'Caducidad: Más próxima primero';

  @override
  String get sortExpiryLatest => 'Caducidad: Más lejana primero';

  @override
  String get sortNameAZ => 'Nombre: A a Z';

  @override
  String get sortNameZA => 'Nombre: Z a A';

  @override
  String get emptyPantryTitle => 'Tu despensa está vacía';

  @override
  String get emptyPantrySubtitle =>
      'Comienza a registrar lo que tienes en casa para evitar desperdicios y organizar tus comidas.';

  @override
  String get emptySearchTitle => 'Sin resultados para tu búsqueda';

  @override
  String get emptySearchSubtitle =>
      'Prueba a buscar con otra palabra clave o ajusta los filtros seleccionados.';

  @override
  String get emptyExpiryTitle => '¡Todo en orden!';

  @override
  String get emptyExpirySubtitle =>
      'No hay alimentos caducados ni próximos a caducar dentro del umbral configurado.';

  @override
  String get emptyImpactTitle => 'Aún no hay actividad registrada';

  @override
  String get emptyImpactSubtitle =>
      'A medida que consumas o deseches alimentos, Valora mostrará tu balance e historial aquí.';

  @override
  String get groupExpired => 'Caducados';

  @override
  String get groupExpiringToday => 'Caducan Hoy';

  @override
  String get groupExpiringSoon => 'Caducan Pronto';

  @override
  String get groupLater => 'Válidos para más adelante';

  @override
  String get groupUnknown => 'Sin Fecha de Caducidad';

  @override
  String get consumeDialogTitle => 'Registrar Consumo';

  @override
  String get consumeDialogPrompt =>
      '¿Qué cantidad de este alimento has consumido?';

  @override
  String get discardDialogTitle => 'Registrar Desecho';

  @override
  String get discardDialogPrompt =>
      '¿Qué cantidad de este alimento ha sido desechada?';

  @override
  String get resetFilters => 'Restablecer filtros';

  @override
  String quantityRemaining(String qty, String unit) {
    return 'Disponible: $qty $unit';
  }

  @override
  String quantityOriginal(String qty, String unit) {
    return 'Original: $qty $unit';
  }

  @override
  String quantityConsumed(String qty, String unit) {
    return 'Consumido: $qty $unit';
  }

  @override
  String quantityDiscarded(String qty, String unit) {
    return 'Desechado: $qty $unit';
  }

  @override
  String get deleteConfirmTitle => '¿Eliminar Alimento?';

  @override
  String deleteConfirmContent(String name) {
    return '¿Seguro que deseas eliminar \"$name\"? El historial de actividades anteriores se conservará.';
  }

  @override
  String get actionSuccessSaved => 'Alimento guardado con éxito.';

  @override
  String get actionSuccessConsumed => 'Consumo registrado correctamente.';

  @override
  String get actionSuccessDiscarded => 'Desecho registrado correctamente.';

  @override
  String get actionSuccessDeleted =>
      'Alimento eliminado de la despensa activa.';

  @override
  String get impactSummary => 'Resumen de Actividad';

  @override
  String get itemsConsumed => 'Alimentos consumidos registrados';

  @override
  String get itemsDiscarded => 'Alimentos desechados registrados';

  @override
  String get valueConsumed => 'Valor estimado aprovechado';

  @override
  String get valueDiscarded => 'Valor estimado desperdiciado';

  @override
  String get consumptionRate => 'Tasa de aprovechamiento';

  @override
  String get impactDisclaimer =>
      'Métricas calculadas directamente a partir de la actividad registrada. Valora nunca inventa estimaciones ficticias.';

  @override
  String get impactHistoryTitle => 'Historial Reciente de Actividad';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsEnableNotifications => 'Recordatorios de Caducidad';

  @override
  String get settingsNotificationDesc =>
      'Recibe avisos antes de que los alimentos alcancen su fecha de caducidad.';

  @override
  String get settingsNotificationThreshold => 'Aviso previo';

  @override
  String get settingsNotificationThresholdDesc =>
      'Avisarme con cuántos días de antelación';

  @override
  String daysUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataManagement => 'Gestión de Datos';

  @override
  String get settingsExportData => 'Exportar Datos (JSON)';

  @override
  String get settingsExportSuccess => 'Datos exportados correctamente.';

  @override
  String get settingsImportData => 'Importar Datos (JSON)';

  @override
  String get settingsImportSuccess => 'Datos importados correctamente.';

  @override
  String get settingsImportInvalid => 'Archivo JSON inválido o incompatible.';

  @override
  String get settingsClearData => 'Borrar Todos los Datos';

  @override
  String get settingsClearDataConfirm =>
      'Esta acción no se puede deshacer. Se borrarán todos los alimentos activos y el historial de actividad.';

  @override
  String get settingsClearDataSuccess =>
      'Todos los datos locales han sido borrados.';

  @override
  String get settingsAbout => 'Acerca de Valora';

  @override
  String get settingsAboutDesc =>
      'Valora es una aplicación offline-first para organizar tu despensa y reducir el desperdicio de comida.';

  @override
  String get settingsPrivacy => 'Privacidad y Almacenamiento';

  @override
  String get settingsPrivacyDesc =>
      'Todos tus datos permanecen al 100% en tu dispositivo. Sin rastreadores ni cuentas obligatorias.';

  @override
  String get settingsLicense => 'Licencia de Código Abierto';

  @override
  String get settingsLicenseDesc =>
      'Distribuido bajo la licencia de código abierto MIT.';

  @override
  String get unsavedChangesTitle => '¿Descartar cambios?';

  @override
  String get unsavedChangesMessage =>
      'Tienes cambios sin guardar. ¿Seguro que deseas salir sin guardar?';

  @override
  String get expirySafetyDisclaimerTitle =>
      'Aviso de Caducidad y Seguridad Alimentaria';

  @override
  String get expirySafetyDisclaimerContent =>
      'Las fechas de caducidad son pautas para una conservación óptima. Revisa siempre el aspecto, aroma y textura. Los alimentos sin fecha informada requieren inspección manual.';

  @override
  String get partial => 'Parcial';

  @override
  String quantityExceedsRemaining(String qty, String unit) {
    return 'No puede superar la cantidad restante ($qty $unit)';
  }

  @override
  String get discardConfirmPermanent => 'Confirmar Desecho';

  @override
  String discardConfirmPermanentPrompt(String qty, String unit, String name) {
    return '¿Seguro que deseas desechar $qty $unit de \"$name\"? Esta acción registrará desperdicio y no se puede deshacer.';
  }

  @override
  String get consumeNotesHint => 'Ej.: Cena familiar, preparación de comidas';

  @override
  String get discardNotesHint => 'Ej.: Pasado de fecha, estropeado';

  @override
  String get homeNeedsAction => 'Requiere Acción';

  @override
  String get homeAddFoodDesc => 'Registra compras para prevenir el desperdicio';

  @override
  String get activityDetailsTitle => 'Detalles de la Actividad';

  @override
  String get activityDate => 'Fecha y Hora';

  @override
  String get activityType => 'Tipo de Acción';

  @override
  String get activityEstimatedValue => 'Valor Estimado';

  @override
  String get activityValueFormulaNotice =>
      'Calculado proporcionalmente según el precio de compra introducido.';

  @override
  String get filterPeriod => 'Período';

  @override
  String get filterPeriodAll => 'Todo el historial';

  @override
  String get filterPeriod7Days => 'Últimos 7 días';

  @override
  String get filterPeriod30Days => 'Últimos 30 días';

  @override
  String get filterType => 'Tipo';

  @override
  String get filterTypeAll => 'Todas las acciones';

  @override
  String get filterTypeConsumed => 'Solo consumo';

  @override
  String get filterTypeDiscarded => 'Solo desecho';

  @override
  String get unitBreakdownTitle => 'Volumen Registrado por Unidad';

  @override
  String get consumedUnits => 'Consumido';

  @override
  String get discardedUnits => 'Desechado';

  @override
  String get fromPricedItems => 'De alimentos con precio informado';

  @override
  String get settingsPreferences => 'Preferencias';

  @override
  String get settingsTheme => 'Apariencia';

  @override
  String get themeSystem => 'Predeterminado del Sistema';

  @override
  String get themeLight => 'Modo Claro';

  @override
  String get themeDark => 'Modo Oscuro';

  @override
  String get themeSystemOption => 'Sistema';

  @override
  String get themeLightOption => 'Claro';

  @override
  String get themeDarkOption => 'Oscuro';

  @override
  String get copyToClipboard => 'Copiar al Portapapeles';

  @override
  String get dataCopiedToClipboard => '¡Datos copiados al portapapeles!';

  @override
  String exportFailed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String get importPastePrompt =>
      'Pega a continuación el archivo de copia de seguridad JSON de Valora:';

  @override
  String get notificationPermissionDenied =>
      'El permiso de notificaciones no fue concedido en los ajustes del dispositivo.';

  @override
  String get appVersionDetails => 'Versión 1.0.0 • Hack Club Cider Submission';

  @override
  String get selectLanguage => 'Seleccionar Idioma / Select Language';

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
  String get langSystem => 'Predeterminado del Sistema';

  @override
  String get subscriptionTitle => 'Suscripción e Invitaciones';

  @override
  String get subscriptionMonthlyPrice => '9,90 \$ / mes';

  @override
  String get subscriptionFreeTrial => '7 Días de Prueba Gratis';

  @override
  String get subscriptionTrialActive => 'Período de Prueba Gratis';

  @override
  String subscriptionTrialDaysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Quedan $days días de prueba gratuita',
      one: 'Queda 1 día de prueba gratuita',
      zero: 'Último día de prueba gratuita',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionExpired => 'Período de Prueba Vencido';

  @override
  String get subscriptionExpiredDesc =>
      'Para continuar usando Valora en Android, suscríbete por 9,90 \$/mes o invita amigos para ganar días gratis.';

  @override
  String get subscriptionActive => 'Suscripción Activa';

  @override
  String get subscribeButton => 'Suscribirse por 9,90 \$ / mes';

  @override
  String get referralTitle => 'Invita y Gana (+7 Días)';

  @override
  String get referralDesc =>
      '¡Por cada persona que invites, obtienes +7 días extra de acceso gratuito!';

  @override
  String get referralYourCode => 'Tu Código de Invitación';

  @override
  String get referralEnterCode => 'Introducir Código de Invitación';

  @override
  String get referralEnterCodePrompt =>
      'Introduce el código de un amigo para ganar +7 días adicionales:';

  @override
  String get referralApply => 'Aplicar Código';

  @override
  String get referralSuccess =>
      '¡Felicidades! Has ganado +7 días de acceso gratuito.';

  @override
  String get referralAlreadyUsed =>
      'Ya has canjeado este código de invitación.';

  @override
  String get referralSelfCode =>
      'No puedes usar tu propio código de invitación.';

  @override
  String get referralInvalidCode => 'Código de invitación no válido.';

  @override
  String get referralSimulateInvite => 'Simular Amigo Invitado (+7 días)';

  @override
  String get referralShareText => 'Compartir Invitación';

  @override
  String get referralInvitedCount => 'Amigos invitados';

  @override
  String get referralBonusDaysCount => 'Días adicionales obtenidos';
}
