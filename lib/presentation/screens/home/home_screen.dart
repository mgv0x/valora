import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/valora_app_bar.dart';
import '../../../data/models/food_item.dart';
import '../../../data/models/food_unit.dart';
import '../../../data/models/food_activity.dart';
import '../../../state/impact_provider.dart';
import '../../../state/pantry_provider.dart';
import '../../../state/settings_provider.dart';
import '../../../state/subscription_provider.dart';
import '../food_form/add_edit_food_screen.dart';
import '../pantry/widgets/food_details_sheet.dart';
import '../pantry/widgets/record_action_dialog.dart';
import '../subscription/subscription_screen.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int tabIndex) onNavigateToTab;
  final VoidCallback onOpenSettings;

  const HomeScreen({
    super.key,
    required this.onNavigateToTab,
    required this.onOpenSettings,
  });

  void _openAddFood(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddEditFoodScreen()),
    );
  }

  void _openSubscription(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );
  }

  void _openDetails(BuildContext context, FoodItem item) {
    FoodDetailsSheet.show(
      context,
      item: item,
      warningThresholdDays: context.read<PantryProvider>().warningThresholdDays,
      onEdit: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AddEditFoodScreen(initialItem: item)),
        );
      },
      onConsume: () async {
        final result = await RecordActionDialog.show(context, item: item, isDiscard: false);
        if (result != null && context.mounted) {
          final qty = result['quantity'] as double;
          final notes = result['notes'] as String?;
          await context.read<PantryProvider>().recordConsumption(
                item: item,
                consumedQuantity: qty,
                notes: notes,
              );
          if (context.mounted) {
            context.read<ImpactProvider>().loadActivities();
            _showToast(context, '${item.name} aproveitado com sucesso! 🌱');
          }
        }
      },
      onDiscard: () async {
        final result = await RecordActionDialog.show(context, item: item, isDiscard: true);
        if (result != null && context.mounted) {
          final qty = result['quantity'] as double;
          final notes = result['notes'] as String?;
          await context.read<PantryProvider>().recordDisposal(
                item: item,
                discardedQuantity: qty,
                notes: notes,
              );
          if (context.mounted) {
            context.read<ImpactProvider>().loadActivities();
            _showToast(context, 'Ação registrada.');
          }
        }
      },
      onDelete: () async {
        final confirmed = await ConfirmationDialog.show(
          context,
          title: 'Excluir alimento',
          content: 'Deseja excluir "${item.name}" da despensa?',
          confirmLabel: 'Excluir',
          cancelLabel: 'Cancelar',
          isDestructive: true,
        );
        if (confirmed && context.mounted) {
          await context.read<PantryProvider>().deleteFood(item.id);
          if (context.mounted) {
            _showToast(context, 'Alimento removido.');
          }
        }
      },
    );
  }

  void _consumeDirectly(BuildContext context, FoodItem item) async {
    await context.read<PantryProvider>().recordConsumption(
          item: item,
          consumedQuantity: item.remainingQuantity,
        );
    if (context.mounted) {
      context.read<ImpactProvider>().loadActivities();
      _showToast(context, '${item.name} aproveitado com sucesso! 🌱');
    }
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.eco, color: Color(0xFFC3ECD2), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2D312D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PantryProvider>();
    final subscription = context.watch<SubscriptionProvider>();
    final settings = context.watch<SettingsProvider>();
    final impact = context.watch<ImpactProvider>();
    final totalActive = provider.totalActiveCount;
    final priorityItems = provider.priorityItems;
    final rate = impact.consumptionRate;
    final rateDisplay = rate != null ? '${rate.toStringAsFixed(0)}%' : '100%';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: ValoraAppBar(
        title: 'Início',
        onProfilePressed: onOpenSettings,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            provider.loadItems(),
            impact.loadActivities(),
          ]);
        },
        color: AppColors.forestGreen,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            // 1. Saudação Calorosa
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Olá, ${settings.userFirstName}!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.spa, size: 20, color: AppColors.sageGreen),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Vamos cuidar da sua despensa hoje?',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.subHeader,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0EAC9).withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: AppColors.forestGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Subscription / Trial Status Banner (if trial mode active)
            if (subscription.isSubscriptionRequired && !subscription.isSubscribed)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openSubscription(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF2E9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.forestGreen.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: AppColors.forestGreen, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${subscription.daysRemainingInTrial} dias de teste grátis',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.forestGreen,
                                ),
                              ),
                              Text(
                                'Indique amigos e ganhe +7 dias para cada um',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.subHeader,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.forestGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '+7 DIAS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 2. Card Hero: Status da Despensa
            Container(
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    offset: Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.shelves,
                              size: 18,
                              color: AppColors.forestGreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Status da Despensa',
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
                          color: const Color(0xFFD0EAC9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ATUALIZADO',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Resumo Numérico (2 columns)
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
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    totalActive.toString(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.forestGreen,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    totalActive == 1 ? 'item' : 'itens',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppColors.subHeader,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'ativos no estoque',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.softGray,
                                ),
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
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    rateDisplay,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.forestGreen,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.trending_up,
                                    size: 16,
                                    color: AppColors.sageGreen,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'aproveitados no mês',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.softGray,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Mensagem Acolhedora
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.eco, size: 18, color: AppColors.sageGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Você já está dando mais valor aos alimentos da sua casa e reduzindo desperdícios.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.4,
                            color: AppColors.subHeader,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Atalho de Ação Rápida: Adicionar Alimento
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openAddFood(context),
                icon: const Icon(Icons.add_circle, size: 20, color: Colors.white),
                label: Text(
                  'Adicionar alimento',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. Seção: Atenção nos próximos dias
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      'Atenção nos próximos dias',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${priorityItems.length} ${priorityItems.length == 1 ? "item" : "itens"}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.subHeader,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Dica: Consuma estes itens primeiro para evitar perdas.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.softGray,
              ),
            ),
            const SizedBox(height: 12),

            // Lista de Itens Críticos
            if (priorityItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.sentiment_satisfied_alt, size: 32, color: AppColors.sageGreen),
                    const SizedBox(height: 8),
                    Text(
                      'Tudo tranquilo por aqui!',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Nenhum alimento em estado crítico no momento.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.softGray,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: priorityItems.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (ctx, idx) {
                  final item = priorityItems[idx];
                  final daysRemaining = item.getDaysRemaining();

                  String expiryText;
                  Color badgeBg;
                  Color badgeText;
                  if (daysRemaining != null && daysRemaining <= 0) {
                    expiryText = 'Vence hoje';
                    badgeBg = AppColors.statusCriticalBg;
                    badgeText = AppColors.statusCriticalText;
                  } else if (daysRemaining == 1) {
                    expiryText = 'Vence amanhã';
                    badgeBg = const Color(0xFFFDF4E5);
                    badgeText = const Color(0xFF8C5B14);
                  } else if (daysRemaining != null) {
                    expiryText = 'Vence em $daysRemaining dias';
                    badgeBg = const Color(0xFFFDF4E5);
                    badgeText = const Color(0xFF8C5B14);
                  } else {
                    expiryText = 'Atenção';
                    badgeBg = const Color(0xFFFDF4E5);
                    badgeText = const Color(0xFF8C5B14);
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.softWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 1),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Thumbnail
                        InkWell(
                          onTap: () => _openDetails(context, item),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item.category.icon,
                              size: 22,
                              color: AppColors.forestGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title & Subtitle & Expiry Pill
                        Expanded(
                          child: InkWell(
                            onTap: () => _openDetails(context, item),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.charcoal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${FoodUnit.formatQuantity(item.remainingQuantity)} ${item.unit.shortSymbol} • ${item.category.displayName}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.softGray,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: badgeBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: badgeText,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        expiryText,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: badgeText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Action button: Check to consume in 1 click
                        IconButton(
                          onPressed: () => _consumeDirectly(context, item),
                          icon: const Icon(Icons.check, size: 20, color: AppColors.sageGreen),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surfaceContainerLow,
                            shape: const CircleBorder(),
                          ),
                          tooltip: 'Marcar como consumido',
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),

            // 5. Seção: Boas Escolhas Recentes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Boas Escolhas Recentes',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: AppColors.charcoal,
                  ),
                ),
                const Icon(Icons.verified, size: 20, color: AppColors.sageGreen),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    offset: Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: impact.activities.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Nenhuma ação registrada ainda. Quando você consumir ou descartar um alimento, seu histórico aparecerá aqui.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.softGray,
                          height: 1.4,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (int i = 0; i < impact.activities.take(3).length; i++) ...[
                          if (i > 0)
                            const Divider(color: AppColors.surfaceContainerLow, height: 16),
                          _buildRecentChoiceRow(
                            title: impact.activities[i].foodName,
                            subtitle: impact.activities[i].type == ActivityType.consumed
                                ? 'Consumido • ${FoodUnit.formatQuantity(impact.activities[i].quantity)} ${impact.activities[i].unit.shortSymbol}'
                                : 'Descartado • ${FoodUnit.formatQuantity(impact.activities[i].quantity)} ${impact.activities[i].unit.shortSymbol}',
                            isConsumed: impact.activities[i].type == ActivityType.consumed,
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentChoiceRow({
    required String title,
    required String subtitle,
    bool isConsumed = true,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isConsumed ? const Color(0xFFEBF2E9) : const Color(0xFFFDE8E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isConsumed ? Icons.done_all : Icons.delete_outline,
                size: 18,
                color: isConsumed ? AppColors.forestGreen : const Color(0xFFDC2626),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.charcoal,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.softGray,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isConsumed ? const Color(0xFFEBF2E9) : const Color(0xFFFDE8E8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isConsumed ? 'Aproveitado' : 'Descartado',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isConsumed ? AppColors.forestGreen : const Color(0xFFDC2626),
            ),
          ),
        ),
      ],
    );
  }
}
