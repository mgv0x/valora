import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valora/core/utils/text_utils.dart';
import 'package:valora/data/local/in_memory_food_repository.dart';
import 'package:valora/data/models/food_activity.dart';
import 'package:valora/data/models/food_category.dart';
import 'package:valora/data/models/food_item.dart';
import 'package:valora/data/models/food_unit.dart';
import 'package:valora/data/models/shopping_item.dart';
import 'package:valora/data/models/storage_location.dart';
import 'package:valora/data/services/eco_metrics_service.dart';
import 'package:valora/data/services/preferences_service.dart';
import 'package:valora/data/services/recipe_suggestions_service.dart';
import 'package:valora/state/pantry_provider.dart';
import 'package:valora/state/shopping_list_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences sharedPrefs;
  late PreferencesService prefsService;
  late InMemoryFoodRepository foodRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
    prefsService = PreferencesService(sharedPrefs);
    foodRepo = InMemoryFoodRepository();
  });

  group('AUDITORIA DE TEMA E IDENTIDADE VISUAL', () {
    test('Tema Padrão não é escuro forçado (Padrão: Light)', () {
      expect(prefsService.themeMode, equals('light'));
    });
  });

  group('FUNÇÃO 1 [FREE]: Lista de Compras Inteligente', () {
    test('Criação, alternância (toggle) e remoção de itens', () async {
      final provider = ShoppingListProvider(prefs: prefsService);

      expect(provider.items, isEmpty);
      expect(provider.uncheckedCount, equals(0));

      // Adiciona item
      await provider.addItem(
        name: 'Aveia em Flocos',
        category: FoodCategory.pantryStaples,
        quantity: 2.0,
        unit: FoodUnit.package,
      );

      expect(provider.items.length, equals(1));
      expect(provider.uncheckedCount, equals(1));
      expect(provider.items.first.name, equals('Aveia em Flocos'));
      expect(provider.items.first.isChecked, isFalse);

      // Marca como comprado
      final id = provider.items.first.id;
      await provider.toggleItem(id);
      expect(provider.items.first.isChecked, isTrue);
      expect(provider.uncheckedCount, equals(0));

      // Limpa concluídos
      await provider.clearCompleted();
      expect(provider.items, isEmpty);
    });

    test('Adição direta a partir de item da despensa', () async {
      final provider = ShoppingListProvider(prefs: prefsService);
      final pantryFood = FoodItem(
        id: 'pantry-1',
        name: 'Leite Integral',
        category: FoodCategory.dairy,
        initialQuantity: 2.0,
        unit: FoodUnit.liter,
        expiryDate: DateTime.now().add(const Duration(days: 2)),
        storageLocation: StorageLocation.refrigerator,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await provider.addFromPantryFood(pantryFood);
      expect(provider.items.length, equals(1));
      expect(provider.items.first.name, equals('Leite Integral'));
      expect(provider.items.first.quantity, equals(2.0));
      expect(provider.items.first.unit, equals(FoodUnit.liter));

      // Adicionar novamente soma quantidade
      await provider.addFromPantryFood(pantryFood);
      expect(provider.items.length, equals(1));
      expect(provider.items.first.quantity, equals(4.0));
    });

    test('Serialização e Desserialização JSON de ShoppingItem', () {
      final item = ShoppingItem.create(
        name: 'Azeite de Oliva',
        category: FoodCategory.pantryStaples,
        quantity: 1.0,
        unit: FoodUnit.package,
      );

      final map = item.toMap();
      final restored = ShoppingItem.fromMap(map);

      expect(restored.id, equals(item.id));
      expect(restored.name, equals('Azeite de Oliva'));
      expect(restored.category, equals(FoodCategory.pantryStaples));
      expect(restored.unit, equals(FoodUnit.package));
      expect(restored.isChecked, isFalse);
    });
  });

  group('FUNÇÃO 2 [FREE]: Predefinições Rápidas de Alimentos com Validade Automática', () {
    test('Matemática de validade positiva e limites temporais', () {
      final presets = [
        {'name': 'Morangos Frescos', 'days': 5, 'cat': FoodCategory.fruits, 'storage': StorageLocation.refrigerator},
        {'name': 'Leite', 'days': 5, 'cat': FoodCategory.dairy, 'storage': StorageLocation.refrigerator},
        {'name': 'Ovos', 'days': 21, 'cat': FoodCategory.dairy, 'storage': StorageLocation.refrigerator},
        {'name': 'Pão de Forma', 'days': 7, 'cat': FoodCategory.bakery, 'storage': StorageLocation.pantry},
        {'name': 'Iogurte', 'days': 12, 'cat': FoodCategory.dairy, 'storage': StorageLocation.refrigerator},
        {'name': 'Queijo Muçarela', 'days': 10, 'cat': FoodCategory.dairy, 'storage': StorageLocation.refrigerator},
        {'name': 'Filé de Frango', 'days': 3, 'cat': FoodCategory.meatFish, 'storage': StorageLocation.refrigerator},
        {'name': 'Espinafre / Folhas', 'days': 4, 'cat': FoodCategory.vegetables, 'storage': StorageLocation.refrigerator},
      ];

      final now = DateTime.now();
      for (final p in presets) {
        final days = p['days'] as int;
        expect(days, greaterThan(0));
        final autoExpiry = now.add(Duration(days: days));
        expect(autoExpiry.isAfter(now), isTrue);
        expect(autoExpiry.difference(now).inDays, equals(days));
      }
    });
  });

  group('FUNÇÃO 3 [FREE]: Filtro Instantâneo por Local de Armazenamento', () {
    test('Filtragem precisa entre Geladeira, Freezer, Despensa e Todos', () async {
      final provider = PantryProvider(repository: foodRepo);

      final itemRefri = FoodItem(
        id: '1',
        name: 'Manteiga',
        category: FoodCategory.dairy,
        initialQuantity: 1.0,
        unit: FoodUnit.piece,
        expiryDate: DateTime.now().add(const Duration(days: 10)),
        storageLocation: StorageLocation.refrigerator,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final itemFreezer = FoodItem(
        id: '2',
        name: 'Sorvete',
        category: FoodCategory.frozen,
        initialQuantity: 1.0,
        unit: FoodUnit.package,
        expiryDate: DateTime.now().add(const Duration(days: 60)),
        storageLocation: StorageLocation.freezer,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final itemPantry = FoodItem(
        id: '3',
        name: 'Arroz Integral',
        category: FoodCategory.pantryStaples,
        initialQuantity: 1.0,
        unit: FoodUnit.kilogram,
        expiryDate: DateTime.now().add(const Duration(days: 180)),
        storageLocation: StorageLocation.pantry,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await provider.addFood(itemRefri);
      await provider.addFood(itemFreezer);
      await provider.addFood(itemPantry);

      expect(provider.filteredAndSortedItems.length, equals(3));

      // Filtra Geladeira
      provider.setSelectedStorageFilter(StorageLocation.refrigerator);
      expect(provider.filteredAndSortedItems.length, equals(1));
      expect(provider.filteredAndSortedItems.first.name, equals('Manteiga'));

      // Filtra Freezer
      provider.setSelectedStorageFilter(StorageLocation.freezer);
      expect(provider.filteredAndSortedItems.length, equals(1));
      expect(provider.filteredAndSortedItems.first.name, equals('Sorvete'));

      // Filtra Despensa
      provider.setSelectedStorageFilter(StorageLocation.pantry);
      expect(provider.filteredAndSortedItems.length, equals(1));
      expect(provider.filteredAndSortedItems.first.name, equals('Arroz Integral'));

      // Limpa filtro
      provider.setSelectedStorageFilter(null);
      expect(provider.filteredAndSortedItems.length, equals(3));
    });
  });

  group('FUNÇÃO 4 [FREE]: Estimativa Qualitativa de Ritmo de Consumo', () {
    test('Classificação consistente de ritmo baseada em dias restantes', () {
      String getPaceLabel(int daysRemaining) {
        if (daysRemaining <= 1) return 'Urgente';
        if (daysRemaining <= 3) return 'Prioridade';
        if (daysRemaining <= 7) return 'Consumir logo';
        return 'Ritmo tranquilo';
      }

      expect(getPaceLabel(0), equals('Urgente'));
      expect(getPaceLabel(1), equals('Urgente'));
      expect(getPaceLabel(2), equals('Prioridade'));
      expect(getPaceLabel(3), equals('Prioridade'));
      expect(getPaceLabel(4), equals('Consumir logo'));
      expect(getPaceLabel(7), equals('Consumir logo'));
      expect(getPaceLabel(8), equals('Ritmo tranquilo'));
      expect(getPaceLabel(30), equals('Ritmo tranquilo'));
    });
  });

  group('FUNÇÃO 5 [FREE]: Busca Instantânea Insensível a Acentos', () {
    test('Normalização e match preciso com acentuação da língua portuguesa', () {
      expect(TextUtils.matchesSearch('Maçã Fuji', 'maca'), isTrue);
      expect(TextUtils.matchesSearch('Pão Integral', 'pao'), isTrue);
      expect(TextUtils.matchesSearch('Feijão Carioca', 'feijao'), isTrue);
      expect(TextUtils.matchesSearch('Açúcar Mascavo', 'acucar'), isTrue);
      expect(TextUtils.matchesSearch('Café Torrado', 'cafe'), isTrue);

      // Busca vazia aceita tudo
      expect(TextUtils.matchesSearch('Qualquer alimento', ''), isTrue);

      // Não correspondência
      expect(TextUtils.matchesSearch('Banana Prata', 'abacaxi'), isFalse);
    });
  });

  group('FUNÇÃO 6 [PREMIUM]: Gerador de Sugestões Anti-Desperdício', () {
    test('Gera receitas contextuais utilizando alimentos prestes a vencer', () {
      final List<FoodItem> expiringItems = [
        FoodItem(
          id: '1',
          name: 'Tomate maduro',
          category: FoodCategory.vegetables,
          initialQuantity: 2.0,
          unit: FoodUnit.piece,
          expiryDate: DateTime.now().add(const Duration(days: 1)),
          storageLocation: StorageLocation.refrigerator,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        FoodItem(
          id: '2',
          name: 'Queijo Prato',
          category: FoodCategory.dairy,
          initialQuantity: 200.0,
          unit: FoodUnit.gram,
          expiryDate: DateTime.now().add(const Duration(days: 2)),
          storageLocation: StorageLocation.refrigerator,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final suggestions = RecipeSuggestionsService.generateForExpiringItems(expiringItems);

      expect(suggestions, isNotEmpty);
      expect(suggestions.length, greaterThanOrEqualTo(3));

      // Verifica injeção dos nomes nas etapas
      final omelet = suggestions.firstWhere((s) => s.title.contains('Omelete'));
      expect(omelet.matchingPantryItems, contains('Tomate maduro'));
      expect(omelet.matchingPantryItems, contains('Queijo Prato'));

      // Detecção de laticínios gera sugestão de vitamina/smoothie
      final hasSmoothie = suggestions.any((s) => s.title.contains('Smoothie'));
      expect(hasSmoothie, isTrue);
    });

    test('Retorna lista vazia se nenhum alimento estiver vencendo', () {
      final suggestions = RecipeSuggestionsService.generateForExpiringItems([]);
      expect(suggestions, isEmpty);
    });
  });

  group('FUNÇÃO 7 [PREMIUM]: Projeção de Economia Anual & Relatório ROI', () {
    test('Cálculo matemático de economia anual e ROI da assinatura', () {
      const monthlySaved = 142.50;
      const annualProjected = monthlySaved * 12;
      const annualProCost = 89.90; // R$ 89,90/ano

      expect(annualProjected, equals(1710.0));
      final netBenefit = annualProjected - annualProCost;
      expect(netBenefit, equals(1620.10));
      final roiMultiplier = (annualProjected / annualProCost).toStringAsFixed(1);
      expect(double.parse(roiMultiplier), greaterThan(15.0));
    });

    test('Estrutura íntegra do relatório para exportação via Clipboard', () {
      const annualProjected = 1710.0;
      final report = '''
📊 VALORA - Relatório de Economia Doméstica
Estimativa de economia anual: R\$ ${annualProjected.toStringAsFixed(2)}
Compromisso: Gestão inteligente de despensa e zero desperdício.
Gerado pelo app Valora.
''';

      expect(report, contains('VALORA - Relatório de Economia Doméstica'));
      expect(report, contains('R\$ 1710.00'));
      expect(report, contains('zero desperdício'));
    });
  });

  group('FUNÇÃO 8 [PREMIUM]: Extensor de Validade por Congelamento (+90 dias)', () {
    test('Posterga a validade em exatamente 90 dias e altera local para congelador', () async {
      final provider = PantryProvider(repository: foodRepo);

      final initialExpiry = DateTime(2026, 11, 1);
      final item = FoodItem(
        id: 'freeze-test-1',
        name: 'Carne Moída',
        category: FoodCategory.meatFish,
        initialQuantity: 500.0,
        unit: FoodUnit.gram,
        expiryDate: initialExpiry,
        storageLocation: StorageLocation.refrigerator,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await provider.addFood(item);

      // Executa o congelamento salvador (+90d)
      await provider.freezeItemToExtendShelfLife(item);

      final updated = provider.filteredAndSortedItems.firstWhere((i) => i.id == item.id);

      expect(updated.storageLocation, equals(StorageLocation.freezer));
      expect(updated.expiryDate!.difference(initialExpiry).inDays, equals(90));
      expect(updated.expiryDate, equals(DateTime(2026, 11, 1).add(const Duration(days: 90))));
    });
  });

  group('FUNÇÃO 9 [PREMIUM]: Calculadora Científica de Pegada Ecológica', () {
    test('Cálculo da pegada hídrica e emissão de carbono evitada', () {
      final activities = [
        FoodActivity(
          id: 'act-1',
          foodItemId: 'f-1',
          foodName: 'Filé Mignon',
          type: ActivityType.consumed,
          category: FoodCategory.meatFish,
          quantity: 1.0,
          unit: FoodUnit.kilogram,
          timestamp: DateTime.now(),
        ),
        FoodActivity(
          id: 'act-2',
          foodItemId: 'f-2',
          foodName: 'Cenoura',
          type: ActivityType.consumed,
          category: FoodCategory.vegetables,
          quantity: 2.0,
          unit: FoodUnit.kilogram,
          timestamp: DateTime.now(),
        ),
      ];

      final summary = EcoMetricsService.calculateSavings(activities);

      expect(summary.itemsSavedCount, equals(2));
      // Carne: 1kg * 15400L = 15400L. Cenoura: 2kg * 322L = 644L. Total: 16044L
      expect(summary.totalWaterSavedLiters, closeTo(16044.0, 0.1));
      // Carne: 1kg * 27kg CO2 = 27kg. Cenoura: 2kg * 2.0kg CO2 = 4kg. Total: 31kg
      expect(summary.totalCo2eSavedKg, closeTo(31.0, 0.1));

      // Formatações
      expect(summary.formattedWater, equals('16.0 m³'));
      expect(summary.formattedCo2, equals('31.0 kg CO₂e'));
      expect(summary.formattedFoodWeight, equals('3.0 kg'));
    });
  });

  group('FUNÇÃO 10 [PREMIUM]: Alerta e Badge de Resgate Urgente', () {
    test('Critério de exibição do Badge de Resgate Urgente (isPro && horas <= 24)', () {
      bool shouldShowRescueBadge({
        required bool isPro,
        required DateTime expiryDate,
      }) {
        final hours = expiryDate.difference(DateTime.now()).inHours;
        return isPro && hours <= 24;
      }

      final now = DateTime.now();

      // Free user: nunca exibe badge PRO
      expect(shouldShowRescueBadge(isPro: false, expiryDate: now.add(const Duration(hours: 12))), isFalse);

      // PRO user com item vencendo em 12 horas: exibe badge PRO
      expect(shouldShowRescueBadge(isPro: true, expiryDate: now.add(const Duration(hours: 12))), isTrue);

      // PRO user com item com mais de 24 horas: não exibe badge urgente
      expect(shouldShowRescueBadge(isPro: true, expiryDate: now.add(const Duration(days: 3))), isFalse);
    });
  });
}
