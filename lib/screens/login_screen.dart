import 'package:provider/provider.dart';
import 'package:ak_kurim/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    final AuthService auth = Provider.of<AuthService>(context, listen: false);

    return ChangeNotifierProvider<LoginScreenManager>(
      create: (_) => LoginScreenManager(),
      child:
          Consumer<LoginScreenManager>(builder: (context, loginState, child) {
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
                        decoration: const InputDecoration(
                          hintText: 'Email',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                      child: TextField(
                        controller: passwordController,
                        obscureText: !loginState.showPassword,
                        enableSuggestions: false,
                        autocorrect: false,
                        onSubmitted: (value) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          loginState.changeSpinner();
                          auth.signIn(
                            emailController.text,
                            passwordController.text,
                            loginState,
                          );
                        },
                        decoration: InputDecoration(
                          hintText: 'Heslo',
                          suffixIcon: IconButton(
                              onPressed: () => loginState.changeShowPassword(),
                              icon: Icon(loginState.showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off)),
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        loginState.changeSpinner();
                        auth.signIn(
                          emailController.text,
                          passwordController.text,
                          loginState,
                        );
                      },
                      child: const Text('Přihlásit se'),
                    )
                  ],
                ),
              ),
            ),
            if (loginState.spinner)
              const Opacity(
                opacity: 0.5,
                child: ModalBarrier(
                  dismissible: false,
                  color: Colors.grey,
                ),
              ),
            if (loginState.spinner)
              const Center(
                child: SpinKitFadingCircle(
                  color: Colors.white,
                  size: 50.0,
                ),
              ),
            if (loginState.failed)
              AlertDialog(
                title: const Text('Přihlášení se nezdařilo'),
                content: const Text(
                    'Zkontrolujte prosím připojení k internetu a zadané údaje'),
                actions: [
                  TextButton(
                    onPressed: () {
                      loginState.changeFailed();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
          ],
        );
      }),
    );
  }
}
