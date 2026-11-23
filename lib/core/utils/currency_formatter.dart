import 'package:intl/intl.dart';

abstract class CurrencyFormatter {
  static String format(double? amount, {String? localeCode}) {
    if (amount == null || amount.isNaN || amount.isInfinite) return '';
    final locale = localeCode ?? 'en_US';
    try {
      final format = NumberFormat.simpleCurrency(locale: locale);
      return format.format(amount);
    } catch (_) {
      final fallbackFormat = NumberFormat.simpleCurrency(locale: 'en_US');
      return fallbackFormat.format(amount);
    }
  }
}
