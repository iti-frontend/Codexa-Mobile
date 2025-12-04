import 'dart:convert';
import 'package:codexa_mobile/Domain/entities/instructor_entity.dart';
import 'package:codexa_mobile/Domain/entities/student_entity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserProvider extends ChangeNotifier {
  final SharedPreferences prefs;

  String? token;
  String? role;
  dynamic user;

  bool get isLoggedIn => token != null && user != null;

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
        final Map<String, dynamic> userData = jsonDecode(userJson);
        // Convert to proper Entity based on role
        if (role?.toLowerCase() == 'student') {
          user = StudentEntity.fromJson(userData);
        } else if (role?.toLowerCase() == 'instructor') {
          user = InstructorEntity.fromJson(userData);
        } else {
          user = userData; // Fallback to Map
        }
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

  // Update user data and notify listeners
  Future<void> updateUser(dynamic updatedUser) async {
    user = updatedUser;

    // Also update in SharedPreferences for persistence
    if (updatedUser != null) {
      String encoded = jsonEncode(updatedUser);
      await prefs.setString('user', encoded);
    }

    notifyListeners(); // This triggers UI rebuild
    print('✅ User updated in provider and SharedPreferences');
  }

  // ADD THIS SETTER: Alternative way to update user
  set setUser(dynamic newUser) {
    user = newUser;
    if (newUser != null) {
      final encoded = jsonEncode(newUser);
      prefs.setString('user', encoded);
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
