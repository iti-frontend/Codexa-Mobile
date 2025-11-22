import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  final SharedPreferences prefs;

  String? token;
  String? role;
  dynamic user;

  UserProvider(this.prefs) {
    // ✅ Schedule loadUser to run after build completes
    SchedulerBinding.instance.addPostFrameCallback((_) {
      loadUser();
    });
  }

  Future<void> loadUser() async {
    token = prefs.getString('token');
    role = prefs.getString('role');
    final userJson = prefs.getString('user');
    if (userJson != null) {
      user = jsonDecode(userJson);
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

    await prefs.setString('token', token);
    await prefs.setString('role', role);

    notifyListeners();
  }

  Future<void> logout() async {
    token = null;
    role = null;
    user = null;

    await prefs.clear();

    notifyListeners();
  }
}
