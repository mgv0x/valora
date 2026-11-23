import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../core/widgets/valora_app_bar.dart';
import '../../../data/models/food_activity.dart';
import '../../../data/models/food_unit.dart';
import '../../../data/services/eco_metrics_service.dart';
import '../../../state/impact_provider.dart';
import '../../../state/subscription_provider.dart';
import '../subscription/subscription_screen.dart';
import 'widgets/activity_details_sheet.dart';

class ImpactScreen extends StatefulWidget {
  final VoidCallback? onOpenSettings;

  const ImpactScreen({
    super.key,
    this.onOpenSettings,
  });

  @override
  State<ImpactScreen> createState() => _ImpactScreenState();
}

class _ImpactScreenState extends State<ImpactScreen> {
  int _selectedPeriod = 0; // 0: Este mês, 1: Últimos 3 meses, 2: Todo o ano

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ImpactProvider>();
      p.setPeriodFilter(ActivityPeriodFilter.last30Days);
      p.loadActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ImpactProvider>();
    final consumedCount = provider.filteredConsumedCount;
    final discardedCount = provider.filteredDiscardedCount;
    final totalActivities = consumedCount + discardedCount;
    final activities = provider.filteredActivities;

    final rate = provider.consumptionRate != null
        ? provider.consumptionRate!.round()
        : (totalActivities > 0 ? 100 : 100);

    final valueConsumed = provider.estimatedValueConsumed;
    final formattedSavings = valueConsumed > 0
        ? 'R\$ ${valueConsumed.toStringAsFixed(2).replaceAll('.', ',')}'
        : 'R\$ 0,00';

    final kg = provider.consumedVolumeByUnit[FoodUnit.kilogram] ?? 0;
    final grams = provider.consumedVolumeByUnit[FoodUnit.gram] ?? 0;
    final liters = provider.consumedVolumeByUnit[FoodUnit.liter] ?? 0;
    final ml = provider.consumedVolumeByUnit[FoodUnit.milliliter] ?? 0;
    final totalKg = kg + (grams / 1000.0);
    final totalLiters = liters + (ml / 1000.0);

    final String foodVolumeText;
    if (totalKg > 0 && totalLiters > 0) {
      foodVolumeText = '${totalKg.toStringAsFixed(1).replaceAll('.', ',')} kg • ${totalLiters.toStringAsFixed(1).replaceAll('.', ',')} L';
    } else if (totalKg > 0) {
      foodVolumeText = '${totalKg.toStringAsFixed(1).replaceAll('.', ',')} kg';
    } else if (totalLiters > 0) {
      foodVolumeText = '${totalLiters.toStringAsFixed(1).replaceAll('.', ',')} L';
    } else if (consumedCount > 0) {
      foodVolumeText = '$consumedCount ${consumedCount == 1 ? "item" : "itens"}';
    } else {
      foodVolumeText = '0 kg';
    }

    final insightText = consumedCount > 0
        ? 'Você aproveitou $consumedCount ${consumedCount == 1 ? "alimento" : "alimentos"} que poderiam ter sido perdidos no período selecionado.'
        : 'Comece a registrar o consumo dos seus alimentos para acompanhar sua evolução consciente.';

    // Calculate 4 weekly consistency buckets dynamically
    final now = DateTime.now();
    final allActs = provider.activities;
    final weekRates = <double>[];
    for (int w = 3; w >= 0; w--) {
      final start = now.subtract(Duration(days: (w + 1) * 7));
      final end = now.subtract(Duration(days: w * 7));
      final acts = allActs.where((a) => a.timestamp.isAfter(start) && a.timestamp.isBefore(end)).toList();
      final cCount = acts.where((a) => a.type == ActivityType.consumed).length;
      final dCount = acts.where((a) => a.type == ActivityType.discarded).length;
      final total = cCount + dCount;
      if (total == 0) {
        weekRates.add(allActs.isEmpty ? 0.0 : 100.0);
      } else {
        weekRates.add((cCount / total) * 100.0);
      }
    }
    final previousWeekRate = weekRates[2];
    final currentWeekRate = weekRates[3];
    final diff = (currentWeekRate - previousWeekRate).round();
    final trendText = diff >= 0 ? '+$diff%' : '$diff%';
    final isPositiveTrend = diff >= 0;

