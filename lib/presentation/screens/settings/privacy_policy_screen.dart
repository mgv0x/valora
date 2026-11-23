import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../data/local/food_repository.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _exportData(BuildContext context) async {
    final repo = context.read<FoodRepository>();
    try {
      final data = await repo.exportData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.softWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Portabilidade LGPD (JSON)',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.forestGreen,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 260,
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonString,
                  style: GoogleFonts.firaCode(fontSize: 10, color: AppColors.charcoal),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: jsonString));
                  Navigator.of(ctx).pop();
                  UiFeedback.showSuccess(context, 'Dados copiados para a área de transferência!');
                },
                child: Text(
                  'Copiar JSON',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: AppColors.forestGreen,
                  ),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.forestGreen),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        UiFeedback.showError(context, 'Falha ao exportar dados: $e');
      }
    }
  }

  void _copyContactEmail(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: 'marcussgollub@gmail.com'));
    UiFeedback.showSuccess(context, 'E-mail do DPO copiado: marcussgollub@gmail.com');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.subHeader),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Política de Privacidade',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.forestGreen,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 20, color: AppColors.subHeader),
            tooltip: 'Copiar e-mail do DPO',
            onPressed: () => _copyContactEmail(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Hero Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceContainerLow : AppColors.softWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A1E3F20),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.forestGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.forestGreen),
                            const SizedBox(width: 5),
                            Text(
                              'LGPD & GDPR Compliant',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.forestGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'v1.0 Oficial',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.softGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Transparência e Soberania Total sobre seus Dados',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.forestGreen,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'O Valora foi desenvolvido com o compromisso ético de privacidade por padrão. Seus dados de despensa e hábitos nunca são vendidos nem utilizados para publicidade direcionada.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.subHeader,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Última atualização: 22 de novembro de 2026',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppColors.softGray,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pilares de Privacidade (4 Mini Cards)
            Row(
              children: [
                Expanded(
                  child: _buildHighlightCard(
                    icon: Icons.storage_rounded,
                    title: 'Offline-First',
                    subtitle: 'Dados salvos no seu aparelho em SQLite local.',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHighlightCard(
                    icon: Icons.block_flipped,
                    title: 'Zero Ads',
                    subtitle: 'Sem anúncios, rastreadores ou data brokers.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildHighlightCard(
                    icon: Icons.lock_outline,
                    title: 'Segurança',
                    subtitle: 'Isolamento de sandbox e tráfego TLS 1.3.',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHighlightCard(
                    icon: Icons.file_download_outlined,
                    title: 'Portabilidade',
                    subtitle: 'Exporte tudo em formato aberto JSON a qualquer momento.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Seções Detalhadas da Política
            _buildSectionCard(
              title: '1. Princípios Fundamentais',
              content:
                  'O Valora adota os princípios de Privacidade por Design (Privacy by Design) e Privacidade por Padrão (Privacy by Default). Acreditamos que a gestão eficiente de alimentos e o combate ao desperdício não requerem a invasão da privacidade pessoal. O usuário é o único detentor soberano de suas informações.',
            ),
            const SizedBox(height: 12),

            _buildSectionCard(
              title: '2. Dados Tratados: Modo Local vs. Nuvem',
              content:
                  '• Modo Local (Padrão): Nomes dos alimentos, categorias, quantidades, unidades, datas de validade, preços informados, local de armazenamento e notas ficam estritamente no banco SQLite do seu dispositivo. Nós não temos acesso a esses dados.\n\n'
                  '• Sincronização em Nuvem (Opcional): Caso crie uma conta no Firebase Auth, tratamos seu e-mail, identificador de usuário (UID) e cópia criptografada da sua despensa para fins exclusivos de backup e restauração.\n\n'
                  '• Open Food Facts: As buscas de alimentos por texto ou código de barras consultam a API pública de forma anônima, sem envio de dados pessoais.',
            ),
            const SizedBox(height: 12),

            _buildSectionCard(
              title: '3. Bases Legais (LGPD Art. 7º)',
              content:
                  'O tratamento de dados no Valora fundamenta-se estritamente nas seguintes hipóteses legais:\n\n'
                  '1. Execução de Contrato (Art. 7º, V): para prestação dos serviços de cadastro, cálculo de validade e alertas solicitados pelo usuário.\n'
                  '2. Legítimo Interesse (Art. 7º, IX): para melhoria técnica de estabilidade e prevenção de falhas no banco local.\n'
                  '3. Consentimento (Art. 7º, I): para o envio de notificações locais de vencimento.\n'
                  '4. Cumprimento de Obrigação Legal (Art. 7º, II): garantia do direito à portabilidade e acesso aos dados.',
            ),
            const SizedBox(height: 12),

            _buildSectionCard(
              title: '4. Permissões Solicitadas',
              content:
                  '• Notificações Locais: Utilizadas exclusivamente para avisar quando itens estiverem próximos do vencimento. Os agendamentos ocorrem no próprio relógio do sistema, sem servidores externos de push marketing.\n\n'
                  '• Armazenamento / Arquivos: Acionada estritamente quando você solicita salvar ou abrir arquivos de backup (.json).',
            ),
            const SizedBox(height: 12),

            _buildSectionCard(
              title: '5. Compartilhamento Técnico',
              content:
                  'O Valora NUNCA vende ou compartilha dados para fins publicitários ou comerciais. Os únicos parceiros técnicos são:\n\n'
                  '• Google Firebase: Infraestrutura de autenticação e banco em nuvem cifrado para usuários cadastrados.\n'
                  '• Open Food Facts: Base comunitária aberta consultada de forma anônima para enriquecimento de nomes de alimentos.',
            ),
            const SizedBox(height: 12),

            _buildSectionCard(
              title: '6. Segurança e Proteção',
              content:
                  '• Armazenamento isolado no sandbox nativo do Android e iOS.\n'
                  '• Criptografia HTTPS/TLS 1.3 em qualquer comunicação externa.\n'
                  '• Defesa ativa contra injeção SQL (consultas parametrizadas).\n'
                  '• Ferramentas de diagnóstico e manutenção local de integridade.',
            ),
            const SizedBox(height: 12),

            _buildSectionCard(
              title: '7. Seus Direitos (LGPD Artigo 18)',
              content:
                  'Você pode a qualquer momento:\n'
                  '1. Acessar todos os seus dados cadastrados.\n'
                  '2. Corrigir ou atualizar qualquer informação.\n'
                  '3. Exportar todo o inventário em formato JSON (Portabilidade).\n'
                  '4. Excluir todos os alimentos locais com 1 clique.\n'
                  '5. Solicitar a exclusão definitiva da conta em nuvem.',
            ),
            const SizedBox(height: 12),

            _buildSectionCard(
              title: '8. Menores de Idade',
              content:
                  'O Valora não é direcionado a crianças menores de 13 anos e não realiza coleta deliberada de dados de menores. Caso identificado qualquer registro involuntário, ele será excluído prontamente.',
            ),
            const SizedBox(height: 20),

            // Card de Ação Rápida: Portabilidade dos Dados (LGPD)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.forestGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.forestGreen.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.download_rounded, color: AppColors.forestGreen, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Exercer Direito de Portabilidade',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Baixe uma cópia instantânea e legível por máquina de todos os seus alimentos, categorias e histórico gravados neste aparelho.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.subHeader, height: 1.45),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.forestGreen,
                        side: const BorderSide(color: AppColors.forestGreen),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () => _exportData(context),
                      icon: const Icon(Icons.code_rounded, size: 18),
                      label: Text(
                        'Visualizar e Exportar JSON',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card de Contato DPO
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.forestGreen, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Encarregado de Proteção de Dados (DPO)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Para dúvidas, requisições de titulares ou informações adicionais:',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.subHeader),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _copyContactEmail(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.email_outlined, size: 16, color: AppColors.forestGreen),
                          const SizedBox(width: 8),
                          Text(
                            'marcussgollub@gmail.com',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.forestGreen,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.copy, size: 14, color: AppColors.softGray),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Footer
            Center(
              child: Text(
                'Valora • Menos desperdício. Mais valor.\nPrivacidade e soberania como valor inegociável.',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.softGray, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.forestGreen, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.subHeader,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.forestGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              height: 1.6,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}
