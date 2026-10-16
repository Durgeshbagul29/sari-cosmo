class Coupon {
  final int id;
  final String code;
  final String description;
  final String type; // "fixed" or "percent"
  final double value;
  final double minOrderAmount;
  final double? maxDiscount;
  final String validUntil;

  const Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.type,
    required this.value,
    required this.minOrderAmount,
    this.maxDiscount,
    required this.validUntil,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'fixed',
      value: (json['value'] ?? 0).toDouble(),
      minOrderAmount: (json['min_order_amount'] ?? 0).toDouble(),
      maxDiscount: json['max_discount'] != null ? (json['max_discount'] as num).toDouble() : null,
      validUntil: json['valid_until'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'type': type,
      'value': value,
      'min_order_amount': minOrderAmount,
      'max_discount': maxDiscount,
      'valid_until': validUntil,
    };
  }

  // UI helper getters
  bool get isActive {
    try {
      final expiry = DateTime.parse(validUntil);
      // Compare with start of day today to prevent timezone issues
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return expiry.isAfter(today) || expiry.isAtSameMomentAs(today);
    } catch (_) {
      return true; // Fallback to active if parse fails
    }
  }

  String get validTillFormatted {
    try {
      final parts = validUntil.split('T')[0].split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final monthInt = int.parse(parts[1]);
        final day = int.parse(parts[2]).toString();
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final monthStr = months[monthInt - 1];
        return '$day $monthStr $year';
      }
    } catch (_) {}
    return validUntil;
  }
}
