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
import 'package:supabase_flutter/supabase_flutter.dart' as spb;
import 'package:ak_kurim/services/background.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  // init packages and set up notification callback and error sending
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await openDatabase();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // send error to firebase crashlytics
      FirebaseCrashlytics.instance.recordFlutterError(details);
    }
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      print(error);
      print(stack);
    }
    if (kReleaseMode) {
      // send error to firebase crashlytics
      FirebaseCrashlytics.instance.recordError(error, stack);
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
    final auth =
        Provider.of<AuthService>(context, listen: true); // used for refreshing
    final spb.User? user = spb.Supabase.instance.client.auth.currentUser;
    return user != null ? HomeScreen() : const LoginScreen();
  }
}
