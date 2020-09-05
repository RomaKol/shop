import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return this._items;
  }

  int get itemCount {
    return this._items.length;
  }

  double get totalAmount {
    double total = 0.0;
    this._items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(
    String productId,
    double price,
    String title,
  ) {
    if (this._items.containsKey(productId)) {
      // change quantity...
      this._items.update(
            productId,
            (existingCartItem) => CartItem(
              id: existingCartItem.id,
              title: existingCartItem.title,
              price: existingCartItem.price,
              quantity: existingCartItem.quantity + 1,
            ),
          );
    } else {
      this._items.putIfAbsent(
            productId,
            () => CartItem(
              id: DateTime.now().toString(),
              title: title,
              quantity: 1,
              price: price,
            ),
          );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    this._items.remove(productId);
    notifyListeners();
  }

  void clear() {
    this._items = {};
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!this._items.containsKey(productId)) {
      return;
    }
    if (this._items[productId].quantity > 1) {
      this._items.update(
            productId,
            (existingCartItem) => CartItem(
              id: existingCartItem.id,
              title: existingCartItem.title,
              price: existingCartItem.price,
              quantity: existingCartItem.quantity - 1,
            ),
          );
    } else {
      this._items.remove(productId);
    }
    notifyListeners();
  }
}
