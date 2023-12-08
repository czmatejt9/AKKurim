import 'package:flutter/material.dart';
import 'package:ak_kurim/models/race.dart';

class RaceCard extends StatelessWidget {
  final Race race;
  const RaceCard({super.key, required this.race});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 10,
        child: ListTile(
          title: Text(race.name),
        ));
  }
}
