import '../models/warranty.dart';

class WarrantyService {
  static final WarrantyService _instance = WarrantyService._internal();
  factory WarrantyService() => _instance;
  WarrantyService._internal();

  final Map<String, Warranty> _warranties = {};

  void registerWarranty(Warranty warranty) {
    _warranties[warranty.productId] = warranty;
  }

  Warranty? getWarranty(String productId) {
    return _warranties[productId];
  }
}
