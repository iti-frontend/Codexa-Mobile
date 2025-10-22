import 'package:shared_preferences/shared_preferences.dart';
import '../api_manager/api_manager.dart';
import '../models/StudentUser.dart';
import '../models/InstructorUser.dart';

class AuthRepository {
  final ApiManager _api = ApiManager();

  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';

  // ================= Student =================

  Future<StudentUser?> registerStudent({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = await _api.studentRegister(
      name: name,
      email: email,
      password: password,
    );

    if (user?.token != null) {
      await _saveToken(user!.token!, 'student');
    }

    return user;
  }

  Future<StudentUser?> loginStudent({
    required String email,
    required String password,
  }) async {
    final user = await _api.studentLogin(
      email: email,
      password: password,
    );

    if (user?.token != null) {
      await _saveToken(user!.token!, 'student');
    }

    return user;
  }

  // ================= Instructor =================

  Future<InstructorUser?> registerInstructor({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = await _api.instructorRegister(
      name: name,
      email: email,
      password: password,
    );

    if (user?.token != null) {
      await _saveToken(user!.token!, 'instructor');
    }

    return user;
  }

  Future<InstructorUser?> loginInstructor({
    required String email,
    required String password,
  }) async {
    final user = await _api.instructorLogin(
      email: email,
      password: password,
    );

    if (user?.token != null) {
      await _saveToken(user!.token!, 'instructor');
    }

    return user;
  }

  // ================= Social Login =================

  Future<dynamic> socialLogin({
    required String role,
    required String tokenId,
  }) async {
    try {
      dynamic user;
      if (role == 'instructor') {
        user = await _api.socialLogin(tokenId: tokenId);
      } else if (role == 'student') {
        user = await _api.socialLoginStudent(tokenId: tokenId);
      } else {
        throw Exception("Role not supported");
      }

      if (user?.token != null) {
        await _saveToken(user.token!, role);
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // ================= Local Token Handling =================

  Future<void> _saveToken(String token, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_roleKey, role);
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }
}
