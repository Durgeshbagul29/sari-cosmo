import 'package:intl/intl.dart';

class AppHelpers {
  /// Formats a double value as currency (e.g. ₹1,200)
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return formatter.format(amount);
  }

  /// Formats a DateTime object into a readable string (e.g. 12 Oct, 2026)
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM, yyyy');
    return formatter.format(date);
  }
}
