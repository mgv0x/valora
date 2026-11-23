import 'package:flutter/material.dart';
import 'package:valora/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../data/models/food_item.dart';
import '../../../../data/models/food_unit.dart';

class RecordActionDialog extends StatefulWidget {
  final FoodItem item;
  final bool isDiscard;

  const RecordActionDialog({
    super.key,
    required this.item,
    required this.isDiscard,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required FoodItem item,
    required bool isDiscard,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => RecordActionDialog(item: item, isDiscard: isDiscard),
    );
  }

  @override
  State<RecordActionDialog> createState() => _RecordActionDialogState();
}

class _RecordActionDialogState extends State<RecordActionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  final _notesController = TextEditingController();
  bool _isAll = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: FoodUnit.formatQuantity(widget.item.remainingQuantity),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onToggleAll(bool all) {
    setState(() {
      _isAll = all;
      if (all) {
        _quantityController.text = FoodUnit.formatQuantity(widget.item.remainingQuantity);
      }
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final double qtyToApply;
    if (_isAll) {
      qtyToApply = widget.item.remainingQuantity;
    } else {
      final enteredQty = double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 0;
      if (enteredQty <= 0 || enteredQty > widget.item.remainingQuantity + 0.0001) {
        return;
      }
      qtyToApply = enteredQty;
    }

    if (widget.isDiscard) {
      final l10n = AppLocalizations.of(context);
      final unitStr = l10n != null ? widget.item.unit.localizedShort(l10n) : widget.item.unit.shortSymbol;
      final confirmed = await ConfirmationDialog.show(
        context,
        title: l10n?.discardConfirmPermanent ?? 'Confirmar Descarte',
        content: l10n != null
            ? l10n.discardConfirmPermanentPrompt(
                FoodUnit.formatQuantity(qtyToApply),
                unitStr,
                widget.item.name,
              )
            : 'Descartar ${FoodUnit.formatQuantity(qtyToApply)} $unitStr de "${widget.item.name}"?',
        confirmLabel: l10n?.discard ?? 'Descartar',
        cancelLabel: l10n?.cancel ?? 'Cancelar',
        isDestructive: true,
      );

      if (!confirmed || !mounted) return;
    }

    setState(() => _isSubmitting = true);

    Navigator.of(context).pop({
      'quantity': qtyToApply,
      'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unitStr = l10n != null ? widget.item.unit.localizedShort(l10n) : widget.item.unit.shortSymbol;

    final title = widget.isDiscard
        ? (l10n?.discardDialogTitle ?? 'Registrar Descarte')
        : (l10n?.consumeDialogTitle ?? 'Registrar Consumo');
    final prompt = widget.isDiscard
        ? (l10n?.discardDialogPrompt ?? 'Quanto você gostaria de descartar?')
        : (l10n?.consumeDialogPrompt ?? 'Quanto você consumiu?');
    final actionColor = widget.isDiscard ? AppColors.statusExpired : AppColors.primarySage;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: actionColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isDiscard ? Icons.delete_outline_rounded : Icons.restaurant_rounded,
                      color: actionColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.headline.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          widget.item.name,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                prompt,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),
              // All vs Partial toggle
              Row(
                children: [
                  ChoiceChip(
                    label: Text(
                      '${l10n?.all ?? "Tudo"} (${FoodUnit.formatQuantity(widget.item.remainingQuantity)} $unitStr)',
                    ),
                    selected: _isAll,
                    onSelected: (val) => _onToggleAll(true),
                    selectedColor: actionColor.withValues(alpha: 0.2),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(l10n?.partial ?? 'Parcial'),
                    selected: !_isAll,
                    onSelected: (val) => _onToggleAll(false),
                    selectedColor: actionColor.withValues(alpha: 0.2),
                  ),
                ],
              ),
              if (!_isAll) ...[
                const SizedBox(height: 14),
                AppTextField(
                  label: '${l10n?.quantity ?? "Quantidade"} ($unitStr)',
                  controller: _quantityController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return l10n?.quantityRequired ?? 'Informe a quantidade';
                    }
                    final parsed = double.tryParse(val.replaceAll(',', '.'));
                    if (parsed == null || parsed <= 0) {
                      return l10n?.quantityRequired ?? 'Informe uma quantidade válida';
                    }
                    if (parsed > widget.item.remainingQuantity + 0.0001) {
                      return l10n != null
                          ? l10n.quantityExceedsRemaining(
                              FoodUnit.formatQuantity(widget.item.remainingQuantity),
                              unitStr,
                            )
                          : 'Quantidade excede o restante em estoque.';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 14),
              AppTextField(
                label: l10n?.notesOptional ?? 'Observações (opcional)',
                controller: _notesController,
                hint: widget.isDiscard
                    ? (l10n?.discardNotesHint ?? 'Motivo do descarte...')
                    : (l10n?.consumeNotesHint ?? 'Ex: receita, lanche...'),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: l10n?.cancel ?? 'Cancelar',
                    variant: AppButtonVariant.secondary,
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  AppButton(
                    label: widget.isDiscard ? (l10n?.discard ?? 'Descartar') : (l10n?.consume ?? 'Consumir'),
                    variant: widget.isDiscard ? AppButtonVariant.destructive : AppButtonVariant.primary,
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
