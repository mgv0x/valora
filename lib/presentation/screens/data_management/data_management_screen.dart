import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../data/local/food_repository.dart';
import '../../../data/models/food_item.dart';
import '../../../data/services/cloud_sync_service.dart';
import '../../../data/services/open_food_facts_service.dart';
import '../../../state/impact_provider.dart';
import '../../../state/pantry_provider.dart';
import '../../../state/settings_provider.dart';
import '../../../state/shopping_list_provider.dart';
import '../food_form/add_edit_food_screen.dart';

class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  final _apiService = OpenFoodFactsApiService();
  final _apiSearchController = TextEditingController();

  bool _isOptimizing = false;
  bool _isSyncingCloud = false;
  bool _isSearchingApi = false;
  bool? _apiIsOnline;

  List<OpenFoodProduct> _apiSearchResults = [];
  Map<String, dynamic>? _storageStats;

  @override
  void initState() {
    super.initState();
    _loadStorageStats();
    _checkApiHealth();
  }

  @override
  void dispose() {
    _apiSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadStorageStats() async {
    final repo = context.read<FoodRepository>();
    final stats = await repo.getStorageDiagnostics();
    if (mounted) {
      setState(() => _storageStats = stats);
    }
  }

  Future<void> _checkApiHealth() async {
    final isOnline = await _apiService.checkHealth();
    if (mounted) {
      setState(() => _apiIsOnline = isOnline);
    }
  }

  Future<void> _optimizeDatabase() async {
    setState(() => _isOptimizing = true);
    final repo = context.read<FoodRepository>();
    await repo.optimizeStorage();
    await Future.delayed(const Duration(milliseconds: 600));
    await _loadStorageStats();
    if (mounted) {
      setState(() => _isOptimizing = false);
      UiFeedback.showSuccess(context, 'Banco SQLite otimizado (VACUUM & Índices revalidados)!');
    }
  }

  Future<void> _exportBackup(BuildContext context) async {
    final repo = context.read<FoodRepository>();
    final data = await repo.exportData();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    await Clipboard.setData(ClipboardData(text: jsonString));

    if (context.mounted) {
      UiFeedback.showSuccess(context, 'Backup JSON copiado para a área de transferência!');
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final textController = TextEditingController();
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            'Importar Backup JSON',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cole abaixo o conteúdo JSON do backup para restaurar a despensa e o histórico com integridade ACID:',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.subHeader),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: '{\n  "app": "Valora",\n  "food_items": [...]\n}',
                  hintStyle: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppColors.softGray),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                style: GoogleFonts.jetBrainsMono(fontSize: 11),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Restaurar'),
            ),
          ],
        ),
      );

      if (confirmed == true && textController.text.trim().isNotEmpty && context.mounted) {
        final rawText = textController.text.trim();
        try {
          final decoded = jsonDecode(rawText);
          if (decoded is! Map<String, dynamic>) {
            UiFeedback.showError(context, 'O backup deve ser um objeto JSON válido.');
            return;
          }
          final repo = context.read<FoodRepository>();
          final pantry = context.read<PantryProvider>();
          final impact = context.read<ImpactProvider>();
          final success = await repo.importData(decoded);
          if (success) {
            await pantry.loadItems();
            await impact.loadActivities();
            await _loadStorageStats();
            if (context.mounted) {
              UiFeedback.showSuccess(context, 'Dados restaurados com sucesso no banco de dados!');
            }
          } else {
            if (context.mounted) {
              UiFeedback.showError(context, 'Incompatibilidade de dados ou arquivo corrompido.');
            }
          }
        } catch (_) {
          if (context.mounted) {
            UiFeedback.showError(context, 'JSON inválido ou corrompido.');
          }
        }
      }
    } finally {
      textController.dispose();
    }
  }

  Future<void> _performCloudSync() async {
    setState(() => _isSyncingCloud = true);
    final repo = context.read<FoodRepository>();
    final prefs = context.read<SettingsProvider>().prefs;
    final cloudService = CloudSyncService(repository: repo, preferences: prefs);

    final result = await cloudService.syncToCloud();
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() => _isSyncingCloud = false);
      if (result.success) {
        UiFeedback.showSuccess(
          context,
          'Nuvem sincronizada! ${result.syncedItemsCount} alimentos e ${result.syncedActivitiesCount} registros salvos.',
        );
      } else {
        UiFeedback.showError(context, result.message);
      }
    }
  }

  Future<void> _performCloudRestore() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Restaurar da Nuvem?',
      content: 'Esta ação substituirá o estado local pelo último snapshot salvo no banco em nuvem.',
      confirmLabel: 'Restaurar da Nuvem',
      cancelLabel: 'Cancelar',
    );

    if (!confirmed || !mounted) return;

    setState(() => _isSyncingCloud = true);
    final repo = context.read<FoodRepository>();
    final prefs = context.read<SettingsProvider>().prefs;
    final pantry = context.read<PantryProvider>();
    final impact = context.read<ImpactProvider>();
    final cloudService = CloudSyncService(repository: repo, preferences: prefs);

    final result = await cloudService.restoreFromCloud();
    if (result.success) {
      await pantry.loadItems();
      await impact.loadActivities();
      await _loadStorageStats();
    }

    if (mounted) {
      setState(() => _isSyncingCloud = false);
      if (result.success) {
        UiFeedback.showSuccess(context, 'Banco local restaurado da nuvem com sucesso!');
      } else {
        UiFeedback.showError(context, result.message);
      }
    }
  }

  Future<void> _searchApi(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    setState(() => _isSearchingApi = true);
    final results = await _apiService.searchProducts(trimmed, limit: 8);
    if (mounted) {
      setState(() {
        _apiSearchResults = results;
        _isSearchingApi = false;
      });
    }
  }

  void _addApiProductToPantry(OpenFoodProduct product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditFoodScreen(
          initialItem: FoodItem(
            id: '',
            name: product.name,
            category: product.category,
            initialQuantity: 1.0,
            unit: product.unit,
            storageLocation: product.suggestedStorage,
            expiryDate: DateTime.now().add(Duration(days: product.suggestedShelfLifeDays)),
            notes: product.brand != null ? 'Marca: ${product.brand}' : null,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pantry = context.watch<PantryProvider>();
    final impact = context.watch<ImpactProvider>();
    final shopping = context.watch<ShoppingListProvider>();
    final settings = context.watch<SettingsProvider>();

    final lastSync = settings.prefs.lastCloudSyncTime;
    final lastSyncText = lastSync != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(lastSync)
        : 'Ainda não sincronizado';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Gerenciamento de Dados',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        children: [
          // Introdução
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF264E36), Color(0xFF1B3B2B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storage_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Arquitetura de Dados Híbrida',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Armazenamento local SQLite com integridade ACID, nuvem conectada e consumo de APIs públicas.',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ==========================================
          // 1. ARMAZENAMENTO LOCAL (LOCAL STORAGE / SQLITE)
          // ==========================================
          _buildSectionHeader('1. ARMAZENAMENTO LOCAL (SQLITE & ACID)', Icons.storage),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.softWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Banco de Dados Relacional',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.charcoal,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ACID Ativo',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Alimentos Ativos',
                        value: '${pantry.items.length}',
                        icon: Icons.inventory_2_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Atividades (Audit)',
                        value: '${impact.activities.length}',
                        icon: Icons.history_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricTile(
                        label: 'Lista de Compras',
                        value: '${shopping.items.length}',
                        icon: Icons.shopping_bag_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.surfaceContainerLow),
                const SizedBox(height: 12),
                _buildInfoLine('Mecanismo:', _storageStats?['engine']?.toString() ?? 'SQLite Relational (sqflite)'),
                _buildInfoLine('Nome do Arquivo:', _storageStats?['database_name']?.toString() ?? 'valora_inventory.db'),
                _buildInfoLine('Integridade Referencial:', 'Chaves estrangeiras com CASCADE ativadas'),
                _buildInfoLine('Índices de Performance:', 'idx_status, idx_timestamp, idx_food_id'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.forestGreen,
                          side: const BorderSide(color: AppColors.forestGreen),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: _isOptimizing ? null : _optimizeDatabase,
                        icon: _isOptimizing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.tune, size: 16),
                        label: Text(_isOptimizing ? 'Otimizando...' : 'Otimizar Banco'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.charcoal,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () => _exportBackup(context),
                        icon: const Icon(Icons.file_download_outlined, size: 16),
                        label: const Text('Exportar JSON'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.subHeader,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _importBackup(context),
                    icon: const Icon(Icons.file_upload_outlined, size: 16),
                    label: const Text('Importar / Restaurar Backup JSON'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ==========================================
          // 2. BANCO EM NUVEM & SINCRONIZAÇÃO (CLOUD DATABASE)
          // ==========================================
          _buildSectionHeader('2. BANCO EM NUVEM & SINCRONIZAÇÃO', Icons.cloud_done_rounded),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.softWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sincronização em Nuvem (Cloud Sync)',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.charcoal,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Firebase / Cloud',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1976D2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoLine('Conta Conectada:', settings.userEmail.isNotEmpty ? settings.userEmail : 'Modo Convidado'),
                _buildInfoLine('Última Sincronização:', lastSyncText),
                _buildInfoLine('Modo Offline:', 'Fallback automático e sincronização pendente segura'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.forestGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _isSyncingCloud ? null : _performCloudSync,
                        icon: _isSyncingCloud
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.sync_rounded, size: 18),
                        label: Text(_isSyncingCloud ? 'Sincronizando...' : 'Sincronizar com Nuvem'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.subHeader,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _isSyncingCloud ? null : _performCloudRestore,
                        child: const Text('Restaurar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ==========================================
          // 3. APIS E SERVIÇOS EXTERNOS (REST APIS)
          // ==========================================
          _buildSectionHeader('3. APIS E SERVIÇOS CONECTADOS', Icons.api_rounded),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.softWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Open Food Facts REST API',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.charcoal,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _apiIsOnline == true
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _apiIsOnline == true ? Colors.green : Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _apiIsOnline == true ? 'API Online' : 'Conectando...',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _apiIsOnline == true
                                  ? AppColors.forestGreen
                                  : Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Acesso a mais de 3 milhões de produtos alimentícios com preenchimento automático de categoria, unidade e prazos de validade recomendados.',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.subHeader, height: 1.3),
                ),
                const SizedBox(height: 14),

                // Campo de Teste / Consulta ao Vivo da API
                TextField(
                  controller: _apiSearchController,
                  onSubmitted: _searchApi,
                  decoration: InputDecoration(
                    hintText: 'Digite um alimento para testar a API (ex: leite, banana, arroz)...',
                    hintStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.softGray),
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.subHeader),
                    suffixIcon: IconButton(
                      icon: _isSearchingApi
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.arrow_forward_rounded, color: AppColors.forestGreen),
                      onPressed: () => _searchApi(_apiSearchController.text),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                if (_apiSearchResults.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Resultados Retornados da API (${_apiSearchResults.length}):',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _apiSearchResults.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.surfaceContainerLow),
                    itemBuilder: (ctx, i) {
                      final item = _apiSearchResults[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.surfaceContainerLow,
                          child: Icon(item.category.icon, size: 18, color: AppColors.forestGreen),
                        ),
                        title: Text(
                          item.displayName,
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'Categoria: ${item.category.displayName} • Sugestão: ${item.suggestedShelfLifeDays} dias',
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.subHeader),
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.forestGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _addApiProductToPantry(item),
                          child: const Text('Cadastrar'),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.forestGreen),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: AppColors.subHeader,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({required String label, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.forestGreen),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.subHeader,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.charcoal),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.subHeader),
            ),
          ),
        ],
      ),
    );
  }
}
