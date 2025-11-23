import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserProvider extends ChangeNotifier {
  final SharedPreferences prefs;

  String? token;
  String? role;
  dynamic user;

  bool _loaded = false;

  UserProvider(this.prefs);

  /// يجب استدعاؤها مرة واحدة في main.dart بعد إنشاء provider
  Future<void> loadUser() async {
    if (_loaded) return;
    _loaded = true;

    token = prefs.getString('token');
    role = prefs.getString('role');

    final userJson = prefs.getString('user');

    if (userJson != null) {
      try {
        user = jsonDecode(userJson);
      } catch (e) {
        print("Error decoding user json: $e");
      }
    }

    notifyListeners();
  }

  Future<void> saveUser({
    required String token,
    required String role,
    required dynamic user,
  }) async {
    this.token = token;
    this.role = role;
    this.user = user;
    _loaded = true;

    await prefs.setString('token', token);
    await prefs.setString('role', role);

    if (user != null) {
      String encoded = jsonEncode(user);
      await prefs.setString('user', encoded);
    }

    notifyListeners();
  }

  Future<void> logout() async {
    token = null;
    role = null;
    user = null;
    _loaded = false;

    // 🟢 Sign out from Firebase + Google
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

    await prefs.clear();
    await prefs.reload();

    notifyListeners();
  }
}
