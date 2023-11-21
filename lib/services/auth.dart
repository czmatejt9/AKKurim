import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ak_kurim/services/powersync.dart';

class AuthService extends ChangeNotifier {
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

    try {
      await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);
    } catch (e) {
      failed = true;
      spinner = false;
      notifyListeners();
      return;
    }

    spinner = false;
    password = '';
    email = '';
    notifyListeners();
  }

  Future<void> logout_() async {
    await logout();
    notifyListeners();
  }
}
