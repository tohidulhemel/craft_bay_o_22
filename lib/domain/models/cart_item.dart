import 'product.dart';

class CartItem {
  const CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    this.color,
    this.size,
  });

  final String id;
  final Product product;
  final int quantity;
  final String? color;
  final String? size;

  num get unitPrice => product.currentPrice;
  num get totalPrice => unitPrice * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      product: product,
      quantity: quantity ?? this.quantity,
      color: color,
      size: size,
    );
  }
}
