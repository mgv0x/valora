// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Valora';

  @override
  String get tagline => 'Não deixe comida boa ir para o lixo.';

  @override
  String get homeTitle => 'Início';

  @override
  String get pantryTitle => 'Despensa';

  @override
  String get expiryCenterTitle => 'Validades';

  @override
  String get impactTitle => 'Meu Impacto';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get greetingMorning => 'Bom dia';

  @override
  String get greetingAfternoon => 'Boa tarde';

  @override
  String get greetingEvening => 'Boa noite';

  @override
  String activeItemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alimentos ativos',
      one: '1 alimento ativo',
      zero: 'Nenhum alimento ativo',
    );
    return '$_temp0';
  }

  @override
  String needsAttentionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens requerem atenção',
      one: '1 item requer atenção',
      zero: 'Nenhum item com atenção',
    );
    return '$_temp0';
  }

  @override
  String expiringSoonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vencendo em breve',
      one: '1 vencendo em breve',
      zero: 'Nenhum vencendo em breve',
    );
    return '$_temp0';
  }

  @override
  String get priorityItems => 'Itens Prioritários';

  @override
  String get consumeFirstTitle => 'Consuma primeiro';

  @override
  String get insightNoneUrgent => 'Nenhum alimento precisa de atenção urgente.';

  @override
  String insightExpired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count alimentos já estão vencidos. Priorize estes itens para reduzir o desperdício.',
      one:
          '1 alimento já está vencido. Priorize estes itens para reduzir o desperdício.',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count alimentos vencem hoje. Priorize estes itens para reduzir o desperdício.',
      one:
          '1 alimento vence hoje. Priorize estes itens para reduzir o desperdício.',
    );
    return '$_temp0';
  }

  @override
  String insightExpiringTomorrow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Estes $count alimentos vencem amanhã.',
      one: 'Este alimento vence amanhã.',
    );
    return '$_temp0';
  }

  @override
  String get insightGeneralPriority =>
      'Priorize estes itens para reduzir o desperdício.';

  @override
  String get priorityHigh => 'Prioridade alta';

  @override
  String get priorityAttention => 'Atenção';

  @override
  String get priorityOnTrack => 'Em dia';

  @override
  String get viewAll => 'Ver todos';

  @override
  String get addFood => 'Adicionar Alimento';

  @override
  String get editFood => 'Editar Alimento';

  @override
  String get foodDetails => 'Detalhes do Alimento';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get confirm => 'Confirmar';

  @override
  String get consume => 'Consumir';

  @override
  String get discard => 'Descartar';

  @override
  String get markConsumed => 'Marcar como Consumido';

  @override
  String get markDiscarded => 'Marcar como Descartado';

  @override
  String get all => 'Todos';

  @override
  String get foodName => 'Nome do Alimento';

  @override
  String get foodNameHint => 'Ex: Leite Integral, Maçã Gala';

  @override
  String get foodNameRequired => 'Por favor, informe o nome do alimento';

  @override
  String get category => 'Categoria';

  @override
  String get categoryRequired => 'Por favor, selecione uma categoria';

  @override
  String get quantity => 'Quantidade';

  @override
  String get quantityRequired => 'Informe uma quantidade maior que zero';

  @override
  String get unit => 'Unidade';

  @override
  String get expiryDate => 'Data de Validade';

  @override
  String get unknownExpiry => 'Validade não informada';

  @override
  String get expiryDateRequired =>
      'Selecione uma data de validade ou marque como não informada';

  @override
  String get purchasePrice => 'Preço de Compra';

  @override
  String get purchasePriceOptional => 'Preço de Compra (opcional)';

  @override
  String get purchasePriceInvalid => 'O preço não pode ser negativo';

  @override
  String get storageLocation => 'Local de Armazenamento';

  @override
  String get storageLocationOptional => 'Local de Armazenamento (opcional)';

  @override
  String get purchaseDate => 'Data de Compra';

  @override
  String get purchaseDateOptional => 'Data de Compra (opcional)';

  @override
  String get notes => 'Observações';

  @override
  String get notesOptional => 'Observações (opcional)';

  @override
  String get notesHint => 'Marca, prateleira específica, lote, etc.';

  @override
  String get catFruits => 'Frutas';

  @override
  String get catVegetables => 'Legumes e Verduras';

  @override
  String get catDairy => 'Laticínios';

  @override
  String get catMeatFish => 'Carnes e Peixes';

  @override
  String get catBakery => 'Padaria';

  @override
  String get catPantryStaples => 'Grãos e Despensa';

  @override
  String get catFrozen => 'Congelados';

  @override
  String get catDrinks => 'Bebidas';

  @override
  String get catOther => 'Outros';

  @override
  String get locRefrigerator => 'Geladeira';

  @override
  String get locFreezer => 'Freezer';

  @override
  String get locPantry => 'Despensa';

  @override
  String get locOther => 'Outro local';

  @override
  String get unitPiece => 'un.';

  @override
  String get unitGram => 'g';

  @override
  String get unitKilogram => 'kg';

  @override
  String get unitMilliliter => 'ml';

  @override
  String get unitLiter => 'L';

  @override
  String get unitPackage => 'pct.';

  @override
  String get statusExpired => 'Vencido';

  @override
  String get statusExpiringToday => 'Vence hoje';

  @override
  String get statusExpiringSoon => 'Vence em breve';

  @override
  String get statusFresh => 'No prazo';

  @override
  String get statusUnknown => 'Não informada';

  @override
  String daysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Faltam $days dias',
      one: 'Falta 1 dia',
      zero: 'Vence hoje',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Venceu há $days dias',
      one: 'Venceu ontem',
      zero: 'Venceu hoje',
    );
    return '$_temp0';
  }

  @override
  String get searchPlaceholder => 'Buscar alimento por nome...';

  @override
  String get filterAll => 'Todos';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get sortExpirySoonest => 'Validade: Mais próxima primeiro';

  @override
  String get sortExpiryLatest => 'Validade: Mais distante primeiro';

  @override
  String get sortNameAZ => 'Nome: A a Z';

  @override
  String get sortNameZA => 'Nome: Z a A';

  @override
  String get emptyPantryTitle => 'Sua despensa está vazia';

  @override
  String get emptyPantrySubtitle =>
      'Comece a organizar os alimentos que você tem em casa para evitar desperdício e planejar melhor suas refeições.';

  @override
  String get emptySearchTitle => 'Nenhum alimento encontrado';

  @override
  String get emptySearchSubtitle =>
      'Tente buscar por outro termo ou ajuste os filtros selecionados.';

  @override
  String get emptyExpiryTitle => 'Tudo sob controle!';

  @override
  String get emptyExpirySubtitle =>
      'Nenhum alimento está vencido ou próximo do vencimento dentro do limite configurado.';

  @override
  String get emptyImpactTitle => 'Nenhuma atividade registrada ainda';

  @override
  String get emptyImpactSubtitle =>
      'Conforme você consumir ou descartar alimentos, o Valora exibirá seu histórico e estatísticas reais aqui.';

  @override
  String get groupExpired => 'Vencidos';

  @override
  String get groupExpiringToday => 'Vencem Hoje';

  @override
  String get groupExpiringSoon => 'Vencendo em Breve';

  @override
  String get groupLater => 'Vencem Depois';

  @override
  String get groupUnknown => 'Validade Não Informada';

  @override
  String get consumeDialogTitle => 'Registrar Consumo';

  @override
  String get consumeDialogPrompt => 'Quanto deste alimento você consumiu?';

  @override
  String get discardDialogTitle => 'Registrar Descarte';

  @override
  String get discardDialogPrompt => 'Quanto deste alimento foi descartado?';

  @override
  String get resetFilters => 'Limpar filtros';

  @override
  String quantityRemaining(String qty, String unit) {
    return 'Disponível: $qty $unit';
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
    return 'Descartado: $qty $unit';
  }

  @override
  String get deleteConfirmTitle => 'Excluir Alimento?';

  @override
  String deleteConfirmContent(String name) {
    return 'Tem certeza que deseja excluir \"$name\"? O histórico de ações anteriores será preservado.';
  }

  @override
  String get actionSuccessSaved => 'Alimento salvo com sucesso.';

  @override
  String get actionSuccessConsumed => 'Consumo registrado com sucesso.';

  @override
  String get actionSuccessDiscarded => 'Descarte registrado com sucesso.';

  @override
  String get actionSuccessDeleted => 'Item removido da despensa ativa.';

  @override
  String get impactSummary => 'Resumo de Atividades';

  @override
  String get itemsConsumed => 'Alimentos consumidos registrados';

  @override
  String get itemsDiscarded => 'Alimentos descartados registrados';

  @override
  String get valueConsumed => 'Valor estimado de consumo';

  @override
  String get valueDiscarded => 'Valor estimado de desperdício';

  @override
  String get consumptionRate => 'Taxa de aproveitamento';

  @override
  String get impactDisclaimer =>
      'Métricas calculadas exclusivamente a partir das atividades registradas. O Valora nunca inventa números ou estimativas ambientais.';

  @override
  String get impactHistoryTitle => 'Histórico Recente de Atividades';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsNotifications => 'Notificações';

  @override
  String get settingsEnableNotifications => 'Lembretes de Validade';

  @override
  String get settingsNotificationDesc =>
      'Receba avisos antes que os alimentos atinjam a data de validade.';

  @override
  String get settingsNotificationThreshold => 'Aviso prévio';

  @override
  String get settingsNotificationThresholdDesc =>
      'Avisar com quantos dias de antecedência';

  @override
  String daysUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String get settingsDataManagement => 'Gerenciamento de Dados';

  @override
  String get settingsExportData => 'Exportar Dados (JSON)';

  @override
  String get settingsExportSuccess => 'Dados exportados com sucesso.';

  @override
  String get settingsImportData => 'Importar Dados (JSON)';

  @override
  String get settingsImportSuccess => 'Dados importados com sucesso.';

  @override
  String get settingsImportInvalid => 'Arquivo JSON inválido ou incompatível.';

  @override
  String get settingsClearData => 'Apagar Todos os Dados';

  @override
  String get settingsClearDataConfirm =>
      'Esta ação não pode ser desfeita. Todos os alimentos e histórico de consumo/descarte serão apagados.';

  @override
  String get settingsClearDataSuccess =>
      'Todos os dados locais foram excluídos.';

  @override
  String get settingsAbout => 'Sobre o Valora';

  @override
  String get settingsAboutDesc =>
      'O Valora é um aplicativo offline-first para gerenciamento de despensa e redução de desperdício de alimentos, criado para o desafio Hack Club Cider.';

  @override
  String get settingsPrivacy => 'Privacidade e Armazenamento';

  @override
  String get settingsPrivacyDesc =>
      'Todos os seus dados permanecem 100% no seu dispositivo. Sem rastreadores, sem contas na nuvem.';

  @override
  String get settingsLicense => 'Licença de Código Aberto';

  @override
  String get settingsLicenseDesc =>
      'Distribuído sob a licença de código aberto MIT.';

  @override
  String get unsavedChangesTitle => 'Descartar alterações?';

  @override
  String get unsavedChangesMessage =>
      'Você tem alterações não salvas. Deseja realmente sair sem salvar?';

  @override
  String get expirySafetyDisclaimerTitle => 'Aviso de Validade e Conservação';

  @override
  String get expirySafetyDisclaimerContent =>
      'As datas de validade são estimativas de conservação e qualidade recomendada. Avalie sempre o aspecto, odor e textura. Alimentos sem data informada requerem atenção manual e não são presumidos como automaticamente seguros ou vencidos.';

  @override
  String get partial => 'Parcial';

  @override
  String quantityExceedsRemaining(String qty, String unit) {
    return 'Não pode exceder o estoque restante ($qty $unit)';
  }

  @override
  String get discardConfirmPermanent => 'Confirmar Descarte';

  @override
  String discardConfirmPermanentPrompt(String qty, String unit, String name) {
    return 'Tem certeza de que deseja descartar $qty $unit de \"$name\"? Esta ação registrará desperdício e não pode ser desfeita.';
  }

  @override
  String get consumeNotesHint => 'Ex.: Preparou jantar, marmita';

  @override
  String get discardNotesHint => 'Ex.: Estragou, passou do ponto';

  @override
  String get homeNeedsAction => 'Atenção';

  @override
  String get homeAddFoodDesc =>
      'Registre novos alimentos para evitar desperdício';

  @override
  String get activityDetailsTitle => 'Detalhes da Atividade';

  @override
  String get activityDate => 'Data e Hora';

  @override
  String get activityType => 'Tipo de Ação';

  @override
  String get activityEstimatedValue => 'Valor Estimado';

  @override
  String get activityValueFormulaNotice =>
      'Calculado proporcionalmente a partir do preço de compra informado.';

  @override
  String get filterPeriod => 'Período';

  @override
  String get filterPeriodAll => 'Todo o período';

  @override
  String get filterPeriod7Days => 'Últimos 7 dias';

  @override
  String get filterPeriod30Days => 'Últimos 30 dias';

  @override
  String get filterType => 'Tipo';

  @override
  String get filterTypeAll => 'Todas as ações';

  @override
  String get filterTypeConsumed => 'Apenas consumo';

  @override
  String get filterTypeDiscarded => 'Apenas descarte';

  @override
  String get unitBreakdownTitle => 'Volume Registrado por Unidade';

  @override
  String get consumedUnits => 'Consumido';

  @override
  String get discardedUnits => 'Descartado';

  @override
  String get fromPricedItems => 'De alimentos com preço informado';

  @override
  String get settingsPreferences => 'Preferências';

  @override
  String get settingsTheme => 'Aparência';

  @override
  String get themeSystem => 'Padrão do Sistema';

  @override
  String get themeLight => 'Modo Claro';

  @override
  String get themeDark => 'Modo Escuro';

  @override
  String get themeSystemOption => 'Sistema';

  @override
  String get themeLightOption => 'Claro';

  @override
  String get themeDarkOption => 'Escuro';

  @override
  String get copyToClipboard => 'Copiar para Área de Transferência';

  @override
  String get dataCopiedToClipboard =>
      'Dados copiados para a área de transferência!';

  @override
  String exportFailed(String error) {
    return 'Falha ao exportar: $error';
  }

  @override
  String get importPastePrompt =>
      'Cole o backup JSON exportado do Valora abaixo:';

  @override
  String get notificationPermissionDenied =>
      'Permissão de notificações não concedida nas configurações do dispositivo.';

  @override
  String get appVersionDetails => 'Versão 1.0.0 • Submissão Hack Club Cider';

  @override
  String get selectLanguage => 'Escolha o Idioma / Select Language';

  @override
  String get langPortuguese => 'Português (Brasil)';

  @override
  String get langEnglish => 'Inglês (English)';

  @override
  String get langSpanish => 'Espanhol (Español)';

  @override
  String get langFrench => 'Francês (Français)';

  @override
  String get langGerman => 'Alemão (Deutsch)';

  @override
  String get langItalian => 'Italiano';

  @override
  String get langChinese => 'Chinês Simplificado (中文)';

  @override
  String get langJapanese => 'Japonês (日本語)';

  @override
  String get langRussian => 'Russo (Русский)';

  @override
  String get langArabic => 'Árabe (العربية)';

  @override
  String get langHindi => 'Hindi (हिन्दी)';

  @override
  String get langSystem => 'Padrão do Sistema / System Default';

  @override
  String get subscriptionTitle => 'Assinatura & Convites';

  @override
  String get subscriptionMonthlyPrice => 'R\$ 9,90 / mês';

  @override
  String get subscriptionFreeTrial => '7 Dias de Teste Grátis';

  @override
  String get subscriptionTrialActive => 'Período de Teste Grátis';

  @override
  String subscriptionTrialDaysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Faltam $days dias de teste grátis',
      one: 'Falta 1 dia de teste grátis',
      zero: 'Último dia de teste grátis',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionExpired => 'Período de Teste Expirado';

  @override
  String get subscriptionExpiredDesc =>
      'Para continuar usando o Valora no Android, assine o plano mensal por R\$ 9,90 ou convide amigos para ganhar mais dias grátis.';

  @override
  String get subscriptionActive => 'Assinatura Ativa';

  @override
  String get subscribeButton => 'Assinar por R\$ 9,90 / mês';

  @override
  String get referralTitle => 'Indique e Ganhe (+7 Dias)';

  @override
  String get referralDesc =>
      'A cada pessoa que você convidar, você ganha mais 7 dias de acesso grátis!';

  @override
  String get referralYourCode => 'Seu Código de Convite';

  @override
  String get referralEnterCode => 'Inserir Código de Convite';

  @override
  String get referralEnterCodePrompt =>
      'Digite o código de convite de um amigo para ganhar +7 dias:';

  @override
  String get referralApply => 'Aplicar Código';

  @override
  String get referralSuccess =>
      'Parabéns! Você ganhou +7 dias extras de acesso grátis!';

  @override
  String get referralAlreadyUsed =>
      'Você já resgatou este código anteriormente.';

  @override
  String get referralSelfCode =>
      'Você não pode usar o seu próprio código de convite.';

  @override
  String get referralInvalidCode => 'Código de convite inválido.';

  @override
  String get referralSimulateInvite => 'Simular Amigo Convidado (+7 dias)';

  @override
  String get referralShareText => 'Compartilhar Convite';

  @override
  String get referralInvitedCount => 'Amigos convidados';

  @override
  String get referralBonusDaysCount => 'Dias bônus ganhos';
}
