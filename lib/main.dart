import 'package:ak_kurim/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:ak_kurim/firebase_options.dart';
import 'package:ak_kurim/wrapper.dart';
import 'package:ak_kurim/screens/login_screen.dart';
import 'package:ak_kurim/services/theme.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ak_kurim/services/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeService>(
          create: (_) => ThemeService(),
        ),
        ChangeNotifierProvider<DatabaseService>(
          create: (BuildContext context) => DatabaseService(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, theme, child) {
          theme.loadTheme();
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: const [
              Locale('cs', 'CZ'),
            ],
            title: 'AK Kuřim',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: theme.colorScheme,
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const Wrapper(),
              '/login': (context) => const LoginScreen(),
            },
          );
        },
      ),
    );
  }
}
