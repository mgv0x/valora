abstract class TextUtils {
  static const _withAccents = 'àáâãäåèéêëìíîïòóôõöùúûüçñýÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÇÑÝ';
  static const _withoutAccents = 'aaaaaaeeeeiiiiooooouuuucnyAAAAAAEEEEIIIIOOOOOUUUUCNY';

  static final Map<int, String> _charMap = () {
    final map = <int, String>{};
    for (int i = 0; i < _withAccents.length; i++) {
      map[_withAccents.codeUnitAt(i)] = _withoutAccents[i];
    }
    return map;
  }();

  /// Removes diacritics / accents and converts to trimmed lowercase.
  /// E.g. "Maçã Gala" -> "maca gala", "Pão Francês" -> "pao frances".
  static String normalize(String input) {
    if (input.isEmpty) return '';
    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final code = input.codeUnitAt(i);
      final replaced = _charMap[code];
      if (replaced != null) {
        buffer.write(replaced);
      } else {
        buffer.writeCharCode(code);
      }
    }
    return buffer.toString().toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Returns true if [target] contains [query], ignoring case, extra spaces, and accents.
  static bool matchesSearch(String target, String query) {
    if (target.isEmpty && query.isNotEmpty) return false;
    final normQuery = normalize(query);
    if (normQuery.isEmpty) return true;
    final normTarget = normalize(target);
    return normTarget.contains(normQuery);
  }
}
