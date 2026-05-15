import 'dart:convert';

import 'package:frontend/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/core/constants/constants.dart';

class AuthRemoteRepository {
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/signup'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }
      return UserModel.fromMap(jsonDecode(res.body));
    } catch (e) {
      throw e.toString();
    }
  }

  // Future<void> login() {}
}
