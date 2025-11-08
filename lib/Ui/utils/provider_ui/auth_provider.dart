import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String? token;
  String? role;
  dynamic user;

  Future<void> saveUser({
    required String token,
    required String role,
    required dynamic user,
  }) async {
    this.token = token;
    this.role = role;
    this.user = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);

    notifyListeners();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    role = prefs.getString('role');

    notifyListeners();
  }

  Future<void> logout() async {
    token = null;
    role = null;
    user = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}
