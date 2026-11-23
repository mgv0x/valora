import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/valora_app_bar.dart';
import '../../../data/models/food_item.dart';
import '../../../data/models/food_unit.dart';
import '../../../data/models/storage_location.dart';
import '../../../state/impact_provider.dart';
import '../../../state/pantry_provider.dart';
import '../food_form/add_edit_food_screen.dart';
import '../pantry/widgets/food_details_sheet.dart';
import '../pantry/widgets/record_action_dialog.dart';
import '../recipes/recipe_ideas_sheet.dart';

class ExpiryCenterScreen extends StatefulWidget {
  final VoidCallback? onOpenSettings;

  const ExpiryCenterScreen({
    super.key,
    this.onOpenSettings,
  });

  @override
  State<ExpiryCenterScreen> createState() => _ExpiryCenterScreenState();
}

class _ExpiryCenterScreenState extends State<ExpiryCenterScreen> {
  StorageLocation? _selectedStorage;

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
      onConsume: () => _onConsume(context, item),
      onDiscard: () => _onDiscard(context, item),
      onDelete: () async {
        final confirmed = await ConfirmationDialog.show(
          context,
          title: 'Excluir alimento',
          content: 'Tem certeza que deseja remover "${item.name}" do seu inventário?',
          confirmLabel: 'Excluir',
          isDestructive: true,
        );
        if (confirmed && context.mounted) {
          await context.read<PantryProvider>().deleteFood(item.id);
          if (context.mounted) {
            context.read<ImpactProvider>().loadActivities();
            UiFeedback.showSuccess(context, 'Alimento removido.');
          }
        }
      },
    );
  }

  Future<void> _onConsume(BuildContext context, FoodItem item) async {
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
        UiFeedback.showSuccess(context, '${item.name} aproveitado com sucesso! 🌱');
      }
    }
  }

  Future<void> _consumeDirectly(BuildContext context, FoodItem item) async {
    await context.read<PantryProvider>().recordConsumption(
          item: item,
          consumedQuantity: item.remainingQuantity,
        );
    if (context.mounted) {
      context.read<ImpactProvider>().loadActivities();
      UiFeedback.showSuccess(context, '${item.name} aproveitado com sucesso! 🌱');
    }
  }

  Future<void> _onDiscard(BuildContext context, FoodItem item) async {
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
        UiFeedback.showSuccess(context, 'Descarte registrado.');
      }
    }
  }

  void _showStorageFilterSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtrar por local de armazenamento',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('Todos os locais'),
                trailing: _selectedStorage == null ? const Icon(Icons.check, color: AppColors.forestGreen) : null,
                onTap: () {
                  setState(() => _selectedStorage = null);
                  Navigator.of(ctx).pop();
                },
              ),
              ...StorageLocation.values.map(
                (loc) => ListTile(
                  leading: Icon(loc.icon, color: AppColors.forestGreen),
                  title: Text(loc.displayName),
                  trailing: _selectedStorage == loc ? const Icon(Icons.check, color: AppColors.forestGreen) : null,
                  onTap: () {
                    setState(() => _selectedStorage = loc);
                    Navigator.of(ctx).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PantryProvider>();
    final allItems = provider.items;

    // Filter by storage location if selected
    final items = _selectedStorage == null
        ? allItems
        : allItems.where((i) => i.storageLocation == _selectedStorage).toList();

    // Grouping by Timeline (Stitch specification)
    final vencidos = <FoodItem>[];
    final vencemHoje = <FoodItem>[];
    final proximos3Dias = <FoodItem>[];
    final proximaSemana = <FoodItem>[];
    final maisAdiante = <FoodItem>[];

    final refDate = provider.referenceDate;
    for (final item in items) {
      final days = item.getDaysRemaining(referenceDate: refDate);
      if (days == null) {
        maisAdiante.add(item);
      } else if (days < 0) {
        vencidos.add(item);
      } else if (days == 0) {
        vencemHoje.add(item);
      } else if (days <= 3) {
        proximos3Dias.add(item);
      } else if (days <= 7) {
        proximaSemana.add(item);
      } else {
        maisAdiante.add(item);
      }
    }

    final totalAttention = vencidos.length + vencemHoje.length + proximos3Dias.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: ValoraAppBar(
        title: 'Validades',
        onProfilePressed: widget.onOpenSettings,
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.loadItems(),
        color: AppColors.forestGreen,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
          children: [
            // 1. Warm Editorial Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Validades',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                    color: AppColors.forestGreen,
                  ),
                ),
                InkWell(
                  onTap: () => _showStorageFilterSheet(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedStorage != null ? AppColors.forestGreen : AppColors.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.tune,
                      size: 20,
                      color: _selectedStorage != null ? Colors.white : AppColors.forestGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              'Consuma no seu ritmo, priorizando o que vence primeiro.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.subHeader,
              ),
            ),
            const SizedBox(height: 14),

            if (vencemHoje.isNotEmpty || proximos3Dias.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFEF3C7), Color(0xFFFFFBEB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD97706),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Ideias Anti-Desperdício',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF92400E),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD97706),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('PRO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${vencemHoje.length + proximos3Dias.length} itens podem virar receitas deliciosas.',
                            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFB45309)),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        RecipeIdeasSheet.show(context, [...vencemHoje, ...proximos3Dias]);
                      },
                      child: const Text('Ver Ideias', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 2. Guilt-free gentle overview badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: AppColors.sageGreen),
                  const SizedBox(width: 8),
                  Text(
                    totalAttention == 1
                        ? '1 alimento demanda atenção no momento'
                        : '$totalAttention alimentos demandam atenção no momento',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 3. Quick Timeline Segment Filter Pills
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterPill(
                    label: 'Todos (${allItems.length})',
                    isSelected: _selectedStorage == null,
                    onTap: () => setState(() => _selectedStorage = null),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'Geladeira (${allItems.where((i) => i.storageLocation == StorageLocation.refrigerator).length})',
                    isSelected: _selectedStorage == StorageLocation.refrigerator,
                    onTap: () => setState(() => _selectedStorage = StorageLocation.refrigerator),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'Armário (${allItems.where((i) => i.storageLocation == StorageLocation.pantry).length})',
                    isSelected: _selectedStorage == StorageLocation.pantry,
                    onTap: () => setState(() => _selectedStorage = StorageLocation.pantry),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterPill(
                    label: 'Congelador (${allItems.where((i) => i.storageLocation == StorageLocation.freezer).length})',
                    isSelected: _selectedStorage == StorageLocation.freezer,
                    onTap: () => setState(() => _selectedStorage = StorageLocation.freezer),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. SEÇÃO 0: Vencidos / Atenção Crítica
            if (vencidos.isNotEmpty) ...[
              _buildSectionHeader(
                title: 'Vencidos',
                badgeText: 'VERIFICAR OU DESCARTAR',
                badgeColor: AppColors.statusExpired,
                dotColor: AppColors.statusExpired,
              ),
              const SizedBox(height: 8),
              ...vencidos.map((item) {
                final daysPast = (item.getDaysRemaining() ?? 0).abs();
                return _buildUrgentFoodCard(
                  context,
                  item: item,
                  tagText: daysPast == 0 ? 'Venceu hoje' : 'Venceu há $daysPast ${daysPast == 1 ? "dia" : "dias"}',
                  tagBg: const Color(0xFFFFDAD6),
                  tagColor: const Color(0xFF93000A),
                  subAdvice: 'Avalie as condições do item antes do preparo ou descarte',
                );
              }),
              const SizedBox(height: 20),
            ],

            // 5. SEÇÃO 1: Vencem hoje / Consumo Imediato
            if (vencemHoje.isNotEmpty) ...[
              _buildSectionHeader(
                title: 'Vencem hoje',
                badgeText: 'CONSUMO IMEDIATO',
                badgeColor: const Color(0xFFDC2626),
                dotColor: const Color(0xFFDC2626),
              ),
              const SizedBox(height: 8),
              ...vencemHoje.map((item) => _buildUrgentFoodCard(
                    context,
                    item: item,
                    tagText: 'Vence hoje',
                    tagBg: const Color(0xFFFFDAD6),
                    tagColor: const Color(0xFF93000A),
                    subAdvice: 'Ideal para o consumo imediato ou receitas rápidas',
                  )),
              const SizedBox(height: 20),
            ],

            // 5. SEÇÃO 2: Próximos 3 dias (Atenção)
            if (proximos3Dias.isNotEmpty) ...[
              _buildSectionHeader(
                title: 'Próximos 3 dias',
                badgeText: 'ATENÇÃO LEVE',
                badgeColor: const Color(0xFF8C5B14),
                dotColor: const Color(0xFFD97706),
              ),
              const SizedBox(height: 8),
              ...proximos3Dias.map((item) {
                final days = item.getDaysRemaining() ?? 2;
                final dateStr = item.expiryDate != null
                    ? DateFormat('dd MMM', 'pt_BR').format(item.expiryDate!)
                    : '$days dias';
                return _buildUrgentFoodCard(
                  context,
                  item: item,
                  tagText: '$days dias ($dateStr)',
                  tagBg: const Color(0xFFFDF4E5),
                  tagColor: const Color(0xFF8C5B14),
                  subAdvice: 'Consuma nos próximos dias para evitar perdas',
                );
              }),
              const SizedBox(height: 20),
            ],

            // 6. SEÇÃO 3: Próxima semana (Em dia)
            if (proximaSemana.isNotEmpty) ...[
              _buildSectionHeader(
                title: 'Próxima semana',
                badgeText: 'EM DIA • TRANQUILO',
                badgeColor: AppColors.forestGreen,
                dotColor: AppColors.sageGreen,
              ),
              const SizedBox(height: 8),
              ...proximaSemana.map((item) => _buildCalmFoodCard(context, item: item)),
              const SizedBox(height: 20),
            ],

            // 7. SEÇÃO 4: Mais adiante (Longo prazo)
            if (maisAdiante.isNotEmpty) ...[
              _buildSectionHeader(
                title: 'Mais adiante',
                badgeText: 'LONGO PRAZO',
                badgeColor: AppColors.subHeader,
                dotColor: const Color(0xFFC1C8C1),
              ),
              const SizedBox(height: 8),
              ...maisAdiante.map((item) => _buildLongTermFoodCard(context, item: item)),
              const SizedBox(height: 20),
            ],

            // 8. Banner Inspirador: Planeje o jantar de hoje
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Color(0x06000000), offset: Offset(0, 2), blurRadius: 8),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.forestGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.auto_awesome, size: 22, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PLANEJE O JANTAR DE HOJE',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: AppColors.forestGreen,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Que tal preparar uma refeição prática utilizando os itens que vencem primeiro antes de fazer novas compras?',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                height: 1.4,
                                color: AppColors.charcoal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              UiFeedback.showSuccess(context, 'Sugestões de receitas em breve ✨');
                            },
                            icon: const Icon(Icons.soup_kitchen_outlined, size: 18),
                            label: const Text('Ideias de consumo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.forestGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.softWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.bookmark_border, size: 20, color: AppColors.subHeader),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 9. Micro-card de Dica de Armazenamento Sustentável
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.spa, size: 22, color: AppColors.sageGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Evitar o desperdício é um ato de cuidado diário. Cada item consumido a tempo poupa água, energia e seu bolso.',
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
    );
  }

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.forestGreen : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.subHeader,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String badgeText,
    required Color badgeColor,
    required Color dotColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
            ),
          ],
        ),
        Text(
          badgeText,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: badgeColor,
          ),
        ),
      ],
    );
  }

  Widget _buildUrgentFoodCard(
    BuildContext context, {
    required FoodItem item,
    required String tagText,
    required Color tagBg,
    required Color tagColor,
    required String subAdvice,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () => _openDetails(context, item),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.category.icon, size: 26, color: AppColors.forestGreen),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.charcoal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: tagBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tagText,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: tagColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${FoodUnit.formatQuantity(item.remainingQuantity)} ${item.unit.shortSymbol} • ${item.storageLocation?.displayName ?? "Despensa"}',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.subHeader),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subAdvice,
                        style: GoogleFonts.inter(fontSize: 11, color: tagColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: () => _consumeDirectly(context, item),
                    icon: const Icon(Icons.done, size: 16),
                    label: const Text('Consumido'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.forestGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu_book, size: 18, color: AppColors.subHeader),
                      onPressed: () => _openDetails(context, item),
                      tooltip: 'Receitas',
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 18, color: AppColors.subHeader),
                      onPressed: () => _openDetails(context, item),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalmFoodCard(BuildContext context, {required FoodItem item}) {
    final days = item.getDaysRemaining() ?? 7;
    final dateStr = item.expiryDate != null
        ? DateFormat('dd MMM', 'pt_BR').format(item.expiryDate!)
        : '$days dias';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.category.icon, size: 22, color: AppColors.forestGreen),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${FoodUnit.formatQuantity(item.remainingQuantity)} ${item.unit.shortSymbol} • ${item.storageLocation?.displayName ?? "Despensa"}',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.softGray),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$days dias ($dateStr)',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.forestGreen,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => _consumeDirectly(context, item),
                child: Row(
                  children: [
                    const Icon(Icons.check, size: 14, color: AppColors.subHeader),
                    const SizedBox(width: 2),
                    Text(
                      'Marcar',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.subHeader),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLongTermFoodCard(BuildContext context, {required FoodItem item}) {
    final dateStr = item.expiryDate != null
        ? DateFormat('dd MMM yyyy', 'pt_BR').format(item.expiryDate!)
        : 'Sem data';

    return InkWell(
      onTap: () => _openDetails(context, item),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.softWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.category.icon, size: 22, color: AppColors.softGray),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${FoodUnit.formatQuantity(item.remainingQuantity)} ${item.unit.shortSymbol} • ${item.storageLocation?.displayName ?? "Despensa"}',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.softGray),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                dateStr,
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.softGray),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
