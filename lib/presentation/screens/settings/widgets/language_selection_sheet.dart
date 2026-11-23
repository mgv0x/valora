import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../state/settings_provider.dart';

class LanguageOption {
  final String? code;
  final String nativeName;
  final String englishName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.flag,
  });
}

class LanguageSelectionSheet extends StatelessWidget {
  const LanguageSelectionSheet({super.key});

  static const List<LanguageOption> supportedLanguages = [
    LanguageOption(
      code: null,
      nativeName: 'Padrão do Sistema',
      englishName: 'System Default',
      flag: '🌐',
    ),
    LanguageOption(
      code: 'pt',
      nativeName: 'Português (Brasil)',
      englishName: 'Portuguese',
      flag: '🇧🇷',
    ),
    LanguageOption(
      code: 'en',
      nativeName: 'English',
      englishName: 'English (US)',
      flag: '🇺🇸',
    ),
    LanguageOption(
      code: 'es',
      nativeName: 'Español',
      englishName: 'Spanish',
      flag: '🇪🇸',
    ),
    LanguageOption(
      code: 'fr',
      nativeName: 'Français',
      englishName: 'French',
      flag: '🇫🇷',
    ),
    LanguageOption(
      code: 'de',
      nativeName: 'Deutsch',
      englishName: 'German',
      flag: '🇩🇪',
    ),
    LanguageOption(
      code: 'it',
      nativeName: 'Italiano',
      englishName: 'Italian',
      flag: '🇮🇹',
    ),
    LanguageOption(
      code: 'zh',
      nativeName: '简体中文',
      englishName: 'Chinese (Simplified)',
      flag: '🇨🇳',
    ),
    LanguageOption(
      code: 'ja',
      nativeName: '日本語',
      englishName: 'Japanese',
      flag: '🇯🇵',
    ),
    LanguageOption(
      code: 'ru',
      nativeName: 'Русский',
      englishName: 'Russian',
      flag: '🇷🇺',
    ),
    LanguageOption(
      code: 'ar',
      nativeName: 'العربية',
      englishName: 'Arabic',
      flag: '🇸🇦',
    ),
    LanguageOption(
      code: 'hi',
      nativeName: 'हिन्दी',
      englishName: 'Hindi',
      flag: '🇮🇳',
    ),
  ];

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const LanguageSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final currentCode = settings.locale?.languageCode;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.language, color: AppColors.forestGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.selectLanguage ?? 'Idioma / Select Language',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                        Text(
                          '11 idiomas globais disponíveis com tradução completa',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.subHeader,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.softGray),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: supportedLanguages.length,
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 56),
                itemBuilder: (context, index) {
                  final lang = supportedLanguages[index];
                  final isSelected = currentCode == lang.code;

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      await settings.setLocale(lang.code);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.forestGreen.withValues(alpha: 0.12)
                                  : AppColors.surfaceContainerLow,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              lang.flag,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.nativeName,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? AppColors.forestGreen : AppColors.charcoal,
                                  ),
                                ),
                                Text(
                                  lang.englishName,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.softGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.forestGreen,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
