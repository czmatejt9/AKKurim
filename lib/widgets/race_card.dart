import 'package:flutter/material.dart';
import 'package:ak_kurim/models/race.dart';
import 'package:ak_kurim/services/helpers.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:provider/provider.dart';

class RaceCard extends StatelessWidget {
  final Race race;
  const RaceCard({super.key, required this.race});

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = Provider.of<DatabaseService>(context);
    final DateTime raceTimeEnd = DateTime.parse(race.datetimeEnd);
    return Card(
      elevation: 10,
      child: ListTile(
          title: Text(race.name),
          tileColor: race.isInProgress()
              ? Colors.orange
              : Helper.isBeforeToday(raceTimeEnd)
                  ? Colors.green
                  : Colors.grey,
          subtitle: Text(race.place.contains(' (')
              ? race.place.split(' (')[0]
              : race.place),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder(
                  future: db.getRacersCount(raceID: race.id),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<int> snapshot,
                  ) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data.toString());
                    } else {
                      return const Text('?');
                    }
                  }),
              const Icon(Icons.people),
            ],
          )),
    );
  }
}
