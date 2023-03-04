import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:ak_kurim/models/user.dart';
import 'package:flutter/material.dart';

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  User? _userFromFirebaseUser(auth.User? user) {
    return user != null ? User(uid: user.uid, email: user.email) : null;
  }

  Stream<User?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // sign in with email and password
  Future<User?> signIn(
      String email, String password, LoginScreenManager loginState) async {
    try {
      final auth.UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      auth.User? user = result.user;
      return _userFromFirebaseUser(user)!;
    } catch (e) {
      loginState.changeSpinner();
      loginState.changeFailed();
      // what should I return when the login fails so it doesnt throw an error?
      return _userFromFirebaseUser(null);
    }
  }

  // register with email and password currently not used, but might be in the future
  Future<User?> signUp(String email, String password) async {
    try {
      final auth.UserCredential result =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      auth.User? user = result.user;
      return _userFromFirebaseUser(user)!;
    } catch (e) {
      // print(e.toString());
      return _userFromFirebaseUser(null);
    }
  }

  // sign out TODO remove print
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}

class LoginScreenManager extends ChangeNotifier {
  bool _spinner = false;
  bool _failed = false;
  bool _showPassword = false;

  bool get spinner => _spinner;
  bool get failed => _failed;
  bool get showPassword => _showPassword;

  void changeSpinner() {
    _spinner = !_spinner;
    notifyListeners();
  }

  void changeFailed() {
    _failed = !_failed;
    notifyListeners();
  }

  void changeShowPassword() {
    _showPassword = !_showPassword;
    notifyListeners();
  }
}
