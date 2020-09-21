import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavoriteValue(bool newValue) {
    this.isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token) async {
    final oldStatus = this.isFavorite;
    this._setFavoriteValue(!this.isFavorite);
    final url =
        'https://flutter-shop-93a5a.firebaseio.com/products/$id.json?auth=$token';
    try {
      final response = await http.patch(
        url,
        body: json.encode({
          'isFavorite': this.isFavorite,
        }),
      );
      if (response.statusCode >= 400) {
        this._setFavoriteValue(oldStatus);
      }
    } catch (error) {
      this._setFavoriteValue(oldStatus);
    }
  }
}
