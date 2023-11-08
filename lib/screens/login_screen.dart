import 'package:provider/provider.dart';
import 'package:ak_kurim/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final TextEditingController emailController =
        TextEditingController(text: auth.email);
    final TextEditingController passwordController =
        TextEditingController(text: auth.password);

    return Stack(
      children: [
        Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                  child: TextField(
                    controller: emailController,
                    onChanged: (value) {
                      auth.email = value;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Email',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                  child: TextField(
                    controller: passwordController,
                    onChanged: (value) {
                      auth.password = value;
                    },
                    obscureText: !auth.showPassword,
                    enableSuggestions: false,
                    autocorrect: false,
                    onSubmitted: (value) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      auth.signInWithEmail(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                    },
                    decoration: InputDecoration(
                      hintText: 'Heslo',
                      suffixIcon: IconButton(
                          onPressed: () {
                            auth.showPassword = !auth.showPassword;
                            auth.refresh();
                          },
                          icon: Icon(auth.showPassword
                              ? Icons.visibility
                              : Icons.visibility_off)),
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    auth.signInWithEmail(
                      email: emailController.text,
                      password: passwordController.text,
                    );
                  },
                  child: const Text('Přihlásit se'),
                )
              ],
            ),
          ),
        ),
        if (auth.spinner)
          const Opacity(
            opacity: 0.5,
            child: ModalBarrier(
              dismissible: false,
              color: Colors.grey,
            ),
          ),
        if (auth.spinner)
          const Center(
            child: SpinKitFadingCircle(
              color: Colors.white,
              size: 50.0,
            ),
          ),
        if (auth.failed)
          AlertDialog(
            title: const Text('Přihlášení se nezdařilo'),
            content: const Text(
                'Zkontrolujte prosím připojení k internetu a zadané údaje'),
            actions: [
              TextButton(
                onPressed: () {
                  auth.failed = !auth.failed;
                  auth.refresh();
                },
                child: const Text('OK'),
              ),
            ],
          ),
      ],
    );
  }
}
