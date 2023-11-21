import 'package:flutter/material.dart';
import 'package:ak_kurim/services/navigation.dart';
import 'package:provider/provider.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:ak_kurim/widgets/drawer.dart';
import 'package:ak_kurim/widgets/appbar.dart';
import 'package:ak_kurim/screens/clothes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context, listen: false);
    final navigation = Provider.of<NavigationService>(context);

    if (!db.isInitialized) {
      db.initialize();
    }

    Widget homeScreen = const Scaffold(
      appBar: MyAppBar(title: 'Domů'),
      body: Placeholder(), // TODO,
      drawer: MyDrawer(),
    );

    List<Widget> screens = [
      homeScreen,
      Placeholder(),
      Placeholder(),
      Placeholder(),
      ClothesScreen()
    ];

    return screens[navigation.currentIndex];
  }
}
