import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/services/open_food_facts_service.dart';

class ApiFoodSearchSheet extends StatefulWidget {
  const ApiFoodSearchSheet({super.key});

  static Future<OpenFoodProduct?> show(BuildContext context) {
    return showModalBottomSheet<OpenFoodProduct>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ApiFoodSearchSheet(),
    );
  }

  @override
  State<ApiFoodSearchSheet> createState() => _ApiFoodSearchSheetState();
}

class _ApiFoodSearchSheetState extends State<ApiFoodSearchSheet> {
  final _searchController = TextEditingController();
  final _apiService = OpenFoodFactsApiService();

  bool _isLoading = false;
  List<OpenFoodProduct> _results = [];
  String? _errorMessage;

  final List<String> _quickTags = [
    'Leite',
    'Arroz',
    'Feijão',
    'Iogurte',
    'Banana',
    'Maçã',
    'Pão de Forma',
    'Peito de Frango',
  ];

  @override
  void initState() {
    super.initState();
    _performSearch('Leite');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _apiService.searchProducts(trimmed, limit: 12);
      if (mounted) {
        setState(() {
          _results = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Falha ao buscar alimentos na API.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      color: isDark ? AppColors.darkSurface : Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.public, color: AppColors.forestGreen, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Base Global Open Food Facts API',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.charcoal,
                      ),
                    ),
                    Text(
                      'Busque qualquer alimento para autocompletar',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.subHeader),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Search Field
          TextField(
            controller: _searchController,
            autofocus: false,
            onSubmitted: _performSearch,
            decoration: InputDecoration(
              hintText: 'Pesquise pelo nome ou marca do alimento...',
              hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.softGray),
              prefixIcon: const Icon(Icons.search, color: AppColors.subHeader),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.forestGreen),
                onPressed: () => _performSearch(_searchController.text),
              ),
              filled: true,
              fillColor: isDark ? AppColors.surfaceContainerLow : const Color(0xFFF4F6F4),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Quick Filter Tags
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _quickTags.map((tag) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(tag, style: GoogleFonts.inter(fontSize: 11)),
                    backgroundColor: isDark ? AppColors.surfaceContainerLow : const Color(0xFFF1F4F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: BorderSide.none,
                    onPressed: () {
                      _searchController.text = tag;
                      _performSearch(tag);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Results list or loader
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? Center(
                        child: Text(
                          _errorMessage ?? 'Nenhum alimento encontrado para essa busca.',
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.subHeader),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, _) =>
                            const Divider(height: 1, color: AppColors.surfaceContainerLow),
                        itemBuilder: (ctx, i) {
                          final item = _results[i];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 4),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.forestGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(item.category.icon, color: AppColors.forestGreen, size: 22),
                            ),
                            title: Text(
                              item.displayName,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppColors.charcoal,
                              ),
                            ),
                            subtitle: Text(
                              '${item.category.displayName} • Sugestão de validade: ${item.suggestedShelfLifeDays} dias',
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.subHeader),
                            ),
                            trailing: const Icon(Icons.add_circle_outline, color: AppColors.forestGreen),
                            onTap: () => Navigator.pop(context, item),
                          );
                        },
                      ),
          ),
        ],
      ),
    ),);
  }
}
