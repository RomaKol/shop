import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (this._expiryDate != null &&
        this._expiryDate.isAfter(DateTime.now()) &&
        this._token != null) {
      return this._token;
    }
    return null;
  }

  String get userId {
    return this._userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    String url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyC0NtI5Rr9fM74AKT3B82qfYDaMKnCXvIQ';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      this._token = responseData['idToken'];
      this._userId = responseData['localId'];
      this._expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      this._autoLogout();
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return this._authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return this._authenticate(email, password, 'signInWithPassword');
  }

  void logout() {
    this._token = null;
    this._userId = null;
    this._expiryDate = null;
    if (this._authTimer != null) {
      this._authTimer.cancel();
      this._authTimer = null;
    }
    notifyListeners();
  }

  void _autoLogout() {
    if (this._authTimer != null) {
      this._authTimer.cancel();
    }
    final timeToExpiry = this._expiryDate.difference(DateTime.now()).inSeconds;
    this._authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
