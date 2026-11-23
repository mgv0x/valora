import '../models/food_item.dart';

class RecipeSuggestion {
  final String title;
  final String description;
  final String prepTime;
  final String difficulty;
  final List<String> matchingPantryItems;
  final List<String> suggestedPantrySteps;

  const RecipeSuggestion({
    required this.title,
    required this.description,
    required this.prepTime,
    required this.difficulty,
    required this.matchingPantryItems,
    required this.suggestedPantrySteps,
  });
}

class RecipeSuggestionsService {
  static List<RecipeSuggestion> generateForExpiringItems(List<FoodItem> expiringItems) {
    if (expiringItems.isEmpty) return [];

    final suggestions = <RecipeSuggestion>[];
    final names = expiringItems.map((e) => e.name).toList();

    // 1. Omelete / Frittata de Sobras (Combina com quase tudo)
    suggestions.add(
      RecipeSuggestion(
        title: 'Omelete Rápido Nutritivo',
        description: 'Ideal para aproveitar rapidamente legumes, queijos e proteínas antes que vençam.',
        prepTime: '10 min',
        difficulty: 'Fácil',
        matchingPantryItems: names.take(3).toList(),
        suggestedPantrySteps: [
          'Bata 2 a 3 ovos com uma pitada de sal e pimenta.',
          'Pique ${names.take(2).join(' e ')} em cubos pequenos e refogue levemente.',
          'Despeje os ovos batidos sobre os ingredientes e doure dos dois lados.',
        ],
      ),
    );

    // 2. Torta de Liquidificador Salgada
    suggestions.add(
      RecipeSuggestion(
        title: 'Torta Salgada de Liquidificador',
        description: 'A receita mais famosa para salvar múltiplos itens da despensa de uma só vez.',
        prepTime: '35 min',
        difficulty: 'Médio',
        matchingPantryItems: names.take(4).toList(),
        suggestedPantrySteps: [
          'Bata no liquidificador: 3 ovos, 2 xícaras de leite, 1/2 xícara de óleo e 2 xícaras de farinha com fermento.',
          'Pique ${names.join(', ')} e tempere a gosto para o recheio.',
          'Disponha a massa em uma assadeira untada, cubra com o recheio e asse a 180°C por 30 minutos.',
        ],
      ),
    );

    // 3. Sopa Creme ou Refogado Express
    suggestions.add(
      RecipeSuggestion(
        title: 'Sopa Creme Reconfortante',
        description: 'Perfeita para legumes, tubérculos e hortaliças que estão perto da maturação máxima.',
        prepTime: '20 min',
        difficulty: 'Fácil',
        matchingPantryItems: names.take(3).toList(),
        suggestedPantrySteps: [
          'Cozinhe ${names.take(3).join(', ')} em caldo de legumes com cebola e alho.',
          'Bata com mixer ou liquidificador até obter consistência cremosa aveludada.',
          'Finalize com azeite de oliva e torradas de pão da despensa.',
        ],
      ),
    );

    // 4. Smoothie Anti-Desperdício (Se houver frutas ou laticínios)
    final hasFruitOrDairy = expiringItems.any((e) =>
        e.category.name == 'fruits' ||
        e.category.name == 'dairy' ||
        e.category.name == 'drinks');
    if (hasFruitOrDairy) {
      suggestions.add(
        RecipeSuggestion(
          title: 'Smoothie Vitamina Anti-Desperdício',
          description: 'Aproveitamento perfeito para frutas maduras, leite ou iogurtes.',
          prepTime: '5 min',
          difficulty: 'Super Fácil',
          matchingPantryItems: names.where((n) => n.isNotEmpty).take(2).toList(),
          suggestedPantrySteps: [
            'Corte as frutas maduras em pedaços e junte no liquidificador.',
            'Adicione 200ml de leite, iogurte ou água gelada com cubos de gelo.',
            'Bata por 1 minuto e sirva imediatamente sem necessidade de adoçar.',
          ],
        ),
      );
    }

    return suggestions;
  }
}
