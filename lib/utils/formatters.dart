/// Formatting utility functions

/// Formats an integer with thousand separators (commas)
/// Example: 1000 -> "1,000", 1000000 -> "1,000,000"
String formatNumberWithCommas(int number) {
  return number.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );
}

/// Formats a double with thousand separators (commas)
/// Example: 1000.5 -> "1,000.5", 1000000.25 -> "1,000,000.25"
String formatDoubleWithCommas(double value, [int decimalPlaces = 2]) {
  final rounded = value.toStringAsFixed(decimalPlaces);
  final parts = rounded.split('.');
  final integerPart = formatNumberWithCommas(int.parse(parts[0]));
  if (parts.length == 1) {
    return integerPart;
  }
  return '$integerPart.${parts[1]}';
}
