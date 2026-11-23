import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/valora_logo.dart';
import '../../../state/settings_provider.dart';
import '../../../state/subscription_provider.dart';
import '../../navigation/main_navigation_screen.dart';
import '../auth/login_screen.dart';
import '../referral/referral_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  final bool isPaywallModal;
  final bool isFirstLaunch;

  const SubscriptionScreen({
    super.key,
    this.isPaywallModal = false,
    this.isFirstLaunch = false,
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isProcessing = false;

  static void _silenceImageError(Object exception, StackTrace? stackTrace) {}

  Future<void> _handleStartTrial(SubscriptionProvider subscription) async {
    setState(() => _isProcessing = true);
    await subscription.acceptTrial();
    setState(() => _isProcessing = false);

    if (mounted) {
      UiFeedback.showSuccess(
        context,
        'Teste grátis de 7 dias ativado! Bem-vindo ao Valora Premium.',
      );
      if (widget.isFirstLaunch) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else {
        Navigator.of(context).maybePop();
      }
    }
  }

  Future<void> _handleSubscribe(SubscriptionProvider subscription) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 600)); // Smooth checkout simulation
    await subscription.subscribe(durationDays: 30);
    setState(() => _isProcessing = false);

    if (mounted) {
      UiFeedback.showSuccess(
        context,
        'Assinatura de R\$ 9,90/mês ativada com sucesso! Bem-vindo ao Valora Premium.',
      );
      if (widget.isFirstLaunch) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      } else if (widget.isPaywallModal) {
        Navigator.of(context).maybePop();
      }
    }
  }

  Future<void> _handleCancelSubscription(SubscriptionProvider subscription) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Cancelar Assinatura?',
      content: 'Você perderá o acesso ilimitado após o término do período atual. Deseja cancelar?',
      confirmLabel: 'Cancelar Assinatura',
      cancelLabel: 'Manter Assinatura',
      isDestructive: true,
    );

    if (confirmed) {
      await subscription.cancelSubscription();
      if (mounted) {
        UiFeedback.showSuccess(context, 'Assinatura cancelada com sucesso.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<SubscriptionProvider>();
    final isSubscribed = subscription.isSubscribed;
    final trialDaysLeft = subscription.daysRemainingInTrial;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
          children: [
            // Top Navigation & Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0EAC9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars, size: 14, color: AppColors.forestGreen),
                      const SizedBox(width: 4),
                      Text(
                        '7 DIAS GRÁTIS DE TESTE',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!widget.isFirstLaunch && subscription.hasActiveAccess)
                  IconButton(
                    icon: const Icon(Icons.close, size: 22, color: AppColors.subHeader),
                    onPressed: () => Navigator.of(context).maybePop(),
                  )
                else
                  const SizedBox(width: 48, height: 48),
              ],
            ),
            const SizedBox(height: 12),

            // Brand & Hero Title
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const ValoraLogo(size: 28),
                      const SizedBox(width: 8),
                      Text(
                        'Valora',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestGreen,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF424927),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'PREMIUM',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: const Color(0xFFDFE7B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Transforme sua rotina com o Valora Premium',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: AppColors.forestGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Economize até R\$ 350 por mês evitando desperdícios e tenha controle inteligente total da sua despensa.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.45,
                      color: AppColors.subHeader,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Editorial Visual Delight
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.forestGreen,
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCq2dR1eUdwvkqJ69UXRFI7yT2tXUGfr54etoAm-fympqwFyCMvpi228qkmaBWfFnTfEH8qTS2EuXsjAipPWeBvhheFCepaJbqIbcgW3y-LdOk4s8iybxYV9xzFM0EaO9rrm9bH5rBKWh5x7B4-KehTvfZ0N3P6qtSJh7Z30KoOacs_qWZ44PWcuBNPywG_PjeH1sFJdBHc-gKEZtw_ZOYRE9NFWuoHoRxgAMthicK44M57Vx6YtyNsNg',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Color(0x99294D3A), BlendMode.multiply),
                  onError: _silenceImageError,
                ),
              ),
              padding: const EdgeInsets.all(14),
              alignment: Alignment.bottomLeft,
              child: Row(
                children: [
                  const Icon(Icons.verified, size: 18, color: Color(0xFFC3ECD2)),
                  const SizedBox(width: 6),
                  Text(
                    'Mais de 14.000 famílias vivendo com desperdício zero',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Exclusivos / Value Stack (5 Benefits)
            Container(
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RECURSOS EXCLUSIVOS',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: AppColors.softGray,
                        ),
                      ),
                      Text(
                        'Tudo incluso',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.sageGreen),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildBenefitRow(
                    icon: Icons.notifications_active,
                    title: 'Lembretes Inteligentes Antecipados',
                    desc: 'Notificações preditivas e personalizadas no horário exato para nunca perder um alimento.',
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitRow(
                    icon: Icons.restaurant_menu,
                    title: 'Sugestões de Refeições com Alimentos que Vencem',
                    desc: 'Receitas práticas e saborosas combinando o que já está na sua geladeira.',
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitRow(
                    icon: Icons.group,
                    title: 'Compartilhamento Familiar em Tempo Real',
                    desc: 'Até 4 pessoas cuidando da mesma despensa sincronizada e organizada.',
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitRow(
                    icon: Icons.insights,
                    title: 'Relatórios de Economia & Carbono',
                    desc: 'Métricas aprofundadas do dinheiro poupado e do impacto positivo mês a mês.',
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitRow(
                    icon: Icons.document_scanner,
                    title: 'Despensa Ilimitada & Leitura de Notas',
                    desc: 'Cadastro ágil por foto de cupom fiscal com categorização automática instantânea.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pricing Card & Transparent Timeline
            Container(
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ACESSO ILIMITADO', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.sageGreen)),
                          Text(
                            'Plano Mensal Flexível',
                            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.forestGreen),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD0EAC9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '7 dias grátis',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.forestGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Price box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Após o período de teste', style: GoogleFonts.inter(fontSize: 11, color: AppColors.subHeader)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  'R\$ 9,90',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.forestGreen),
                                ),
                                const SizedBox(width: 4),
                                Text('/ mês', style: GoogleFonts.inter(fontSize: 12, color: AppColors.subHeader)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Cancele quando quiser',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.sageGreen),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Timeline Rail
                  Text(
                    'COMO FUNCIONA SEU TESTE:',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.softGray),
                  ),
                  const SizedBox(height: 12),
                  _buildTimelineStep(
                    icon: Icons.check,
                    title: 'Hoje: Acesso imediato gratuito',
                    desc: 'Explore todas as funções premium sem pagar nada agora (R\$ 0,00).',
                    isFirst: true,
                  ),
                  _buildTimelineStep(
                    icon: Icons.notifications,
                    title: 'Em 5 dias: Lembrete amigável',
                    desc: 'Avisaremos você por notificação antes de qualquer cobrança.',
                  ),
                  _buildTimelineStep(
                    icon: Icons.credit_card,
                    title: 'Em 7 dias: Início da assinatura',
                    desc: 'Cobrança de R\$ 9,90/mês. Cancele com um toque quando desejar.',
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Indique e Ganhe Banner Shortcut
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReferralScreen()),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFD0EAC9).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.forestGreen.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(color: Color(0xFFD0EAC9), shape: BoxShape.circle),
                      child: const Icon(Icons.group_add, size: 20, color: AppColors.forestGreen),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Indique amigos e ganhe +7 dias grátis',
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.forestGreen),
                          ),
                          Text(
                            'A cada indicação, você e seu amigo ganham 1 semana extra.',
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.subHeader),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward, size: 16, color: AppColors.forestGreen),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // CTA Button
            if (isSubscribed) ...[
              SizedBox(
                height: 48,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _handleCancelSubscription(subscription),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.statusCriticalText),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Cancelar Assinatura',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.statusCriticalText),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () {
                          if (!subscription.hasAcceptedTrial || widget.isFirstLaunch) {
                            _handleStartTrial(subscription);
                          } else {
                            _handleSubscribe(subscription);
                          }
                        },
                  icon: const Icon(Icons.stars_rounded, size: 20, color: Colors.white),
                  label: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          (!subscription.hasAcceptedTrial || widget.isFirstLaunch)
                              ? 'Testar por 7 dias grátis'
                              : (trialDaysLeft > 0 ? 'Iniciar 7 Dias Grátis' : 'Assinar por R\$ 9,90/mês'),
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  (!subscription.hasAcceptedTrial || widget.isFirstLaunch)
                      ? '7 dias grátis de teste · Depois R\$ 9,90/mês · Cancele quando quiser'
                      : 'Transação segura Google Play • Cancele facilmente nas configurações',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.softGray),
                  textAlign: TextAlign.center,
                ),
              ),
              if (!context.watch<SettingsProvider>().isLoggedIn) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(
                            onSuccess: () {
                              if (widget.isFirstLaunch) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                                );
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Já possui uma conta?',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.subHeader),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Entrar',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.forestGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow({required IconData icon, required String title, required String desc}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: AppColors.subHeader),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required String desc,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isFirst ? AppColors.forestGreen : AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 13, color: isFirst ? Colors.white : AppColors.charcoal),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: AppColors.surfaceContainerHigh,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal),
              ),
              Text(
                desc,
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.subHeader),
              ),
              if (!isLast) const SizedBox(height: 14),
            ],
          ),
        ),
      ],
    );
  }
}
