import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:ak_kurim/services/helpers.dart';
import 'package:ak_kurim/models/race_preview.dart';

class ActionsScreen extends StatelessWidget {
  const ActionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: db.racesLoaded
          ? Container(
              color: Theme.of(context).colorScheme.background,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: <Widget>[
                    const SizedBox(height: 10),
                    Text(Helper().getCzechMonthAndYear(DateTime.now()),
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 10),
                    const ThisMonthsRaces(),
                  ],
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class ThisMonthsRaces extends StatelessWidget {
  const ThisMonthsRaces({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    return db.racePreviews.isNotEmpty
        ? Column(children: <Widget>[
            for (var preview in db.racePreviews)
              Column(children: <Widget>[
                // display the below container only if the previous training is not in the same day
                if (db.racePreviews.indexOf(preview) == 0 ||
                    !Helper().isSameDay(
                        db.racePreviews[db.racePreviews.indexOf(preview) - 1]
                            .timestamp
                            .toDate(),
                        preview.timestamp.toDate()))
                  Container(
                    padding: const EdgeInsets.only(left: 16, top: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      Helper().getCzechDayAndDate(preview.timestamp.toDate()),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                RacePreviewCard(
                  racePreview: preview,
                ),
              ])
          ])
        : SizedBox(
            height: 200,
            child: Center(
              child: Text('Žádné závody v tomto měsíci',
                  style: Theme.of(context).textTheme.headlineSmall),
            ),
          );
  }
}

class RacePreviewCard extends StatelessWidget {
  final RacePreview racePreview;
  const RacePreviewCard({super.key, required this.racePreview});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    return Card(
      elevation: 10,
      child: ListTile(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        onTap: () {
          /* // push to take attendance screen
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TakeAttendance(training: training),
              )); TODO race profile page */
        },
        title: Text(racePreview.name),
        subtitle: Text(racePreview.place, style: const TextStyle(fontSize: 10)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(racePreview.members.length.toString()),
            const Icon(Icons.people),
          ],
        ),
      ),
    );
  }
}
