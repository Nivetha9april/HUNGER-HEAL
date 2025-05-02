// models/cart_item.dart
class CartItem {
  final String id;
  final String foodName;
  final String foodType;
  final int quantity;
  final String expiryDate;
  final String pickupLocation;
  final DateTime donationDate;

  CartItem({
    required this.id,
    required this.foodName,
    required this.foodType,
    required this.quantity,
    required this.expiryDate,
    required this.pickupLocation,
    required this.donationDate,
  });
}
