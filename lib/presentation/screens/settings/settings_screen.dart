import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../data/local/food_repository.dart';
import '../../../state/impact_provider.dart';
import '../../../state/pantry_provider.dart';
import '../../../state/settings_provider.dart';
import '../../../state/subscription_provider.dart';
import '../auth/edit_profile_sheet.dart';
import '../auth/login_screen.dart';
import '../data_management/data_management_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../referral/referral_screen.dart';
import '../subscription/subscription_screen.dart';
import 'privacy_policy_screen.dart';
import 'widgets/language_selection_sheet.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _getLanguageLabel(String? code) {
    switch (code) {
      case 'pt':
        return 'Português 🇧🇷';
      case 'en':
        return 'English 🇺🇸';
      case 'es':
        return 'Español 🇪🇸';
      case 'fr':
        return 'Français 🇫🇷';
      case 'de':
        return 'Deutsch 🇩🇪';
      case 'it':
        return 'Italiano 🇮🇹';
      case 'zh':
        return '简体中文 🇨🇳';
      case 'ja':
        return '日本語 🇯🇵';
      case 'ru':
        return 'Русский 🇷🇺';
      case 'ar':
        return 'العربية 🇸🇦';
      case 'hi':
        return 'हिन्दी 🇮🇳';
      default:
        return 'Padrão 🌐';
    }
  }

  void _openSubscription(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );
  }

  void _openReferral(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ReferralScreen()),
    );
  }

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Sair da Conta?',
      content: 'Você será desconectado e poderá entrar novamente a qualquer momento.',
      confirmLabel: 'Sair da Conta',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final settings = context.read<SettingsProvider>();
      await settings.logout();
      if (!context.mounted) return;
      UiFeedback.showInfo(context, 'Sessão encerrada com sucesso.');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen(isMandatory: true)),
        (route) => false,
      );
    }
  }

  Future<void> _exportData(BuildContext context) async {
    final repo = context.read<FoodRepository>();
    try {
      final data = await repo.exportData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Exportar Dados'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonString,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Fechar'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copiar JSON'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  try {
                    await Clipboard.setData(ClipboardData(text: jsonString));
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      UiFeedback.showSuccess(context, 'Dados copiados para a área de transferência!');
                    }
                  } catch (_) {
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      UiFeedback.showInfo(context, 'Backup gerado.');
                    }
                  }
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        UiFeedback.showError(context, 'Erro ao exportar dados: $e');
      }
    }
  }

  Future<void> _importData(BuildContext context) async {
    final repo = context.read<FoodRepository>();
    final pantryProvider = context.read<PantryProvider>();
    final impactProvider = context.read<ImpactProvider>();
    final textController = TextEditingController();

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Importar Dados JSON'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Atenção: A importação de backup substitui os itens atuais da despensa e o histórico pelos dados importados. Cole o JSON abaixo para prosseguir:',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                maxLines: 6,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                decoration: const InputDecoration(
                  hintText: 'Cole o JSON aqui...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.forestGreen, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Importar'),
            ),
          ],
        ),
      );

      if (confirmed == true && textController.text.trim().isNotEmpty && context.mounted) {
        final rawText = textController.text.trim();
        if (rawText.length > 5 * 1024 * 1024) {
          if (context.mounted) {
            UiFeedback.showError(context, 'O arquivo excede o limite máximo de segurança (5 MB).');
          }
          return;
        }
        try {
          final dynamic rawDecoded = jsonDecode(rawText);
          if (rawDecoded is! Map) {
            if (context.mounted) {
              UiFeedback.showError(context, 'O arquivo de backup deve ser um objeto JSON válido.');
            }
            return;
          }
          final decoded = Map<String, dynamic>.from(rawDecoded);
          final success = await repo.importData(decoded);
          if (!success) {
            if (context.mounted) {
              UiFeedback.showError(context, 'Dados incompatíveis ou arquivo corrompido.');
            }
            return;
          }
          await pantryProvider.loadItems();
          await impactProvider.loadActivities();
          if (context.mounted) {
            UiFeedback.showSuccess(context, 'Dados importados com sucesso!');
          }
        } catch (e) {
          if (context.mounted) {
            UiFeedback.showError(context, 'Falha ao importar dados. Verifique a formatação JSON.');
          }
        }
      }
    } finally {
      textController.dispose();
    }
  }

  Future<void> _clearAllPantry(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Limpar Despensa?',
      content: 'Tem certeza de que deseja excluir todos os alimentos da despensa? Esta ação não pode ser desfeita.',
      confirmLabel: 'Limpar Tudo',
      cancelLabel: 'Cancelar',
      isDestructive: true,
    );

    if (confirmed && context.mounted) {
      final repo = context.read<FoodRepository>();
      final pantry = context.read<PantryProvider>();
      final impact = context.read<ImpactProvider>();
      await pantry.notificationService?.cancelAll();
      await repo.clearAllData();
      await pantry.loadItems();
      await impact.loadActivities();
      if (context.mounted) {
        UiFeedback.showSuccess(context, 'Despensa limpa com sucesso.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<SubscriptionProvider>();
    final settings = context.watch<SettingsProvider>();
    final pantry = context.watch<PantryProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 24, color: AppColors.subHeader),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(
                  'Configurações',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestGreen,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 12),

            // Card 1: Perfil do Usuário
            Container(
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), offset: Offset(0, 2), blurRadius: 8),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceContainerLow,
                              border: Border.all(color: AppColors.border, width: 1.5),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: (settings.userAvatar != null)
                                ? Image.network(
                                    settings.userAvatar!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Center(
                                      child: Text(
                                        settings.userInitials,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.forestGreen,
                                        ),
                                      ),
                                    ),
                                  )
                                : (settings.userName == 'Helena Silva')
                                    ? Image.network(
                                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAjgcHmhmo08MLh7U7-dlh_-souE9lF8rd0VzUeXuAKB0-q1YuA40S9xp1tLsJpIF2xhY4yNCrINLmGfeFCf3RgHuu2akqYGx9veEVbiIR744b8kVqq3M8O68x82Sf30NLx8RkAARNlyJKXvvXbV1O6DT4mK8iZd6EEuWQm9XhvBtu5odUFmOulwFVhQAfIzM3WvffcgNOjL_8S5VlY_uNYilZ55EhMZXVtinznVcySDEWysBjQFY0cvQ',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Center(
                                          child: Text(
                                            settings.userInitials,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.forestGreen,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          settings.userInitials,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.forestGreen,
                                          ),
                                        ),
                                      ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: settings.isLoggedIn ? AppColors.forestGreen : AppColors.softGray,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),

                      // Name, email & badge
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  settings.userName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.charcoal,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: subscription.isSubscribed
                                        ? const Color(0xFFD0EAC9)
                                        : (subscription.isTrialActive
                                            ? const Color(0xFFE8F5E9)
                                            : const Color(0xFFFFEBEE)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    subscription.isSubscribed
                                        ? 'Premium'
                                        : (subscription.isTrialActive
                                            ? 'Teste Grátis (${subscription.daysRemainingInTrial}d)'
                                            : 'Teste Expirado'),
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: subscription.isSubscribed
                                          ? AppColors.forestGreen
                                          : (subscription.isTrialActive
                                              ? AppColors.forestGreen
                                              : Colors.red.shade700),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              settings.userEmail,
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.softGray),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.subHeader),
                        onPressed: () => EditProfileSheet.show(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Micro convite
                  InkWell(
                    onTap: () => _openSubscription(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.stars_rounded, size: 18, color: AppColors.forestGreen),
                              const SizedBox(width: 8),
                              Text(
                                subscription.isSubscribed
                                    ? 'Assinatura Premium Ativa'
                                    : (subscription.isTrialActive
                                        ? 'Período de Teste: ${subscription.daysRemainingInTrial} dias restantes'
                                        : 'Teste de 7 dias encerrado · Assinar'),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.forestGreen,
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward, size: 16, color: AppColors.subHeader),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 2: Banner Valora Premium Sofisticado
            Container(
              decoration: BoxDecoration(
                color: AppColors.forestGreen,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x1A294D3A), offset: Offset(0, 4), blurRadius: 10),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.workspace_premium, size: 14, color: Color(0xFFC3ECD2)),
                            const SizedBox(width: 4),
                            Text(
                              'Upgrade Exclusivo',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFC3ECD2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        subscription.isSubscribed
                            ? 'Assinatura Ativa'
                            : (subscription.isTrialActive
                                ? '${subscription.daysRemainingInTrial} dias de teste restantes'
                                : 'Teste de 7 dias expirado'),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Valora Premium',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Leitura de nota fiscal por IA, notificações inteligentes e estatísticas completas de pegada de carbono.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.4,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'R\$ 9,90',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '/mês após teste',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => _openSubscription(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.forestGreen,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(subscription.isSubscribed ? 'Gerenciar' : 'Desbloquear'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Seção 1: Preferências da Despensa
            _buildSectionLabel('PREFERÊNCIAS DA DESPENSA'),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                children: [
                  _buildSettingRow(
                    icon: Icons.language,
                    title: 'Idioma do Aplicativo',
                    subtitle: '11 idiomas mundiais disponíveis',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getLanguageLabel(settings.locale?.languageCode),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.forestGreen,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 18, color: AppColors.softGray),
                      ],
                    ),
                    onTap: () => LanguageSelectionSheet.show(context),
                  ),
                  const Divider(color: AppColors.surfaceContainerLow, height: 1),
                  _buildSettingRow(
                    icon: Icons.notifications_active,
                    title: 'Notificações de Validade',
                    subtitle: 'Lembretes diários no horário ideal',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '09:00',
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.subHeader),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: settings.notificationsEnabled,
                          activeThumbColor: AppColors.forestGreen,
                          onChanged: (val) async {
                            final granted = await settings.setNotificationsEnabled(val);
                            pantry.setNotificationsEnabled(granted);
                          },
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.surfaceContainerLow, height: 1),
                  _buildSettingRow(
                    icon: Icons.hourglass_top,
                    title: 'Antecedência do Aviso',
                    subtitle: 'Tempo de alerta antes do vencimento',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${pantry.warningThresholdDays} dias antes',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 18, color: AppColors.softGray),
                      ],
                    ),
                    onTap: () async {
                      final nextDays = pantry.warningThresholdDays == 3 ? 5 : (pantry.warningThresholdDays == 5 ? 7 : 3);
                      await pantry.updateWarningThreshold(nextDays);
                      await settings.setWarningThresholdDays(nextDays);
                    },
                  ),
                  const Divider(color: AppColors.surfaceContainerLow, height: 1),
                  _buildSettingRow(
                    icon: Icons.menu_book,
                    title: 'Dicas e Receitas Conscientes',
                    subtitle: 'Sugestões de pratos para evitar sobras',
                    trailing: Switch(
                      value: true,
                      activeThumbColor: AppColors.forestGreen,
                      onChanged: (val) {},
                    ),
                  ),
                  const Divider(color: AppColors.surfaceContainerLow, height: 1),
                  _buildSettingRow(
                    icon: Icons.scale,
                    title: 'Unidade Padrão',
                    subtitle: 'Métricas de pesagem e volume',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'g / kg / un',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 18, color: AppColors.softGray),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Seção 2: Assinatura & Conta
            _buildSectionLabel('ASSINATURA & CONTA'),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                children: [
                  _buildSettingRow(
                    icon: Icons.card_giftcard,
                    title: 'Convidar Amigos & Ganhar Premium',
                    subtitle: 'Ganhe 1 semana grátis por cada amigo indicado',
                    trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.softGray),
                    onTap: () => _openReferral(context),
                  ),
                  const Divider(color: AppColors.surfaceContainerLow, height: 1),
                  _buildSettingRow(
                    icon: Icons.credit_card,
                    title: 'Gerenciar Assinatura',
                    subtitle: subscription.isSubscribed
                        ? 'Plano Ativo (R\$ 9,90/mês)'
                        : 'Teste Grátis (${subscription.daysRemainingInTrial} dias restantes)',
                    trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.softGray),
                    onTap: () => _openSubscription(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Seção 3: Dados & Privacidade
            _buildSectionLabel('DADOS & PRIVACIDADE'),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                children: [
                  _buildSettingRow(
                    icon: Icons.storage_rounded,
                    title: 'Central de Gerenciamento de Dados',
                    subtitle: 'Armazenamento local SQLite, nuvem e APIs externas',
                    trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.forestGreen),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DataManagementScreen()),
                      );
                    },
                  ),
                  const Divider(color: AppColors.surfaceContainerLow, height: 1),
                  _buildSettingRow(
                    icon: Icons.download_rounded,
                    title: 'Exportar Dados (JSON)',
                    subtitle: 'Cópia de segurança de toda sua despensa',
                    trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.softGray),
                    onTap: () => _exportData(context),
                  ),
                  const Divider(color: AppColors.surfaceContainerLow, height: 1),
                  _buildSettingRow(
                    icon: Icons.upload_rounded,
                    title: 'Importar Dados (JSON)',
                    subtitle: 'Restaurar alimentos a partir de backup',
                    trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.softGray),
                    onTap: () => _importData(context),
                  ),
                  const Divider(color: AppColors.surfaceContainerLow, height: 1),
                  _buildSettingRow(
                    icon: Icons.delete_outline,
                    title: 'Limpar Todos os Alimentos',
                    subtitle: 'Exclui todos os registros cadastrados',
                    trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.statusCriticalText),
                    onTap: () => _clearAllPantry(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Seção: Conta & Acesso
            _buildSectionLabel('CONTA & ACESSO'),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                children: [
                  _buildSettingRow(
                    icon: Icons.person_outline,
                    title: 'Editar Perfil',
                    subtitle: 'Altere seu nome completo e e-mail',
                    trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.softGray),
                    onTap: () => EditProfileSheet.show(context),
                  ),
                  const Divider(color: AppColors.surfaceContainerLow, height: 1),
                  _buildSettingRow(
                    icon: Icons.switch_account_outlined,
                    title: 'Trocar de Conta / Entrar',
                    subtitle: 'Acesse com outro e-mail ou crie uma nova conta',
                    trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.softGray),
                    onTap: () => _openLogin(context),
                  ),
                  const Divider(color: AppColors.surfaceContainerLow, height: 1),
                  _buildSettingRow(
                    icon: Icons.logout,
                    title: 'Sair da Conta',
                    subtitle: 'Encerrar a sessão atual neste aparelho',
                    trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.statusCriticalText),
                    onTap: () => _handleLogout(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Seção 4: Sobre o Aplicativo
            _buildSectionLabel('SOBRE O APLICATIVO'),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                children: [
                  _buildSettingRow(
                    icon: Icons.eco_outlined,
                    title: 'Sobre o Valora',
                    subtitle: 'Versão 1.2.0 · Feito com cuidado para evitar desperdícios',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'v1.2.0',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.subHeader,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OnboardingScreen(
                            onComplete: () => Navigator.of(context).pop(),
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(color: AppColors.surfaceContainerLow, height: 1),
                  _buildSettingRow(
                    icon: Icons.shield_outlined,
                    title: 'Política de Privacidade',
                    subtitle: 'Conformidade LGPD, modelo offline e segurança',
                    trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.softGray),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Version Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'Valora App v1.2.0',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.subHeader,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Menos desperdício. Mais valor.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.softGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppColors.subHeader,
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColors.forestGreen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.subHeader),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
