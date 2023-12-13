import 'package:flutter/material.dart';
import 'package:ak_kurim/widgets/appbar.dart';
import 'package:ak_kurim/widgets/drawer.dart';
import 'package:ak_kurim/models/race.dart';
import 'package:ak_kurim/widgets/race_card.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:provider/provider.dart';

class RaceScreen extends StatelessWidget {
  const RaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = Provider.of<DatabaseService>(context);
    return Scaffold(
      appBar: const MyAppBar(title: 'Závody'),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: db.races.map((Race race) => RaceCard(race: race)).toList(),
      ),
      drawer: const MyDrawer(),
    );
  }
}
