import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../data/models/expiry_status.dart';
import '../../../data/models/food_category.dart';
import '../../../data/models/food_item.dart';
import '../../../data/models/food_unit.dart';
import '../../../data/models/storage_location.dart';
import '../../../state/pantry_provider.dart';
import 'widgets/api_food_search_sheet.dart';

class AddEditFoodScreen extends StatefulWidget {
  final FoodItem? initialItem;

  const AddEditFoodScreen({super.key, this.initialItem});

  @override
  State<AddEditFoodScreen> createState() => _AddEditFoodScreenState();
}

class _AddEditFoodScreenState extends State<AddEditFoodScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late final TextEditingController _priceController;
  double _quantity = 1.0;
  late FoodUnit _unit;
  late FoodCategory _category;
  StorageLocation _storageLocation = StorageLocation.refrigerator;

  DateTime? _expiryDate;
  bool _noExpiry = false;
  int? _selectedShortcutDays = 7;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;

    _nameController = TextEditingController(text: item?.name ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');
    _priceController = TextEditingController(
      text: item?.purchasePrice != null ? item!.purchasePrice!.toStringAsFixed(2) : '',
    );
    _quantity = item?.remainingQuantity ?? 1.0;
    _unit = item?.unit ?? FoodUnit.piece;
    _category = item?.category ?? FoodCategory.fruits;
    _storageLocation = item?.storageLocation ?? StorageLocation.refrigerator;

    if (item != null) {
      _expiryDate = item.expiryDate;
      _noExpiry = item.expiryDate == null;
      _selectedShortcutDays = null;
    } else {
      _expiryDate = DateTime.now().add(const Duration(days: 7));
      _selectedShortcutDays = 7;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _applyShortcut(int days) {
    setState(() {
      _selectedShortcutDays = days;
      _noExpiry = false;
      _expiryDate = DateTime.now().add(Duration(days: days));
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now.add(const Duration(days: 7)),
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
        _noExpiry = false;
        _selectedShortcutDays = null;
      });
    }
  }

  void _applyQuickSuggestion(
    String name,
    FoodCategory cat,
    StorageLocation loc,
    FoodUnit unit,
    int days,
  ) {
    setState(() {
      _nameController.text = name;
      _category = cat;
      _storageLocation = loc;
      _unit = unit;
      _expiryDate = DateTime.now().add(Duration(days: days));
      _selectedShortcutDays = days;
      _noExpiry = false;
    });
  }

  Future<void> _openApiSearch() async {
    final selected = await ApiFoodSearchSheet.show(context);
    if (selected != null && mounted) {
      setState(() {
        _nameController.text = selected.name;
        _category = selected.category;
        _storageLocation = selected.suggestedStorage;
        _unit = selected.unit;
        _expiryDate = DateTime.now().add(Duration(days: selected.suggestedShelfLifeDays));
        _selectedShortcutDays = selected.suggestedShelfLifeDays;
        _noExpiry = false;
        if (selected.brand != null && selected.brand!.isNotEmpty) {
          _notesController.text = 'Marca: ${selected.brand}';
        }
      });
      UiFeedback.showSuccess(context, 'Dados carregados da API Open Food Facts!');
    }
  }

  Future<void> _saveFood() async {
    if (_isSaving) return;
    if (_nameController.text.trim().isEmpty) {
      UiFeedback.showError(context, 'Por favor, informe o nome do alimento.');
      return;
    }

    if (_quantity <= 0 || _quantity.isNaN || _quantity.isInfinite) {
      UiFeedback.showError(context, 'Por favor, informe uma quantidade válida maior que zero.');
      return;
    }

    final priceText = _priceController.text.trim().replaceAll(',', '.');
    final purchasePrice = priceText.isNotEmpty ? double.tryParse(priceText) : null;
    if (purchasePrice != null && (purchasePrice < 0 || purchasePrice.isNaN || purchasePrice.isInfinite)) {
      UiFeedback.showError(context, 'O preço deve ser um valor numérico positivo ou zero.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final pantry = context.read<PantryProvider>();
      final isEditing = widget.initialItem != null;

      final FoodItem item;
      if (isEditing) {
        final initial = widget.initialItem!;
        item = initial.copyWith(
          name: _nameController.text.trim(),
          category: _category,
          initialQuantity: _quantity + initial.consumedQuantity + initial.discardedQuantity,
          unit: _unit,
          storageLocation: _storageLocation,
          clearStorageLocation: false,
          expiryDate: _noExpiry ? null : _expiryDate,
          clearExpiryDate: _noExpiry,
          purchasePrice: purchasePrice,
          clearPurchasePrice: purchasePrice == null,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          clearNotes: _notesController.text.trim().isEmpty,
          updatedAt: DateTime.now(),
        );
      } else {
        item = FoodItem(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          category: _category,
          initialQuantity: _quantity,
          unit: _unit,
          storageLocation: _storageLocation,
          purchaseDate: (_expiryDate != null && !_noExpiry && _expiryDate!.isBefore(DateTime.now()))
              ? _expiryDate
              : DateTime.now(),
          expiryDate: _noExpiry ? null : _expiryDate,
          purchasePrice: purchasePrice,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      if (isEditing) {
        await pantry.updateFood(item);
      } else {
        await pantry.addFood(item);
      }

      if (mounted) {
        UiFeedback.showSuccess(context, isEditing ? 'Alimento atualizado!' : 'Alimento cadastrado com sucesso!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        UiFeedback.showError(context, 'Erro ao salvar: $e');
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialItem != null;

    String expiryFeedbackText = '';
    if (_noExpiry) {
      expiryFeedbackText = 'Sem validade cadastrada';
    } else if (_expiryDate != null) {
      final days = ExpiryStatus.daysRemaining(expiryDate: _expiryDate);
      if (days == null) {
        expiryFeedbackText = 'Sem validade cadastrada';
      } else if (days < 0) {
        final abs = -days;
        expiryFeedbackText = abs == 1 ? 'Vencido há 1 dia' : 'Vencido há $abs dias';
      } else if (days == 0) {
        expiryFeedbackText = 'Expira hoje';
      } else if (days == 1) {
        expiryFeedbackText = 'Expira amanhã';
      } else if (days == 30) {
        expiryFeedbackText = 'Expira em 1 mês';
      } else {
        expiryFeedbackText = 'Expira em $days dias';
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
          children: [
            // 1. Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back, size: 20, color: AppColors.subHeader),
                        const SizedBox(width: 4),
                        Text(
                          'Cancelar',
                          style: GoogleFonts.inter(fontSize: 14, color: AppColors.subHeader),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0EAC9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.eco, size: 15, color: AppColors.forestGreen),
                      const SizedBox(width: 4),
                      Text(
                        'Despensa Consciente',
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
            const SizedBox(height: 12),

            // Header Title
            Text(
              isEditing ? 'Editar Alimento' : 'Novo Alimento',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.forestGreen,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Adicione à sua despensa para acompanhar validades sem esforço.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.subHeader),
            ),
            const SizedBox(height: 16),

            // Seção 1: Nome & Sugestões Rápidas
            Container(
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
                      Text(
                        'Nome do item',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                      Text(
                        'Obrigatório',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.softGray),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 20, color: AppColors.softGray),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _nameController,
                            style: GoogleFonts.inter(fontSize: 14, color: AppColors.charcoal),
                            decoration: InputDecoration(
                              hintText: 'Ex: Iogurte Natural, Rúcula, Aveia',
                              hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.softGray),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Buscar na API Open Food Facts',
                          icon: const Icon(Icons.public, color: AppColors.forestGreen, size: 20),
                          onPressed: _openApiSearch,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ideias rápidas ou base externa:',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.subHeader),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickChip('🌐 Buscar na API (Open Food Facts)', _openApiSearch),
                        _buildQuickChip('+ Morangos (5d)', () {
                          _applyQuickSuggestion('Morangos Frescos', FoodCategory.fruits, StorageLocation.refrigerator, FoodUnit.package, 5);
                        }),
                        _buildQuickChip('+ Leite Integral (5d)', () {
                          _applyQuickSuggestion('Leite Integral', FoodCategory.dairy, StorageLocation.refrigerator, FoodUnit.liter, 5);
                        }),
                        _buildQuickChip('+ Ovos (21d)', () {
                          _applyQuickSuggestion('Ovos', FoodCategory.dairy, StorageLocation.refrigerator, FoodUnit.piece, 21);
                        }),
                        _buildQuickChip('+ Pão de Forma (7d)', () {
                          _applyQuickSuggestion('Pão de Forma', FoodCategory.bakery, StorageLocation.pantry, FoodUnit.package, 7);
                        }),
                        _buildQuickChip('+ Iogurte (12d)', () {
                          _applyQuickSuggestion('Iogurte Natural', FoodCategory.dairy, StorageLocation.refrigerator, FoodUnit.piece, 12);
                        }),
                        _buildQuickChip('+ Queijo Minas (10d)', () {
                          _applyQuickSuggestion('Queijo Minas', FoodCategory.dairy, StorageLocation.refrigerator, FoodUnit.gram, 10);
                        }),
                        _buildQuickChip('+ Frango (3d)', () {
                          _applyQuickSuggestion('Peito de Frango', FoodCategory.meatFish, StorageLocation.refrigerator, FoodUnit.kilogram, 3);
                        }),
                        _buildQuickChip('+ Espinafre (4d)', () {
                          _applyQuickSuggestion('Espinafre Fresco', FoodCategory.vegetables, StorageLocation.refrigerator, FoodUnit.piece, 4);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Seção 2: Categoria (6 Grid Buttons)
            Container(
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
                      Text(
                        'Categoria',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                      Text(
                        _category.displayName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.15,
                    children: [
                      _buildCategoryTile(FoodCategory.fruits, 'Hortifrúti', Icons.eco),
                      _buildCategoryTile(FoodCategory.dairy, 'Laticínios', Icons.egg_outlined),
                      _buildCategoryTile(FoodCategory.pantryStaples, 'Grãos', Icons.grain),
                      _buildCategoryTile(FoodCategory.meatFish, 'Proteínas', Icons.set_meal_rounded),
                      _buildCategoryTile(FoodCategory.drinks, 'Bebidas', Icons.local_cafe_outlined),
                      _buildCategoryTile(FoodCategory.other, 'Outros', Icons.category_outlined),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Seção 3: Armazenamento (3 Grid Buttons)
            Container(
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Local de armazenamento',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildStorageTile(StorageLocation.refrigerator, 'Geladeira', Icons.ac_unit)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildStorageTile(StorageLocation.pantry, 'Despensa', Icons.shelves)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildStorageTile(StorageLocation.freezer, 'Freezer', Icons.severe_cold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Seção 4: Quantidade e Unidade
            Container(
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quantidade e volume',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Stepper
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: () {
                                  final isFractional = _unit == FoodUnit.kilogram || _unit == FoodUnit.liter;
                                  final step = (isFractional && _quantity <= 1.0) ? 0.25 : 1.0;
                                  if (_quantity - step >= 0.1) {
                                    setState(() => _quantity = double.parse((_quantity - step).toStringAsFixed(2)));
                                  }
                                },
                              ),
                              Text(
                                FoodUnit.formatQuantity(_quantity),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.charcoal,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: () {
                                  final isFractional = _unit == FoodUnit.kilogram || _unit == FoodUnit.liter;
                                  final step = (isFractional && _quantity < 1.0) ? 0.25 : 1.0;
                                  setState(() => _quantity = double.parse((_quantity + step).toStringAsFixed(2)));
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Unit selector
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<FoodUnit>(
                              value: _unit,
                              isExpanded: true,
                              icon: const Icon(Icons.expand_more, size: 18, color: AppColors.subHeader),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.charcoal,
                              ),
                              items: FoodUnit.values.map((u) {
                                return DropdownMenuItem(
                                  value: u,
                                  child: Text(u.shortSymbol),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _unit = val);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Preço de compra (opcional)',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.subHeader,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Text(
                          'R\$',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.subHeader,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: GoogleFonts.inter(fontSize: 14, color: AppColors.charcoal),
                            decoration: InputDecoration(
                              hintText: '0,00',
                              hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.softGray),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
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

            // Seção 5: Validade com Atalhos Inteligentes
            Container(
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
                      Text(
                        'Data de validade',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                      Text(
                        expiryFeedbackText,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Date Picker Tap Field
                  InkWell(
                    onTap: _noExpiry ? null : _pickDate,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: AppColors.subHeader),
                          const SizedBox(width: 10),
                          Text(
                            _expiryDate != null && !_noExpiry
                                ? DateFormat('dd/MM/yyyy').format(_expiryDate!)
                                : 'Selecionar data',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: _noExpiry ? AppColors.softGray : AppColors.charcoal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Atalhos em Pills
                  if (!_noExpiry) ...[
                    Text(
                      'Atalhos rápidos de consumo:',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.subHeader),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildShortcutPill('3 dias', 3),
                        const SizedBox(width: 6),
                        _buildShortcutPill('7 dias', 7),
                        const SizedBox(width: 6),
                        _buildShortcutPill('15 dias', 15),
                        const SizedBox(width: 6),
                        _buildShortcutPill('1 mês', 30),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Toggle Sem Validade
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Não possui validade exata',
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.subHeader),
                      ),
                      Switch(
                        value: _noExpiry,
                        activeThumbColor: AppColors.forestGreen,
                        onChanged: (val) {
                          setState(() {
                            _noExpiry = val;
                            if (val) _selectedShortcutDays = null;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Seção 6: Observações Opcionais
            Container(
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
                      Text(
                        'Notas & Lembretes',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal,
                        ),
                      ),
                      Text(
                        'Opcional',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.softGray),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.charcoal),
                    decoration: InputDecoration(
                      hintText: 'Ex: Consumir a embalagem aberta primeiro, comprado na feira.',
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.softGray),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Micro-dica Valora
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, size: 20, color: Color(0xFF424927)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Dica Valora: Alimentos registrados com validade reduzem o risco de desperdício em até 80%.',
                      style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: AppColors.charcoal),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botão Principal de Submissão
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveFood,
                icon: const Icon(Icons.check_circle, size: 20, color: Colors.white),
                label: Text(
                  'Salvar alimento',
                  style: GoogleFonts.inter(
                    fontSize: 15,
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
            const SizedBox(height: 6),
            Center(
              child: Text(
                'O item será sincronizado instantaneamente com o painel de Validades.',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.softGray),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.charcoal),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTile(FoodCategory cat, String label, IconData icon) {
    final isSel = _category == cat;
    return InkWell(
      onTap: () => setState(() => _category = cat),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isSel ? AppColors.forestGreen : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: isSel ? Colors.white : AppColors.subHeader),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                color: isSel ? Colors.white : AppColors.charcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageTile(StorageLocation loc, String label, IconData icon) {
    final isSel = _storageLocation == loc;
    return InkWell(
      onTap: () => setState(() => _storageLocation = loc),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: isSel ? AppColors.forestGreen : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSel ? Colors.white : AppColors.subHeader),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                color: isSel ? Colors.white : AppColors.charcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutPill(String label, int days) {
    final isSel = _selectedShortcutDays == days;
    return Expanded(
      child: InkWell(
        onTap: () => _applyShortcut(days),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFFD0EAC9) : AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
              color: isSel ? AppColors.forestGreen : AppColors.charcoal,
            ),
          ),
        ),
      ),
    );
  }
}
