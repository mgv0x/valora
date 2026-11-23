import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/ui_feedback.dart';
import '../../../../data/models/expiry_status.dart';
import '../../../../data/models/food_item.dart';
import '../../../../data/models/food_unit.dart';
import '../../../../state/pantry_provider.dart';
import '../../../../state/shopping_list_provider.dart';
import '../../../../state/subscription_provider.dart';
import '../../subscription/subscription_screen.dart';

class FoodDetailsSheet extends StatelessWidget {
  final FoodItem item;
  final int warningThresholdDays;
  final VoidCallback onEdit;
  final VoidCallback onConsume;
  final VoidCallback onDiscard;
  final VoidCallback onDelete;

  const FoodDetailsSheet({
    super.key,
    required this.item,
    required this.warningThresholdDays,
    required this.onEdit,
    required this.onConsume,
    required this.onDiscard,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required FoodItem item,
    required int warningThresholdDays,
    required VoidCallback onEdit,
    required VoidCallback onConsume,
    required VoidCallback onDiscard,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FoodDetailsSheet(
        item: item,
        warningThresholdDays: warningThresholdDays,
        onEdit: onEdit,
        onConsume: onConsume,
        onDiscard: onDiscard,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = item.getExpiryStatus(warningThresholdDays: warningThresholdDays);
    final daysRemaining = item.getDaysRemaining();

    final remainingQtyStr = FoodUnit.formatQuantity(item.remainingQuantity);
    final unitStr = item.unit.shortSymbol;
    final categoryStr = item.category.displayName;
    final storageStr = item.storageLocation?.displayName ?? 'Geladeira';

    String expiryDateFormatted = item.expiryDate != null
        ? DateFormat('d de MMMM', 'pt_BR').format(item.expiryDate!)
        : 'Sem data';

    String purchaseDateFormatted = item.purchaseDate != null
        ? DateFormat('d de MMMM', 'pt_BR').format(item.purchaseDate!)
        : 'Não informada';

    String statusText;
    Color statusBg;
    Color statusTextCol;

    if (status == ExpiryStatus.expired) {
      statusText = 'Vencido';
      statusBg = AppColors.statusCriticalBg;
      statusTextCol = AppColors.statusCriticalText;
    } else if (status == ExpiryStatus.expiringToday) {
      statusText = 'Vence hoje';
      statusBg = const Color(0xFFFFEDD5);
      statusTextCol = const Color(0xFFEA580C);
    } else if (status == ExpiryStatus.expiringSoon) {
      statusText = 'Atenção • Vence em ${daysRemaining ?? 3} dias';
      statusBg = const Color(0xFFFDF4E5);
      statusTextCol = const Color(0xFF8C5B14);
    } else if (status == ExpiryStatus.unknown) {
      statusText = 'Validade não informada';
      statusBg = AppColors.statusUnknownBg;
      statusTextCol = AppColors.statusUnknown;
    } else {
      statusText = 'Em dia • Seguro';
      statusBg = const Color(0xFFEBF2E9);
      statusTextCol = AppColors.forestGreen;
    }

    final double freshnessProgress;
    final String freshnessText;
    final Color freshnessColor;
    if (item.expiryDate == null) {
      freshnessProgress = 0.0;
      freshnessText = 'Sem data de validade cadastrada';
      freshnessColor = AppColors.forestGreen;
    } else {
      final startDate = item.purchaseDate ?? item.createdAt;
      final totalDays = item.expiryDate!.difference(startDate).inDays;
      final elapsedDays = DateTime.now().difference(startDate).inDays;
      if (totalDays <= 0) {
        freshnessProgress = (daysRemaining != null && daysRemaining <= 0) ? 1.0 : 0.0;
      } else {
        freshnessProgress = (elapsedDays / totalDays).clamp(0.0, 1.0);
      }
      final pct = (freshnessProgress * 100).toInt();
      if (daysRemaining != null && daysRemaining < 0) {
        freshnessText = '100% decorrido (Vencido)';
        freshnessColor = AppColors.statusExpired;
      } else if (freshnessProgress >= 0.8) {
        freshnessText = '$pct% decorrido (Atenção)';
        freshnessColor = const Color(0xFFEA580C);
      } else {
        freshnessText = '$pct% decorrido';
        freshnessColor = AppColors.forestGreen;
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.darkBackground : AppColors.canvas;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.softWhite;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final subTextColor = isDark ? AppColors.textSecondaryDark : AppColors.subHeader;
    final bannerFill = isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceContainerLow;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Handle bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Top action bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_back, size: 20, color: AppColors.forestGreen),
                      const SizedBox(width: 4),
                      Text(
                        'Despensa',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.subHeader),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onEdit();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.statusCriticalText),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onDelete();
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Hero Highlight Card
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image/Category Banner Box
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: bannerFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(item.category.icon, size: 52, color: AppColors.forestGreen),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              statusText,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: statusTextCol,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.eco, size: 14, color: AppColors.forestGreen),
                                const SizedBox(width: 4),
                                Text(
                                  'Zero Desperdício',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.forestGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    item.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$categoryStr • $remainingQtyStr $unitStr',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.subHeader),
                  ),
                  const SizedBox(height: 12),

                  // Freshness Visual Meter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ciclo de frescor', style: GoogleFonts.inter(fontSize: 12, color: AppColors.subHeader)),
                      Text(freshnessText, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: freshnessColor)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: freshnessProgress,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceContainer,
                      valueColor: AlwaysStoppedAnimation<Color>(freshnessColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Essential Details Grid (4 tiles 2x2)
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INFORMAÇÕES ESSENCIAIS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.softGray,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.shelves,
                          label: 'Local',
                          val: storageStr,
                          sub: 'Organizado na despensa',
                          color: AppColors.sageGreen,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.scale,
                          label: 'Quantidade',
                          val: '$remainingQtyStr $unitStr',
                          sub: 'Em estoque',
                          color: AppColors.sageGreen,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.alarm_outlined,
                          label: 'Validade',
                          val: expiryDateFormatted,
                          sub: daysRemaining != null ? 'Em $daysRemaining dias' : 'Sem validade',
                          color: const Color(0xFF8C5B14),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInfoTile(
                          icon: Icons.shopping_bag,
                          label: 'Cadastro',
                          val: purchaseDateFormatted,
                          sub: 'Registrado no app',
                          color: AppColors.sageGreen,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Conservation Insight Pill
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD0EAC9).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD0EAC9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lightbulb, size: 20, color: AppColors.forestGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dica de Conservação',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.forestGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mantenha o alimento em local fresco e bem ventilado. Consuma os itens abertos primeiro para prolongar a vida útil.',
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
              ),
            ),
            if (item.notes != null && item.notes!.trim().isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OBSERVAÇÕES',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: subTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.notes!,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.charcoal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Action Buttons Block
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConsume();
                },
                icon: const Icon(Icons.restaurant_rounded, size: 20),
                label: const Text('Marcar como Consumido'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forestGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Função 8 [PREMIUM]: Congelar para Salvar (+90 dias)
            SizedBox(
              height: 44,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final subscription = context.read<SubscriptionProvider>();
                  if (!subscription.hasActiveAccess) {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                    );
                    return;
                  }
                  await context.read<PantryProvider>().freezeItemToExtendShelfLife(item);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    UiFeedback.showSuccess(context, '${item.name} congelado! Validade estendida em +90 dias ❄️');
                  }
                },
                icon: const Icon(Icons.ac_unit_rounded, size: 18, color: Color(0xFF0284C7)),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Congelar para Salvar (+90 dias)',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('PRO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
                    ),
                  ],
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFBAE6FD)),
                  backgroundColor: const Color(0xFFF0F9FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Função 1 [FREE]: Adicionar à Lista de Compras
            SizedBox(
              height: 44,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<ShoppingListProvider>().addFromPantryFood(item);
                  UiFeedback.showSuccess(context, '${item.name} colocado na Lista de Compras!');
                },
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 18, color: AppColors.forestGreen),
                label: Text(
                  'Adicionar à Lista de Compras',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestGreen,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDiscard();
                },
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.subHeader),
                label: Text(
                  'Registrar Descarte',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.subHeader,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String val,
    required String sub,
    required Color color,
    bool isDark = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.subHeader,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            val,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.charcoal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.softGray,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
