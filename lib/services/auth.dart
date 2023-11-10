import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  User? user;

  bool spinner = false;
  bool failed = false;
  bool showPassword = false;

  String? email;
  String? password;

  void refresh() {
    notifyListeners();
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    spinner = true;
    notifyListeners();

    AuthResponse? res;
    try {
      res = await supabase.auth
          .signInWithPassword(email: email, password: password);
    } catch (e) {
      failed = true;
      spinner = false;
      notifyListeners();
      return;
    }

    user = res.user;
    spinner = false;
    password = '';
    email = '';
    notifyListeners();
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    user = null;
    notifyListeners();
  }
}
