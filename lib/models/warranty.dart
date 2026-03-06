class Warranty {
  final String productId;
  final String productName;
  final String customerName;
  final DateTime purchaseDate;
  final int warrantyPeriodMonths;

  Warranty({
    required this.productId,
    required this.productName,
    required this.customerName,
    required this.purchaseDate,
    required this.warrantyPeriodMonths,
  });

  DateTime get expiryDate => DateTime(
        purchaseDate.year,
        purchaseDate.month + warrantyPeriodMonths,
        purchaseDate.day,
      );

  bool get isValid => DateTime.now().isBefore(expiryDate);
}
