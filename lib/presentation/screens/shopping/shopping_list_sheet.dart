import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../data/models/food_category.dart';
import '../../../data/models/food_unit.dart';
import '../../../state/shopping_list_provider.dart';

class ShoppingListSheet extends StatefulWidget {
  const ShoppingListSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ShoppingListSheet(),
    );
  }

  @override
  State<ShoppingListSheet> createState() => _ShoppingListSheetState();
}

class _ShoppingListSheetState extends State<ShoppingListSheet> {
  final _textController = TextEditingController();
  final FoodCategory _selectedCategory = FoodCategory.pantryStaples;
  double _quantity = 1.0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleAdd() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    context.read<ShoppingListProvider>().addItem(
          name: text,
          category: _selectedCategory,
          quantity: _quantity,
          unit: FoodUnit.piece,
        );
    _textController.clear();
    setState(() => _quantity = 1.0);
    UiFeedback.showSuccess(context, '$text adicionado à lista de compras!');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShoppingListProvider>();
    final items = provider.items;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.forestGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shopping_cart_outlined,
                          color: AppColors.forestGreen, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lista de Compras',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                        Text(
                          '${provider.uncheckedCount} itens pendentes',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.subHeader,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (items.any((i) => i.isChecked))
                  TextButton.icon(
                    icon: const Icon(Icons.delete_sweep, size: 16),
                    label: const Text('Limpar comprados'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.statusCriticalText,
                    ),
                    onPressed: () => provider.clearCompleted(),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Quick Add Input
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Ex: Leite, Ovos, Pão de forma...',
                      isDense: true,
                      prefixIcon: const Icon(Icons.add, size: 20, color: AppColors.subHeader),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    onSubmitted: (_) => _handleAdd(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onPressed: _handleAdd,
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          ),

          // Items List
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.checklist_rtl_rounded,
                            size: 56, color: AppColors.softGray.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          'Sua lista de compras está vazia!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Itens consumidos podem ser adicionados em 1 toque.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.subHeader,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: items.length,
                    itemBuilder: (ctx, idx) {
                      final item = items[idx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: item.isChecked
                              ? AppColors.surfaceContainerLow.withValues(alpha: 0.5)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: item.isChecked
                                ? AppColors.border.withValues(alpha: 0.5)
                                : AppColors.border,
                          ),
                        ),
                        child: ListTile(
                          dense: true,
                          leading: Checkbox(
                            value: item.isChecked,
                            activeColor: AppColors.forestGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (_) => provider.toggleItem(item.id),
                          ),
                          title: Text(
                            item.name,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              decoration: item.isChecked ? TextDecoration.lineThrough : null,
                              color: item.isChecked ? AppColors.softGray : AppColors.charcoal,
                            ),
                          ),
                          subtitle: Text(
                            'Qtd: ${item.quantity.toInt()} ${item.unit.shortSymbol} • ${item.category.name}',
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.subHeader),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 18, color: AppColors.softGray),
                            onPressed: () => provider.removeItem(item.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
