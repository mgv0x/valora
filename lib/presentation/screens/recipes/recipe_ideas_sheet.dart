import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/food_item.dart';
import '../../../data/services/recipe_suggestions_service.dart';
import '../../../state/subscription_provider.dart';
import '../subscription/subscription_screen.dart';

class RecipeIdeasSheet extends StatelessWidget {
  final List<FoodItem> expiringItems;

  const RecipeIdeasSheet({super.key, required this.expiringItems});

  static Future<void> show(BuildContext context, List<FoodItem> expiringItems) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecipeIdeasSheet(expiringItems: expiringItems),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<SubscriptionProvider>();
    final isPremium = subscription.hasActiveAccess;
    final suggestions = RecipeSuggestionsService.generateForExpiringItems(expiringItems);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
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
                        color: const Color(0xFFD97706).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.restaurant_menu_rounded,
                          color: Color(0xFFD97706), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Ideias Anti-Desperdício',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.charcoal,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD97706),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'PREMIUM',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Aproveite o que está vencendo hoje',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.subHeader,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.softGray),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          // Content
          Expanded(
            child: suggestions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 48, color: AppColors.forestGreen),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhum item vencendo em breve!',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.charcoal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sua despensa está em dia. Quando houver alimentos próximos da validade, sugestões culinárias aparecerão aqui.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.subHeader),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: suggestions.length,
                    itemBuilder: (ctx, idx) {
                      final item = suggestions[idx];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.forestGreen,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.timer_outlined,
                                          size: 14, color: AppColors.subHeader),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.prepTime,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.subHeader,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.description,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.charcoal,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: item.matchingPantryItems.map((name) {
                                return Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEBF2E9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check, size: 12, color: AppColors.forestGreen),
                                      const SizedBox(width: 4),
                                      Text(
                                        name,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.forestGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Passo a passo rápido:',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.charcoal,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (!isPremium && idx > 0)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.lock_outline, size: 16, color: Color(0xFFD97706)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Desbloqueie o Valora Premium para ver todas as receitas e passos detalhados.',
                                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.charcoal),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => const SubscriptionScreen(),
                                          ),
                                        );
                                      },
                                      child: const Text('Ver Planos'),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ...item.suggestedPantrySteps.map((step) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('• ',
                                            style: TextStyle(
                                                color: AppColors.forestGreen,
                                                fontWeight: FontWeight.bold)),
                                        Expanded(
                                          child: Text(
                                            step,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: AppColors.subHeader,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                          ],
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
