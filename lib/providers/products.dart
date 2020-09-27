import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  final String authToken;
  final String userId;

  Products(this.authToken, this._items, this.userId);

  List<Product> get items {
    return [...this._items];
  }

  List<Product> get favoriteItems {
    return this._items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return this._items.firstWhere((Product product) => product.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="${this.userId}"' : '';
    final String url =
        'https://flutter-shop-93a5a.firebaseio.com/products.json?auth=${this.authToken}&$filterString';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final String urlFavorites =
          'https://flutter-shop-93a5a.firebaseio.com/userFavorites/$userId.json?auth=${this.authToken}';
      final favoriteResponse = await http.get(urlFavorites);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((key, value) {
        loadedProducts.add(Product(
          id: key,
          title: value['title'],
          description: value['description'],
          price: value['price'],
          imageUrl: value['imageUrl'],
          isFavorite: favoriteData == null ? false : favoriteData[key] ?? false,
        ));
      }); // key - prod Id, value - prod data
      this._items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) {
    final String url =
        'https://flutter-shop-93a5a.firebaseio.com/products.json?auth=${this.authToken}';
    return http
        .post(url,
            body: json.encode({
              'title': product.title,
              'description': product.description,
              'imageUrl': product.imageUrl,
              'price': product.price,
              'creatorId': this.userId,
            }))
        .then((http.Response response) {
      final body = json.decode(response.body);
      final Product newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: body['name'],
      );
      this._items.add(newProduct);
      // this.items.insert(0, newProduct); // at the start of the end
      notifyListeners();
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = this._items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://flutter-shop-93a5a.firebaseio.com/products/$id.json?auth=${this.authToken}';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'price': newProduct.price,
            'imageUrl': newProduct.imageUrl,
          }));
      this._items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-shop-93a5a.firebaseio.com/products/$id.json?auth=${this.authToken}';
    final existingProductIndex =
        this._items.indexWhere((prod) => prod.id == id);
    Product existingProduct = this._items[existingProductIndex];
    // this._items.removeWhere((prod) => prod.id == id);

    this._items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      this._items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
