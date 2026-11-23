import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../state/subscription_provider.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final _redeemController = TextEditingController();

  @override
  void dispose() {
    _redeemController.dispose();
    super.dispose();
  }

  void _onRedeemCode(BuildContext context, SubscriptionProvider subscription) {
    final input = _redeemController.text;
    final result = subscription.redeemInviteCode(input);
    switch (result) {
      case RedemptionResult.success:
        _redeemController.clear();
        UiFeedback.showSuccess(context, 'Código ativado! Você ganhou +7 dias Premium! 🎉');
        break;
      case RedemptionResult.empty:
        UiFeedback.showError(context, 'Digite o código de convite recebido.');
        break;
      case RedemptionResult.invalidFormat:
        UiFeedback.showError(context, 'Formato inválido. Use o padrão VAL-XXXX.');
        break;
      case RedemptionResult.selfCode:
        UiFeedback.showError(context, 'Você não pode resgatar seu próprio código.');
        break;
      case RedemptionResult.alreadyUsed:
        UiFeedback.showError(context, 'Este código já foi resgatado anteriormente.');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<SubscriptionProvider>();
    final code = subscription.userReferralCode;
    final inviteLink = 'valora.app/c/$code';
    final count = subscription.invitedCount;
    final totalDaysWon = subscription.referralBonusDays;

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
                  'Indique e Ganhe',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestGreen,
                  ),
                ),
                const SizedBox(width: 48), // Balance space
              ],
            ),
            const SizedBox(height: 12),

            // Hero Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), offset: Offset(0, 2), blurRadius: 8),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.softWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Color(0x08000000), blurRadius: 4),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars, size: 16, color: AppColors.forestGreen),
                        const SizedBox(width: 6),
                        Text(
                          '1 amigo = +7 dias de Premium Grátis',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.forestGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.softWhite,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(color: Color(0x0A000000), offset: Offset(0, 2), blurRadius: 6),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD0EAC9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.redeem, size: 30, color: AppColors.forestGreen),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Compartilhe hábitos conscientes, ganhe semanas de Premium',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forestGreen,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Para cada pessoa que entrar no Valora pelo seu convite, você ganha 7 dias de assinatura Premium totalmente grátis. E quem você convidar também começa com 1 semana extra de teste cortesia.',
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

            // Card 2: Suas Conquistas
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
                      Row(
                        children: [
                          const Icon(Icons.workspace_premium, size: 20, color: AppColors.forestGreen),
                          const SizedBox(width: 8),
                          Text(
                            'Suas Conquistas',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.charcoal,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count amigos ativos',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total acumulado', style: GoogleFonts.inter(fontSize: 11, color: AppColors.subHeader)),
                              const SizedBox(height: 2),
                              Text(
                                '+$totalDaysWon dias',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.forestGreen,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text('Ativo e acumulativo', style: GoogleFonts.inter(fontSize: 11, color: AppColors.sageGreen)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Próximo marco', style: GoogleFonts.inter(fontSize: 11, color: AppColors.subHeader)),
                              const SizedBox(height: 2),
                              Text(
                                '1 Mês',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.forestGreen,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (count % 4) == 0 && count > 0 ? 1.0 : (count % 4) / 4.0,
                                  minHeight: 5,
                                  backgroundColor: AppColors.surfaceContainer,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.forestGreen),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb, size: 18, color: AppColors.forestGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (4 - (count % 4)) == 1
                                ? 'Falta apenas 1 convite para completar seu próximo mês sem custo!'
                                : 'Faltam ${4 - (count % 4)} convites para completar seu próximo mês sem custo!',
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.charcoal),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 3: Código e Link de Convite
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
                  Text(
                    'Seu código exclusivo',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.subHeader),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          code,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: AppColors.forestGreen,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await Clipboard.setData(ClipboardData(text: code));
                              if (context.mounted) {
                                UiFeedback.showSuccess(context, 'Código copiado com sucesso!');
                              }
                            } catch (_) {
                              if (context.mounted) {
                                UiFeedback.showInfo(context, 'Código: $code');
                              }
                            }
                          },
                          icon: const Icon(Icons.content_copy, size: 15),
                          label: const Text('Copiar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.softWhite,
                            foregroundColor: AppColors.forestGreen,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'Link direto de convite',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.subHeader),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            inviteLink,
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.charcoal),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: 'https://$inviteLink'));
                            UiFeedback.showSuccess(context, 'Link copiado com sucesso!');
                          },
                          icon: const Icon(Icons.link, size: 15),
                          label: const Text('Copiar link'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.softWhite,
                            foregroundColor: AppColors.forestGreen,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: subscription.shareMessage));
                        UiFeedback.showSuccess(
                          context,
                          'Mensagem de convite copiada para compartilhar!',
                        );
                      },
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Compartilhar Convite'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.forestGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 4: Resgatar Código de Amigo
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
                    children: [
                      const Icon(Icons.card_giftcard, size: 20, color: AppColors.forestGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Tem o código de um amigo?',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Insira o código recebido para ganhar +7 dias de Premium grátis.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.subHeader),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _redeemController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'Ex: VAL-ABCD',
                            hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.softGray),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.forestGreen, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => _onRedeemCode(context, subscription),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.forestGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Resgatar',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 5: Como Funciona
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
                  Text(
                    'Como funciona',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildStepRow(
                    stepNum: '1',
                    title: 'Compartilhe sua chave',
                    desc: 'Envie seu link ou código exclusivo para pessoas próximas que buscam evitar desperdício.',
                  ),
                  const SizedBox(height: 12),
                  _buildStepRow(
                    stepNum: '2',
                    title: 'Instalação e cadastro',
                    desc: 'Seu amigo instala o Valora e ativa seu código promocional no primeiro acesso.',
                  ),
                  const SizedBox(height: 12),
                  _buildStepRow(
                    stepNum: '3',
                    title: 'Semana liberada para os dois',
                    desc: 'Instantaneamente, cada um recebe 7 dias com todos os recursos inteligentes e sem limites.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card 6: Amigos Convidados & Códigos Ativados
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
                        'Amigos convidados',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestGreen,
                        ),
                      ),
                      Text(
                        count == 1 ? '1 amigo' : '$count amigos',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.subHeader),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (count == 0 && subscription.redeemedCodes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.people_outline, size: 36, color: AppColors.subHeader.withValues(alpha: 0.5)),
                            const SizedBox(height: 8),
                            Text(
                              'Nenhum convite registrado ainda.\nCompartilhe seu código acima!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.subHeader),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    ...List.generate(count, (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildFriendRow(
                            '#${index + 1}',
                            'Amigo Convidado #${index + 1}',
                            'Bônus de indicação ativo',
                          ),
                        )),
                    if (subscription.redeemedCodes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Códigos resgatados por você:',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.forestGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...subscription.redeemedCodes.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildFriendRow('🎁', 'Código $c', 'Bônus resgatado com sucesso'),
                          )),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow({required String stepNum, required String title, required String desc}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Color(0xFFD0EAC9),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            stepNum,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.forestGreen,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.4,
                  color: AppColors.subHeader,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFriendRow(String initials, String name, String sub) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.forestGreen,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  Text(
                    sub,
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.softGray),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFD0EAC9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+7 dias',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.forestGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
