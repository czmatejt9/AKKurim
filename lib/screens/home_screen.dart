import 'package:ak_kurim/models/member_preview.dart';
import 'package:flutter/material.dart';
import 'package:ak_kurim/services/navigation.dart';
import 'package:ak_kurim/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:ak_kurim/widgets/drawer.dart';
import 'package:ak_kurim/widgets/appbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final auth = Provider.of<AuthService>(context);
    final navigation = Provider.of<NavigationService>(context);

    if (!db.isInitialized) {
      db.initialize();
    }

    return Scaffold(
      appBar: const MyAppBar(title: 'Domů'),
      body: Placeholder(), // TODO,
      drawer: const MyDrawer(),
    );
  }
}
