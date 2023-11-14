import 'package:ak_kurim/services/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ak_kurim/screens/login_screen.dart';
import 'package:ak_kurim/screens/home_screen.dart';
import 'package:ak_kurim/services/navigation.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:ak_kurim/services/powersync.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await openDatabase();
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
        ChangeNotifierProvider<DatabaseService>(
          create: (_) => DatabaseService(),
        ),
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<NavigationService>(
          create: (_) => NavigationService(),
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
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('cs', 'CZ'),
      ],
      title: 'AK Kuřim',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey[200],
        brightness: Brightness.dark,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Wrapper(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context); // used for refreshing
    return isLoggedIn() ? HomeScreen() : const LoginScreen();
  }
}
