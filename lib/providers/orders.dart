import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [...this._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = 'https://flutter-shop-93a5a.firebaseio.com/orders.json';
    final timestamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'dateTime': timestamp.toIso8601String(),
        'products': cartProducts
            .map((cartProduct) => {
                  'id': cartProduct.id,
                  'title': cartProduct.title,
                  'quantity': cartProduct.quantity,
                  'price': cartProduct.price,
                })
            .toList(),
      }),
    );
    this._orders.insert(
          0,
          OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            products: cartProducts,
            dateTime: timestamp,
          ),
        );
    notifyListeners();
  }
}