    final unlockedAchievementsCount =
        (provider.activities.length >= 10 ? 1 : 0) + (rate >= 90 && totalActivities > 0 ? 1 : 0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: ValoraAppBar(
        title: 'Meu impacto',
        onProfilePressed: widget.onOpenSettings,
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadActivities(),
        color: AppColors.forestGreen,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
          children: [
            // 1. Subtle Header Introduction
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD0EAC9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco, size: 18, color: AppColors.forestGreen),
                ),
                const SizedBox(width: 8),
                Text(
                  'Meu Impacto',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: AppColors.forestGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Pequenas escolhas que fazem bem para sua casa e para o planeta.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.subHeader,
              ),
            ),
            const SizedBox(height: 16),

            // 2. Interactive Period Pills Filter
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  _buildPeriodPill(label: 'Este mês', index: 0),
                  _buildPeriodPill(label: 'Últimos 3 meses', index: 1),
                  _buildPeriodPill(label: 'Todo o ano', index: 2),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Hero Highlight Card (94% radial spark)
            Container(
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), offset: Offset(0, 2), blurRadius: 8),
                ],
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
                          Text(
                            'TAXA DE CONSUMO CONSCIENTE',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: AppColors.softGray,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$rate%',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.8,
                                  color: AppColors.forestGreen,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isPositiveTrend ? const Color(0xFFD0EAC9) : const Color(0xFFFDE8E8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                                      size: 14,
                                      color: isPositiveTrend ? AppColors.forestGreen : const Color(0xFFDC2626),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      trendText,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isPositiveTrend ? AppColors.forestGreen : const Color(0xFFDC2626),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Alimentos aproveitados com sucesso',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.charcoal,
                            ),
                          ),
                        ],
                      ),

                      // Compact Circular Visual Spark (Radial gauge)
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: rate / 100.0,
                              strokeWidth: 5,
                              backgroundColor: AppColors.surfaceContainer,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.forestGreen),
                            ),
                            const Icon(
                              Icons.task_alt,
                              size: 20,
                              color: AppColors.forestGreen,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Gentle Insight Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.favorite, size: 18, color: AppColors.sageGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            insightText,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              height: 1.4,
                              color: AppColors.subHeader,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Two Column Metric Tiles (Economia & Nutrição)
            Row(
              children: [
                // Financial Savings
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.softWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD0EAC9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.savings, size: 18, color: AppColors.forestGreen),
                            ),
                            Text(
                              'Economia',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.sageGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          formattedSavings,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: AppColors.forestGreen,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Economia estimada',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.subHeader),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Evitando compras duplicadas e perdas.',
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.softGray),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Food Weight Saved
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.softWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD0EAC9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.restaurant, size: 18, color: AppColors.forestGreen),
                            ),
                            Text(
                              'Nutrição',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.sageGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          foodVolumeText,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: AppColors.forestGreen,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Comida aproveitada',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.subHeader),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          consumedCount > 0
                              ? 'Equivalente a ${consumedCount * 2} porções cuidadas.'
                              : 'Alimentos consumidos dentro do prazo.',
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.softGray),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 5. Weekly Progress Bar Chart Card (4 Semanas)
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
                          Text(
                            'Consistência Semanal',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.forestGreen,
                            ),
                          ),
                          Text(
                            'Taxa de alimentos consumidos no prazo',
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.softGray),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '4 Semanas',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 4 Bars Graphic
                  SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildChartBar(
                          label: 'Sem 1',
                          pct: '${weekRates[0].round()}%',
                          heightFactor: (weekRates[0] / 100.0).clamp(0.2, 1.0),
                          color: AppColors.surfaceContainerHigh,
                        ),
                        _buildChartBar(
                          label: 'Sem 2',
                          pct: '${weekRates[1].round()}%',
                          heightFactor: (weekRates[1] / 100.0).clamp(0.2, 1.0),
                          color: AppColors.surfaceContainerHigh,
                        ),
                        _buildChartBar(
                          label: 'Sem 3',
                          pct: '${weekRates[2].round()}%',
                          heightFactor: (weekRates[2] / 100.0).clamp(0.2, 1.0),
                          color: const Color(0xFFB5CDAE),
                        ),
                        _buildChartBar(
                          label: 'Sem 4',
                          pct: '${weekRates[3].round()}%',
                          heightFactor: (weekRates[3] / 100.0).clamp(0.2, 1.0),
                          color: AppColors.forestGreen,
                          isCurrent: true,
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.surfaceContainer, height: 16),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Função 9 [PREMIUM]: Calculadora de Impacto Ecológico (Água e Carbono)
            Builder(
              builder: (ctx) {
                final subscription = Provider.of<SubscriptionProvider?>(ctx);
                final isPro = subscription?.hasActiveAccess ?? false;
                final ecoSummary = EcoMetricsService.calculateSavings(provider.activities);

                return Container(
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
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.water_drop_rounded, size: 18, color: Color(0xFF0284C7)),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pegada Ecológica Poupada',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.forestGreen,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'PREMIUM',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Impacto ambiental positivo ao evitar o descarte de alimentos.',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.softGray),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F9FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFBAE6FD)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ecoSummary.formattedWater,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0369A1),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Água virtual poupada',
                                    style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF0284C7)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFBBF7D0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ecoSummary.formattedCo2,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF15803D),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'CO₂e evitado na atmosfera',
                                    style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF16A34A)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!isPro) ...[
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: Color(0xFFD97706)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Ative o Valora PRO para desbloquear relatórios detalhados de CO₂ e água.',
                                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.charcoal),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.softGray),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            // Função 7 [PREMIUM]: Relatório Executivo Financeiro e Projeção Anual
            Builder(
              builder: (ctx) {
                final subscription = Provider.of<SubscriptionProvider?>(ctx);
                final isPro = subscription?.hasActiveAccess ?? false;
                final yearlyProjected = valueConsumed * 12;

                return Container(
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
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.analytics_rounded, size: 18, color: Color(0xFFD97706)),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Projeção Financeira Anual',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.forestGreen,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Projeção de economia anual baseada no seu padrão consciente:',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.subHeader),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'R\$ ${yearlyProjected.toStringAsFixed(2).replaceAll('.', ',')} / ano',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.forestGreen,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (!isPro) {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                              );
                              return;
                            }
                            final report = '''
📊 RELATÓRIO EXECUTIVO DE ECONOMIA • VALORA
--------------------------------------------
• Alimentos Consumidos: $consumedCount itens
• Taxa de Aproveitamento: $rate%
• Economia Registrada no Período: $formattedSavings
• Projeção de Economia Anual: R\$ ${yearlyProjected.toStringAsFixed(2).replaceAll('.', ',')}
• Status da Despensa: Zero Desperdício Ativo
--------------------------------------------
Gerado pelo app Valora • Gestão Consciente de Alimentos
''';
                            Clipboard.setData(ClipboardData(text: report));
                            UiFeedback.showSuccess(context, 'Relatório executivo copiado para a área de transferência!');
                          },
                          icon: const Icon(Icons.copy, size: 16, color: AppColors.forestGreen),
                          label: const Text('Copiar Relatório Executivo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            // 6. Mindful Achievements (Badges)
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
                        'Conquistas Conscientes',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.forestGreen,
                        ),
                      ),
                      Text(
                        '$unlockedAchievementsCount ativas',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.sageGreen, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildAchievementTile(
                    icon: Icons.shield,
                    title: 'Guardião da Despensa',
                    subtitle: provider.activities.length >= 10
                        ? 'Conquista ativa: Mais de 10 ações conscientes registradas'
                        : 'Em progresso: ${provider.activities.length}/10 ações conscientes registradas',
                    iconBg: provider.activities.length >= 10 ? const Color(0xFFD0EAC9) : AppColors.surfaceContainer,
                    iconColor: provider.activities.length >= 10 ? AppColors.forestGreen : AppColors.softGray,
                  ),
                  const SizedBox(height: 8),
                  _buildAchievementTile(
                    icon: Icons.eco,
                    title: 'Aproveitamento Excepcional',
                    subtitle: (rate >= 90 && totalActivities > 0)
                        ? 'Conquista ativa: Mais de 90% dos alimentos aproveitados'
                        : 'Meta: 90% de aproveitamento (atual: $rate%)',
                    iconBg: (rate >= 90 && totalActivities > 0) ? const Color(0xFFC3ECD2) : AppColors.surfaceContainer,
                    iconColor: (rate >= 90 && totalActivities > 0) ? AppColors.forestGreen : AppColors.softGray,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 7. Heartfelt Reflection Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.forestGreen,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x1A294D3A), offset: Offset(0, 4), blurRadius: 12),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.spa, size: 20, color: Color(0xFFC3ECD2)),
                      const SizedBox(width: 8),
                      Text(
                        'REFLEXÃO DO MÊS',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: const Color(0xFFC3ECD2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Cada refeição aproveitada economiza água, energia e o seu dinheiro. Parabéns pela dedicação e pelo cuidado diário com o seu lar!',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.people_alt, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Valora Comunidade',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFC3ECD2),
                            ),
                          ),
                          Text(
                            'Juntos por um consumo gentil',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 8. Recent Activities History
            if (activities.isNotEmpty) ...[
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
                          'Histórico de Atividades',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.forestGreen,
                          ),
                        ),
                        Text(
                          '${activities.length} ${activities.length == 1 ? "registro" : "registros"}',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.subHeader),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...activities.take(5).map((act) => _buildActivityRow(context, act)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(BuildContext context, FoodActivity act) {
    final isConsumed = act.type == ActivityType.consumed;
    final color = isConsumed ? AppColors.forestGreen : AppColors.statusExpired;
    final icon = isConsumed ? Icons.check_circle_outline : Icons.delete_outline;
    final dateStr = DateFormat('dd/MM HH:mm').format(act.timestamp);
    final qtyStr = '${FoodUnit.formatQuantity(act.quantity)} ${act.unit.shortSymbol}';

    return InkWell(
      onTap: () => ActivityDetailsSheet.show(context, activity: act),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    act.foodName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  Text(
                    '$qtyStr • $dateStr',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.subHeader),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.softGray),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodPill({required String label, required int index}) {
    final isSelected = _selectedPeriod == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _selectedPeriod = index);
          final provider = context.read<ImpactProvider>();
          if (index == 0) {
            provider.setPeriodFilter(ActivityPeriodFilter.last30Days);
          } else if (index == 1) {
            provider.setPeriodFilter(ActivityPeriodFilter.last90Days);
          } else {
            provider.setPeriodFilter(ActivityPeriodFilter.allTime);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.softWhite : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? const [BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 4)]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppColors.forestGreen : AppColors.subHeader,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartBar({
    required String label,
    required String pct,
    required double heightFactor,
    required Color color,
    bool isCurrent = false,
  }) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            pct,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
              color: isCurrent ? AppColors.forestGreen : AppColors.softGray,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: heightFactor,
                child: Container(
                  width: 32,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
              color: isCurrent ? AppColors.forestGreen : AppColors.subHeader,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: iconColor),
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
                    color: AppColors.forestGreen,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.subHeader,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
