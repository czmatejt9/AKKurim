import 'package:ak_kurim/services/auth.dart';
import 'package:ak_kurim/screens/login_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ak_kurim/services/theme.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // TODO change here
    }
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      print(error);
      print(stack);
    }
    if (kReleaseMode) {
      // TODO change here
    }
    return true;
  };
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeService>(
          create: (_) => ThemeService(),
        ),
        ChangeNotifierProvider<DatabaseService>(
          create: (_) => DatabaseService(),
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Consumer<ThemeService>(
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
    );
  }
}
