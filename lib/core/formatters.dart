/// Small formatting helpers shared across the UI layer.
class Formatters {
  const Formatters._();

  /// Formats a double as a price in euros, e.g. `24,90 €`.
  static String price(double value) {
    return '${value.toStringAsFixed(2).replaceAll('.', ',')} €';
  }

  /// Short month-year date, e.g. `mars 2024`.
  static String monthYear(DateTime date) {
    const months = [
      'janvier',
      'fevrier',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'aout',
      'septembre',
      'octobre',
      'novembre',
      'decembre',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
