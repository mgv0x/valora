import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/valora_app_bar.dart';
import '../../../data/models/food_category.dart';
import '../../../data/models/food_item.dart';
import '../../../data/models/storage_location.dart';
import '../../../state/impact_provider.dart';
import '../../../state/pantry_provider.dart';
import '../food_form/add_edit_food_screen.dart';
import 'widgets/food_details_sheet.dart';
import 'widgets/food_item_tile.dart';
import 'widgets/record_action_dialog.dart';

class PantryScreen extends StatefulWidget {
  final VoidCallback? onOpenSettings;

  const PantryScreen({
    super.key,
    this.onOpenSettings,
  });

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    context.read<PantryProvider>().setSearchQuery(val);
  }

  void _openAddFood() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddEditFoodScreen()),
    );
  }

  void _openFoodDetails(FoodItem item) {
    FoodDetailsSheet.show(
      context,
      item: item,
      warningThresholdDays: context.read<PantryProvider>().warningThresholdDays,
      onEdit: () => _openEditFood(item),
      onConsume: () => _onConsume(item),
      onDiscard: () => _onDiscard(item),
      onDelete: () => _onDelete(item),
    );
  }

  void _openEditFood(FoodItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditFoodScreen(initialItem: item)),
    );
  }

  Future<void> _onConsume(FoodItem item) async {
    final result = await RecordActionDialog.show(context, item: item, isDiscard: false);
    if (result != null && mounted) {
      final qty = result['quantity'] as double;
      final notes = result['notes'] as String?;
      await context.read<PantryProvider>().recordConsumption(
            item: item,
            consumedQuantity: qty,
            notes: notes,
          );
      if (mounted) {
        context.read<ImpactProvider>().loadActivities();
        UiFeedback.showSuccess(context, '${item.name} consumido com sucesso!');
      }
    }
  }

  Future<void> _onDiscard(FoodItem item) async {
    final result = await RecordActionDialog.show(context, item: item, isDiscard: true);
    if (result != null && mounted) {
      final qty = result['quantity'] as double;
      final notes = result['notes'] as String?;
      await context.read<PantryProvider>().recordDisposal(
            item: item,
            discardedQuantity: qty,
            notes: notes,
          );
      if (mounted) {
        context.read<ImpactProvider>().loadActivities();
        UiFeedback.showSuccess(context, 'Descarte registrado.');
      }
    }
  }

  Future<void> _onDelete(FoodItem item) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Excluir alimento',
      content: 'Tem certeza de que deseja excluir permanentemente "${item.name}"?',
      confirmLabel: 'Excluir',
      cancelLabel: 'Cancelar',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      await context.read<PantryProvider>().deleteFood(item.id);
      if (mounted) {
        UiFeedback.showSuccess(context, 'Alimento removido da despensa.');
      }
    }
  }

  void _showSortMenu() {
    final provider = context.read<PantryProvider>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Ordenar por',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.arrow_downward_rounded, color: AppColors.forestGreen),
                  title: const Text('Validade (mais próximos)'),
                  trailing: provider.sortOption == PantrySortOption.expirySoonest
                      ? const Icon(Icons.check, color: AppColors.forestGreen)
                      : null,
                  onTap: () {
                    provider.setSortOption(PantrySortOption.expirySoonest);
                    Navigator.of(ctx).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.arrow_upward_rounded, color: AppColors.forestGreen),
                  title: const Text('Validade (mais distantes)'),
                  trailing: provider.sortOption == PantrySortOption.expiryLatest
                      ? const Icon(Icons.check, color: AppColors.forestGreen)
                      : null,
                  onTap: () {
                    provider.setSortOption(PantrySortOption.expiryLatest);
                    Navigator.of(ctx).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha_rounded, color: AppColors.forestGreen),
                  title: const Text('Nome (A-Z)'),
                  trailing: provider.sortOption == PantrySortOption.nameAZ
                      ? const Icon(Icons.check, color: AppColors.forestGreen)
                      : null,
                  onTap: () {
                    provider.setSortOption(PantrySortOption.nameAZ);
                    Navigator.of(ctx).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha_rounded, color: AppColors.forestGreen),
                  title: const Text('Nome (Z-A)'),
                  trailing: provider.sortOption == PantrySortOption.nameZA
                      ? const Icon(Icons.check, color: AppColors.forestGreen)
                      : null,
                  onTap: () {
                    provider.setSortOption(PantrySortOption.nameZA);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PantryProvider>();
    final items = provider.filteredAndSortedItems;
    final totalCount = provider.totalActiveCount;
    final needsActionCount = provider.needsAttentionCount;
    final activeCategory = provider.selectedCategory;
    final activeStorage = provider.selectedStorageFilter;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: ValoraAppBar(
        title: 'Despensa',
        onProfilePressed: widget.onOpenSettings,
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadItems(),
        color: AppColors.forestGreen,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 88),
          children: [
            // 1. Cabeçalho de Página
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Minha Despensa',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.sageGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$totalCount alimentos organizados',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.subHeader,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.eco, size: 16, color: AppColors.forestGreen),
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
              ],
            ),
            const SizedBox(height: 16),

            // 2. Campo de Busca Minimalista e Filtro
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.softWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: const [
                        BoxShadow(color: Color(0x06000000), offset: Offset(0, 1), blurRadius: 4),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 20, color: AppColors.softGray),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            style: GoogleFonts.inter(fontSize: 14, color: AppColors.charcoal),
                            decoration: InputDecoration(
                              hintText: 'Buscar alimento ou categoria...',
                              hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.softGray),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close, size: 18, color: AppColors.softGray),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.softWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 1),
                    boxShadow: const [
                      BoxShadow(color: Color(0x06000000), offset: Offset(0, 1), blurRadius: 4),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune, size: 20, color: AppColors.subHeader),
                    onPressed: _showSortMenu,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 3. Chips de Categorias Deslizáveis
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip(
                    label: 'Todos ($totalCount)',
                    isSelected: activeCategory == null,
                    onTap: () => provider.setSelectedCategory(null),
                  ),
                  const SizedBox(width: 8),
                  ...FoodCategory.values.map((cat) {
                    final isSel = activeCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildCategoryChip(
                        label: cat.displayName,
                        isSelected: isSel,
                        onTap: () => provider.setSelectedCategory(isSel ? null : cat),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 3.1 Filtro Rápido por Local de Armazenamento
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildStorageChip(
                    label: 'Todos locais',
                    icon: Icons.all_inbox_outlined,
                    isSelected: activeStorage == null,
                    onTap: () => provider.setSelectedStorageFilter(null),
                  ),
                  const SizedBox(width: 6),
                  ...StorageLocation.values.map((loc) {
                    final isSel = activeStorage == loc;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _buildStorageChip(
                        label: loc.displayName,
                        icon: loc.icon,
                        isSelected: isSel,
                        onTap: () => provider.setSelectedStorageFilter(isSel ? null : loc),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 4. Barra de Ordenação Contextual & Resumo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: _showSortMenu,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sort, size: 16, color: AppColors.sageGreen),
                        const SizedBox(width: 6),
                        Text(
                          'Ordenar: ',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.subHeader,
                          ),
                        ),
                        Text(
                          switch (provider.sortOption) {
                            PantrySortOption.expirySoonest => 'Validade',
                            PantrySortOption.expiryLatest => 'Validade (distante)',
                            PantrySortOption.nameAZ => 'Nome (A-Z)',
                            PantrySortOption.nameZA => 'Nome (Z-A)',
                          },
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const Icon(Icons.expand_more, size: 16, color: AppColors.subHeader),
                      ],
                    ),
                  ),
                ),
                if (needsActionCount > 0)
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC2626),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$needsActionCount requerem consumo',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.subHeader,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 5. Lista de Alimentos
            if (items.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.softWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.shelves, size: 40, color: AppColors.sageGreen),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhum alimento encontrado',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tente ajustar seus filtros ou cadastre um novo alimento.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.softGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (ctx, idx) {
                  final item = items[idx];
                  return FoodItemTile(
                    item: item,
                    warningThresholdDays: provider.warningThresholdDays,
                    onTap: () => _openFoodDetails(item),
                    onEdit: () => _openEditFood(item),
                    onConsume: () => _onConsume(item),
                    onDiscard: () => _onDiscard(item),
                    onDelete: () => _onDelete(item),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddFood,
        backgroundColor: AppColors.forestGreen,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, size: 16, color: Colors.white),
        ),
        label: Text(
          'Novo alimento',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return CategoryChip(
      label: label,
      isSelected: isSelected,
      onSelected: onTap,
    );
  }

  Widget _buildStorageChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.forestGreen.withValues(alpha: 0.12) : AppColors.softWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.forestGreen : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColors.forestGreen : AppColors.subHeader,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.forestGreen : AppColors.subHeader,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
