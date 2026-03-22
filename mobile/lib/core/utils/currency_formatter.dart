import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatLkr(num amount) {
    final format = NumberFormat.currency(
      symbol: 'LKR ',
      decimalDigits: 2,
    );
    return format.format(amount);
  }
}
