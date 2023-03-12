import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:ak_kurim/services/navigation.dart';
import 'package:ak_kurim/services/helpers.dart';
import 'package:ak_kurim/models/training.dart';
import 'package:ak_kurim/models/group.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    return Consumer<NavigationService>(
        builder: (BuildContext context, NavigationService navigation, child) {
      return Container(
        color: Theme.of(context).colorScheme.background,
        child: Column(
          children: [
            TableCalendar(
              locale: 'cs_CZ',
              calendarFormat: CalendarFormat.week,
              calendarStyle: const CalendarStyle(
                weekendTextStyle: TextStyle(color: Colors.red),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2032, 12, 31),
              focusedDay: navigation.selectedDate,
              selectedDayPredicate: (DateTime date) {
                return isSameDay(navigation.selectedDate, date);
              },
              onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                navigation.selectedDate = selectedDay;
                navigation.focusedDay = focusedDay;
              },
            ),
            const SizedBox(height: 10),
            Container(
              color: Colors.orange,
            ),
            // here show trainings for selected date TODO
            Expanded(
                child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 76),
              itemCount: db.trainings.length,
              itemBuilder: (context, index) {
                if (Helper().isSameWeek(db.trainings[index].timestamp.toDate(),
                    navigation.selectedDate)) {
                  return Card(
                    elevation: 10,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                      ),
                      onTap: () {
                        // TODO
                      },
                      title: Text(
                          db.getGroupNameFromID(db.trainings[index].groupID)),
                      trailing: Text(db.trainings[index].timestamp
                          .toDate()
                          .toString()
                          .substring(0, 10)),
                    ),
                  );
                }
                return Container();
              },
            ))
          ],
        ),
      );
    });
  }
}

class TrainingProfile extends StatelessWidget {
  final Training training;
  final bool create;
  const TrainingProfile(
      {super.key, required this.training, required this.create});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(create ? 'Vytvořit trénink' : 'Upravit trénink'),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: ((context) => AlertDialog(
                          title: const Text(
                              'Opravdu chcete smazat tento trénink?'),
                          content: const Text('Tato akce je nevratná.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Zrušit'),
                            ),
                            TextButton(
                              onPressed: () {
                                if (!create) {
                                  db.deleteTraining(training);
                                }
                                db.refresh();
                                showModalBottomSheet(
                                    isDismissible: false,
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        height: 50,
                                        color: Colors.red[300],
                                        child: const Center(
                                          child: Text('Trénink smazán'),
                                        ),
                                      );
                                    });
                                Future.delayed(const Duration(seconds: 1), () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                });
                              },
                              child: const Text('Smazat'),
                            ),
                          ],
                        )));
              },
              icon: const Icon(Icons.delete),
              color: Colors.red,
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Text("Skupina:"),
                  DropdownButton(
                    value: training.groupID,
                    items: db.trainerGroups.map((Group group) {
                      return DropdownMenuItem(
                        value: group.id,
                        child: Text(group.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      training.groupID = value.toString();
                      db.refresh();
                    },
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
