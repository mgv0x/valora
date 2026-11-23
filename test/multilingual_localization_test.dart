import 'package:flutter_test/flutter_test.dart';
import 'package:valora/l10n/generated/app_localizations.dart';
import 'package:valora/l10n/generated/app_localizations_ar.dart';
import 'package:valora/l10n/generated/app_localizations_de.dart';
import 'package:valora/l10n/generated/app_localizations_en.dart';
import 'package:valora/l10n/generated/app_localizations_es.dart';
import 'package:valora/l10n/generated/app_localizations_fr.dart';
import 'package:valora/l10n/generated/app_localizations_hi.dart';
import 'package:valora/l10n/generated/app_localizations_it.dart';
import 'package:valora/l10n/generated/app_localizations_ja.dart';
import 'package:valora/l10n/generated/app_localizations_pt.dart';
import 'package:valora/l10n/generated/app_localizations_ru.dart';
import 'package:valora/l10n/generated/app_localizations_zh.dart';
import 'package:valora/data/services/preferences_service.dart';
import 'package:valora/data/services/notification_service.dart';
import 'package:valora/state/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Valora Multilingual Localization - 11 Global Languages', () {
    test('Supported locales list contains all 11 global languages', () {
      final supportedCodes = AppLocalizations.supportedLocales
          .map((loc) => loc.languageCode)
          .toSet();

      final expectedLanguages = {
        'en', // English
        'pt', // Portuguese
        'es', // Spanish
        'fr', // French
        'de', // German
        'it', // Italian
        'zh', // Chinese Simplified
        'ja', // Japanese
        'ru', // Russian
        'ar', // Arabic
        'hi', // Hindi
      };

      for (final code in expectedLanguages) {
        expect(
          supportedCodes.contains(code),
          isTrue,
          reason: 'Language code $code must be supported in AppLocalizations',
        );
      }
    });

    test('English (en) translation verifies correct words and plural forms', () {
      final l10n = AppLocalizationsEn();
      expect(l10n.appName, 'Valora');
      expect(l10n.tagline, 'Waste less. Live better.');
      expect(l10n.pantryTitle, 'Pantry');
      expect(l10n.expiryCenterTitle, 'Expiry Center');
      expect(l10n.impactTitle, 'My Impact');
      expect(l10n.addFood, 'Add Food');
      expect(l10n.consume, 'Consume');
      expect(l10n.discard, 'Discard');
      expect(l10n.activeItemsCount(0), 'No active items');
      expect(l10n.activeItemsCount(1), '1 active item');
      expect(l10n.activeItemsCount(5), '5 active items');
      expect(l10n.daysLeft(0), 'Expires today');
      expect(l10n.daysLeft(1), '1 day left');
      expect(l10n.daysLeft(3), '3 days left');
    });

    test('Português (pt) translation verifies correct words and plural forms', () {
      final l10n = AppLocalizationsPt();
      expect(l10n.appName, 'Valora');
      expect(l10n.pantryTitle, 'Despensa');
      expect(l10n.expiryCenterTitle, 'Validades');
      expect(l10n.impactTitle, 'Meu Impacto');
      expect(l10n.addFood, 'Adicionar Alimento');
      expect(l10n.consume, 'Consumir');
      expect(l10n.discard, 'Descartar');
      expect(l10n.activeItemsCount(0), 'Nenhum alimento ativo');
      expect(l10n.activeItemsCount(1), '1 alimento ativo');
      expect(l10n.activeItemsCount(4), '4 alimentos ativos');
      expect(l10n.daysLeft(0), 'Vence hoje');
      expect(l10n.daysLeft(1), 'Falta 1 dia');
      expect(l10n.daysLeft(5), 'Faltam 5 dias');
    });

    test('Español (es) translation verifies correct words and plural forms', () {
      final l10n = AppLocalizationsEs();
      expect(l10n.appName, 'Valora');
      expect(l10n.tagline, 'Desperdicia menos. Vive mejor.');
      expect(l10n.pantryTitle, 'Despensa');
      expect(l10n.expiryCenterTitle, 'Caducidad');
      expect(l10n.impactTitle, 'Mi Impacto');
      expect(l10n.addFood, 'Añadir Alimento');
      expect(l10n.consume, 'Consumir');
      expect(l10n.discard, 'Desechar');
      expect(l10n.activeItemsCount(0), 'Sin alimentos activos');
      expect(l10n.activeItemsCount(1), '1 alimento activo');
      expect(l10n.activeItemsCount(3), '3 alimentos activos');
      expect(l10n.daysLeft(0), 'Caduca hoy');
      expect(l10n.daysLeft(1), 'Queda 1 día');
      expect(l10n.daysLeft(4), 'Quedan 4 días');
    });

    test('Français (fr) translation verifies correct words and plural forms', () {
      final l10n = AppLocalizationsFr();
      expect(l10n.appName, 'Valora');
      expect(l10n.tagline, 'Gaspillez moins. Vivez mieux.');
      expect(l10n.pantryTitle, 'Garde-manger');
      expect(l10n.expiryCenterTitle, 'Dates limites');
      expect(l10n.impactTitle, 'Mon Impact');
      expect(l10n.addFood, 'Ajouter un aliment');
      expect(l10n.consume, 'Consommer');
      expect(l10n.discard, 'Jeter');
      expect(l10n.activeItemsCount(0), 'Aucun aliment actif');
      expect(l10n.daysLeft(0), "Expire aujourd'hui");
      expect(l10n.daysLeft(1), 'Reste 1 jour');
      expect(l10n.daysLeft(2), 'Reste 2 jours');
    });

    test('Deutsch (de) translation verifies correct words and plural forms', () {
      final l10n = AppLocalizationsDe();
      expect(l10n.appName, 'Valora');
      expect(l10n.tagline, 'Weniger verschwenden. Besser leben.');
      expect(l10n.pantryTitle, 'Vorratskammer');
      expect(l10n.expiryCenterTitle, 'Haltbarkeit');
      expect(l10n.impactTitle, 'Mein Beitrag');
      expect(l10n.addFood, 'Lebensmittel hinzufügen');
      expect(l10n.consume, 'Verbrauchen');
      expect(l10n.discard, 'Entsorgen');
      expect(l10n.activeItemsCount(0), 'Keine aktiven Lebensmittel');
      expect(l10n.activeItemsCount(1), '1 aktives Lebensmittel');
      expect(l10n.activeItemsCount(4), '4 aktive Lebensmittel');
      expect(l10n.daysLeft(0), 'Läuft heute ab');
      expect(l10n.daysLeft(1), 'Noch 1 Tag');
      expect(l10n.daysLeft(3), 'Noch 3 Tage');
    });

    test('Italiano (it) translation verifies correct words and plural forms', () {
      final l10n = AppLocalizationsIt();
      expect(l10n.appName, 'Valora');
      expect(l10n.tagline, 'Spreco zero. Vivere meglio.');
      expect(l10n.pantryTitle, 'Dispensa');
      expect(l10n.expiryCenterTitle, 'Scadenze');
      expect(l10n.impactTitle, 'Il mio Impatto');
      expect(l10n.addFood, 'Aggiungi Alimento');
      expect(l10n.consume, 'Consuma');
      expect(l10n.discard, 'Getta');
      expect(l10n.activeItemsCount(0), 'Nessun alimento attivo');
      expect(l10n.activeItemsCount(1), '1 alimento attivo');
      expect(l10n.activeItemsCount(3), '3 alimenti attivi');
      expect(l10n.daysLeft(0), 'Scade oggi');
      expect(l10n.daysLeft(1), 'Resta 1 giorno');
      expect(l10n.daysLeft(4), 'Restano 4 giorni');
    });

    test('Chinese (zh) translation verifies correct words and plural forms', () {
      final l10n = AppLocalizationsZh();
      expect(l10n.appName, 'Valora');
      expect(l10n.tagline, '减少浪费，美好生活。');
      expect(l10n.pantryTitle, '食品库');
      expect(l10n.expiryCenterTitle, '保质期中心');
      expect(l10n.impactTitle, '成效统计');
      expect(l10n.addFood, '添加食品');
      expect(l10n.consume, '食用');
      expect(l10n.discard, '丢弃');
      expect(l10n.activeItemsCount(0), '暂无在库食品');
      expect(l10n.activeItemsCount(1), '1 件在库食品');
      expect(l10n.activeItemsCount(8), '8 件在库食品');
      expect(l10n.daysLeft(0), '今天到期');
      expect(l10n.daysLeft(1), '还剩 1 天');
      expect(l10n.daysLeft(5), '还剩 5 天');
    });

    test('Japanese (ja) translation verifies correct words and plural forms', () {
      final l10n = AppLocalizationsJa();
      expect(l10n.appName, 'Valora');
      expect(l10n.tagline, '無駄を減らし、もっと豊かに。');
      expect(l10n.pantryTitle, 'パントリー');
      expect(l10n.expiryCenterTitle, '賞味期限センター');
      expect(l10n.impactTitle, '実績・成果');
      expect(l10n.addFood, '食材を追加');
      expect(l10n.consume, '消費する');
      expect(l10n.discard, '廃棄する');
      expect(l10n.activeItemsCount(0), '保管中の食材はありません');
      expect(l10n.activeItemsCount(1), '保管中 1 品');
      expect(l10n.activeItemsCount(6), '保管中 6 品');
      expect(l10n.daysLeft(0), '本日が期限');
      expect(l10n.daysLeft(1), '残り 1 日');
      expect(l10n.daysLeft(4), '残り 4 日');
    });

    test('Russian (ru) translation verifies correct words and plural forms', () {
      final l10n = AppLocalizationsRu();
      expect(l10n.appName, 'Valora');
      expect(l10n.tagline, 'Меньше отходов. Лучше жизнь.');
      expect(l10n.pantryTitle, 'Кладовая');
      expect(l10n.expiryCenterTitle, 'Сроки годности');
      expect(l10n.impactTitle, 'Мой вклад');
      expect(l10n.addFood, 'Добавить продукт');
      expect(l10n.consume, 'Употребить');
      expect(l10n.discard, 'Выбросить');
      expect(l10n.activeItemsCount(0), 'Нет продуктов в запасе');
      expect(l10n.activeItemsCount(1), '1 продукт в запасе');
      expect(l10n.activeItemsCount(2), '2 продукта в запасе');
      expect(l10n.activeItemsCount(5), '5 продуктов в запасе');
      expect(l10n.daysLeft(0), 'Истекает сегодня');
      expect(l10n.daysLeft(1), 'Остался 1 день');
      expect(l10n.daysLeft(3), 'Осталось 3 дня');
      expect(l10n.daysLeft(5), 'Осталось 5 дней');
    });

    test('Arabic (ar) translation verifies correct words and plural forms', () {
      final l10n = AppLocalizationsAr();
      expect(l10n.appName, 'Valora');
      expect(l10n.tagline, 'هدر أقل. حياة أفضل.');
      expect(l10n.pantryTitle, 'المؤونة');
      expect(l10n.expiryCenterTitle, 'مركز الصلاحية');
      expect(l10n.impactTitle, 'أثري وإنجازاتي');
      expect(l10n.addFood, 'إضافة طعام');
      expect(l10n.consume, 'استهلاك');
      expect(l10n.discard, 'إتلاف');
      expect(l10n.activeItemsCount(0), 'لا توجد أطعمة في المؤونة');
      expect(l10n.activeItemsCount(1), 'صنف غذائي واحد');
      expect(l10n.activeItemsCount(2), 'صنفان غذائيان');
      expect(l10n.activeItemsCount(4), '4 أصناف غذائية');
      expect(l10n.activeItemsCount(15), '15 صنفاً غذائياً');
      expect(l10n.daysLeft(0), 'ينتهي اليوم');
      expect(l10n.daysLeft(1), 'متبقي يوم واحد');
      expect(l10n.daysLeft(2), 'متبقي يومان');
      expect(l10n.daysLeft(3), 'متبقي 3 أيام');
    });

    test('Hindi (hi) translation verifies correct words and plural forms', () {
      final l10n = AppLocalizationsHi();
      expect(l10n.appName, 'Valora');
      expect(l10n.tagline, 'कम बर्बादी। बेहतर जीवन।');
      expect(l10n.pantryTitle, 'रसोई भंडार');
      expect(l10n.expiryCenterTitle, 'समाप्ति केंद्र');
      expect(l10n.impactTitle, 'मेरा प्रभाव');
      expect(l10n.addFood, 'खाद्य सामग्री जोड़ें');
      expect(l10n.consume, 'उपभोग करें');
      expect(l10n.discard, 'त्यागें');
      expect(l10n.activeItemsCount(0), 'कोई खाद्य सामग्री नहीं');
      expect(l10n.activeItemsCount(1), '1 उपलब्ध खाद्य सामग्री');
      expect(l10n.activeItemsCount(4), '4 उपलब्ध खाद्य सामग्रियां');
      expect(l10n.daysLeft(0), 'आज समाप्त हो रहा है');
      expect(l10n.daysLeft(1), '1 दिन शेष');
      expect(l10n.daysLeft(5), '5 दिन शेष');
    });

    test('Placeholder interpolation works properly across multiple languages', () {
      final en = AppLocalizationsEn();
      final es = AppLocalizationsEs();
      final fr = AppLocalizationsFr();
      final zh = AppLocalizationsZh();
      final ru = AppLocalizationsRu();
      final ar = AppLocalizationsAr();
      final hi = AppLocalizationsHi();

      expect(en.quantityRemaining('2.5', 'kg'), 'Available: 2.5 kg');
      expect(es.quantityRemaining('2.5', 'kg'), 'Disponible: 2.5 kg');
      expect(fr.quantityRemaining('2.5', 'kg'), 'Disponible : 2.5 kg');
      expect(zh.quantityRemaining('2.5', 'kg'), '剩余：2.5 kg');
      expect(ru.quantityRemaining('2.5', 'кг'), 'Осталось: 2.5 кг');
      expect(ar.quantityRemaining('2.5', 'كغ'), 'المتاح: 2.5 كغ');
      expect(hi.quantityRemaining('2.5', 'किग्रा'), 'उपलब्ध: 2.5 किग्रा');
    });

    test('SettingsProvider updates locale and persists across all 11 languages', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await PreferencesService.create();
      final notifications = LocalNotificationServiceImpl();
      final settings = SettingsProvider(prefs: prefs, notifications: notifications);

      expect(settings.locale, isNull);

      final testCodes = ['pt', 'es', 'fr', 'de', 'it', 'zh', 'ja', 'ru', 'ar', 'hi', 'en'];
      for (final code in testCodes) {
        await settings.setLocale(code);
        expect(settings.locale?.languageCode, code);
        expect(prefs.localeCode, code);
      }

      // Revert to system default
      await settings.setLocale(null);
      expect(settings.locale, isNull);
      expect(prefs.localeCode, isNull);
    });
  });
}
