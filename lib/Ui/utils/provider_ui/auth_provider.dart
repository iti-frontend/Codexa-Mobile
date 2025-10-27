import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? token;
  String? role;
  dynamic user; // StudentEntity or InstructorEntity

  void saveUser({required String token, required String role, required dynamic user}) {
    this.token = token;
    this.role = role;
    this.user = user;
    notifyListeners();
  }

  void logout() {
    token = null;
    role = null;
    user = null;
    notifyListeners();
  }
}
