import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/expiry_status.dart';
import '../../../../data/models/food_item.dart';
import '../../../../data/models/food_unit.dart';
import '../../../../data/models/storage_location.dart';

class FoodItemTile extends StatelessWidget {
  final FoodItem item;
  final int warningThresholdDays;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback onConsume;
  final VoidCallback onDiscard;
  final VoidCallback onDelete;

  const FoodItemTile({
    super.key,
    required this.item,
    required this.warningThresholdDays,
    required this.onTap,
    this.onEdit,
    required this.onConsume,
    required this.onDiscard,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final status = item.getExpiryStatus(warningThresholdDays: warningThresholdDays);
    final daysRemaining = item.getDaysRemaining();

    final remainingQtyStr = FoodUnit.formatQuantity(item.remainingQuantity);
    final unitStr = item.unit.shortSymbol;
    final categoryStr = item.category.displayName;
    final storageStr = item.storageLocation?.displayName ?? 'Despensa';

    // Semantic colors and badge text
    String badgeText;
    Color badgeBg;
    Color badgeColor;
    IconData dateIcon;

    if (status == ExpiryStatus.expired) {
      badgeText = 'Vencido';
      badgeBg = AppColors.statusCriticalBg;
      badgeColor = AppColors.statusCriticalText;
      dateIcon = Icons.warning_amber_rounded;
    } else if (status == ExpiryStatus.expiringToday) {
      badgeText = 'Vence hoje';
      badgeBg = const Color(0xFFFFEDD5);
      badgeColor = const Color(0xFFEA580C);
      dateIcon = Icons.event_busy;
    } else if (status == ExpiryStatus.expiringSoon) {
      badgeText = 'Atenção';
      badgeBg = const Color(0xFFFDF4E5);
      badgeColor = const Color(0xFF8C5B14);
      dateIcon = Icons.alarm_outlined;
    } else if (status == ExpiryStatus.unknown) {
      badgeText = 'Sem data';
      badgeBg = AppColors.statusUnknownBg;
      badgeColor = AppColors.statusUnknown;
      dateIcon = Icons.help_outline_rounded;
    } else {
      badgeText = 'Em dia';
      badgeBg = const Color(0xFFEBF2E9);
      badgeColor = AppColors.forestGreen;
      dateIcon = Icons.event_available;
    }

    String dateDetail;
    if (item.expiryDate != null) {
      final formattedDate = DateFormat('dd MMM', 'pt_BR').format(item.expiryDate!);
      if (daysRemaining != null && daysRemaining < 0) {
        final absDays = daysRemaining.abs();
        dateDetail = 'Validade: $formattedDate (venceu há $absDays ${absDays == 1 ? "dia" : "dias"})';
      } else if (daysRemaining != null && daysRemaining == 0) {
        dateDetail = 'Validade: $formattedDate (vence hoje • ⚠️ Urgente)';
      } else if (daysRemaining != null && daysRemaining == 1) {
        dateDetail = 'Validade: $formattedDate (amanhã • ⚠️ Prioridade)';
      } else if (daysRemaining != null && daysRemaining <= 3) {
        dateDetail = 'Validade: $formattedDate ($daysRemaining dias • ⏳ Consumir logo)';
      } else if (daysRemaining != null) {
        dateDetail = 'Validade: $formattedDate ($daysRemaining dias • 🌱 Ritmo tranquilo)';
      } else {
        dateDetail = 'Validade: $formattedDate';
      }
    } else {
      dateDetail = 'Sem validade cadastrada';
    }

    IconData storageIcon = Icons.kitchen;
    if (item.storageLocation == StorageLocation.freezer ||
        storageStr.toLowerCase().contains('freezer') ||
        storageStr.toLowerCase().contains('congelador')) {
      storageIcon = Icons.severe_cold;
    } else if (item.storageLocation == StorageLocation.pantry ||
        storageStr.toLowerCase().contains('armário') ||
        storageStr.toLowerCase().contains('despensa')) {
      storageIcon = Icons.shelves;
    }

    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Thumbnail Container with Storage Icon Badge
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.category.icon,
                        size: 26,
                        color: AppColors.forestGreen,
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [
                            BoxShadow(color: Color(0x15000000), blurRadius: 3),
                          ],
                        ),
                        child: Icon(
                          storageIcon,
                          size: 13,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                // 2. Main Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.charcoal,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Text(
                                      '$categoryStr • $storageStr • ',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.subHeader,
                                      ),
                                    ),
                                    Text(
                                      '$remainingQtyStr $unitStr',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.subHeader,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          if (status == ExpiryStatus.expiringToday || (daysRemaining != null && daysRemaining <= 1 && daysRemaining >= 0)) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.flash_on_rounded, size: 12, color: Color(0xFFD97706)),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Resgatar',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF92400E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],

                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: badgeColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  badgeText,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: badgeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Bottom Date & Chevron
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(dateIcon, size: 15, color: badgeColor),
                              const SizedBox(width: 6),
                              Text(
                                dateDetail,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: badgeColor,
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Color(0xFFC1C8C1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
