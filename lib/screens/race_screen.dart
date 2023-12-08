import 'package:flutter/material.dart';
import 'package:ak_kurim/widgets/appbar.dart';
import 'package:ak_kurim/widgets/drawer.dart';

class RaceScreen extends StatelessWidget {
  const RaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: 'Závody'),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          ListTile(
            title: Text('Závody'),
          )
        ],
      ), // TODO,
      drawer: const MyDrawer(),
    );
  }
}
