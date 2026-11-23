import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../data/models/food_activity.dart';
import '../../../../data/models/food_unit.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ActivityDetailsSheet extends StatelessWidget {
  final FoodActivity activity;

  const ActivityDetailsSheet({
    super.key,
    required this.activity,
  });

  static Future<void> show(BuildContext context, {required FoodActivity activity}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ActivityDetailsSheet(activity: activity),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor ?? AppColors.primarySage),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.titleMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMMMd(locale).add_jm();

    final isConsumed = activity.type == ActivityType.consumed;
    final actionColor = isConsumed ? AppColors.primarySage : AppColors.statusExpired;
    final actionIcon = isConsumed ? Icons.restaurant_rounded : Icons.delete_outline_rounded;
    final actionLabel = isConsumed
        ? (l10n?.consume ?? 'Consumido')
        : (l10n?.discard ?? 'Descartado');

    final qtyStr = FoodUnit.formatQuantity(activity.quantity);
    final unitStr = l10n != null ? activity.unit.localizedShort(l10n) : activity.unit.shortSymbol;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header: Action icon circle + Food name + Action type badge
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: actionColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    actionIcon,
                    size: 26,
                    color: actionColor,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.foodName,
                        style: AppTypography.displayMedium.copyWith(
                          fontSize: 18,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n != null ? activity.category.localizedName(l10n) : activity.category.displayName,
                        style: AppTypography.caption.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: actionColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    actionLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: actionColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Details card
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                children: [
                  _buildInfoRow(
                    context: context,
                    icon: Icons.scale_rounded,
                    label: l10n?.quantity ?? 'Quantidade',
                    value: '$qtyStr $unitStr',
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context: context,
                    icon: Icons.access_time_rounded,
                    label: l10n?.activityDate ?? 'Data da Ação',
                    value: dateFormat.format(activity.timestamp),
                  ),
                  const Divider(),
                  _buildInfoRow(
                    context: context,
                    icon: activity.category.icon,
                    label: l10n?.category ?? 'Categoria',
                    value: l10n != null ? activity.category.localizedName(l10n) : activity.category.displayName,
                  ),
                  if (activity.estimatedValue != null) ...[
                    const Divider(),
                    _buildInfoRow(
                      context: context,
                      icon: Icons.attach_money_rounded,
                      label: l10n?.activityEstimatedValue ?? 'Valor Estimado',
                      value: CurrencyFormatter.format(activity.estimatedValue, localeCode: locale),
                      iconColor: actionColor,
                    ),
                  ],
                  if (activity.notes != null && activity.notes!.isNotEmpty) ...[
                    const Divider(),
                    _buildInfoRow(
                      context: context,
                      icon: Icons.notes_rounded,
                      label: l10n?.notes ?? 'Observações',
                      value: activity.notes!,
                    ),
                  ],
                ],
              ),
            ),

            if (activity.estimatedValue != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  l10n?.activityValueFormulaNotice ?? 'Cálculo proporcional baseado no preço de compra.',
                  style: AppTypography.caption.copyWith(
                    color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                    fontSize: 11,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Fechar',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
