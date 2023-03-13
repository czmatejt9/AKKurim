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
      navigation.trainingForCurrentDay = false;
      return Container(
          color: Theme.of(context).colorScheme.background,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 76),
            itemCount: db.trainerTrainings.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return TableCalendar(
                  locale: 'cs_CZ',
                  calendarFormat: CalendarFormat.month,
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
                );
              } else if (isSameDay(
                  db.trainerTrainings[index - 1].timestamp.toDate(),
                  navigation.selectedDate)) {
                navigation.trainingForCurrentDay = true;
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
                        // push to take attendance screen
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TakeAttendance(
                                  training: db.trainerTrainings[index - 1]),
                            ));
                      },
                      title: Text(
                          '${Helper().getHourMinute(db.trainerTrainings[index - 1].timestamp.toDate())} ${db.getGroupNameFromID(db.trainerTrainings[index - 1].groupID)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              '${db.trainerTrainings[index - 1].attendingNumber}/${db.trainerTrainings[index - 1].attendanceNumber}'),
                          db.trainerTrainings[index - 1].attendanceTaken
                              ? const Icon(Icons.check, color: Colors.green)
                              : const Icon(Icons.close, color: Colors.red)
                        ],
                      )),
                );
              } else if (db.trainerTrainings.last ==
                      db.trainerTrainings[index - 1] &&
                  !navigation.trainingForCurrentDay) {
                return Center(
                  child: Column(
                    children: const <Widget>[
                      SizedBox(height: 20),
                      Text('V tento den nemáte žádné tréninky.',
                          style: TextStyle(fontSize: 20)),
                    ],
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ));
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
    final group = db.getGroupFromID(training.groupID);
    return Scaffold(
        appBar: AppBar(
          title: Text(create ? 'Vytvořit trénink' : 'Upravit trénink'),
          leading: IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text('Opravdu chcete odejít?'),
                        content: const Text(
                            'Pokud odejdete, neuložené změny budou ztraceny.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('Odejít'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Zůstat'),
                          ),
                        ],
                      ));
            },
            icon: const Icon(Icons.arrow_back),
          ),
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
                                  if (!create) {
                                    Navigator.pop(context);
                                  }
                                });
                              },
                              child: const Text('Smazat'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Zrušit'),
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
          child: Stack(children: [
            ListView(
              children: <Widget>[
                ListTile(
                  title: Text('Skupina: ${group.name}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(group.trainerIDs.length.toString()),
                      const Icon(Icons.person),
                      Text(group.memberIDs.length.toString()),
                      const Icon(Icons.people),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: ((context) => AlertDialog(
                              title: const Text('Vyberte skupinu'),
                              content: SizedBox(
                                height: 300,
                                width: 300,
                                child: ListView.builder(
                                  itemCount: db.trainerGroups.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(db.trainerGroups[index].name),
                                      onTap: () {
                                        training.groupID =
                                            db.trainerGroups[index].id;
                                        training.substituteTrainerID = '';
                                        db.refresh();
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              ),
                            )));
                  },
                ),
                const Divider(),
                ListTile(
                  title: Text(
                      'Náhradní trenér: ${db.getTrainerfullNameFromID(training.substituteTrainerID)}'),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: ((context) => AlertDialog(
                              title: const Text('Vyberte náhradního trenéra'),
                              content: SizedBox(
                                height: 300,
                                width: 300,
                                child: ListView.builder(
                                  itemCount: db.allTrainers.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == db.allTrainers.length) {
                                      return ListTile(
                                        title: const Text('-'),
                                        onTap: () {
                                          training.substituteTrainerID = '';
                                          db.refresh();
                                          Navigator.pop(context);
                                        },
                                      );
                                    }
                                    if (!group.trainerIDs
                                        .contains(db.allTrainers[index].id)) {
                                      return ListTile(
                                        title: Text(
                                            db.allTrainers[index].fullName),
                                        onTap: () {
                                          training.substituteTrainerID =
                                              db.allTrainers[index].id;
                                          db.refresh();
                                          Navigator.pop(context);
                                        },
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                ),
                              ),
                            )));
                  },
                ),
                const Divider(),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).colorScheme.secondary),
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).colorScheme.onSecondary),
                ),
                onPressed: () {
                  if (create) {
                    db.createTraining(training);
                  } else {
                    db.updateTraining(training, true);
                  }
                  db.refresh();
                  showModalBottomSheet(
                      isDismissible: false,
                      context: context,
                      builder: (context) {
                        return Container(
                          height: 50,
                          color: Colors.green[400],
                          child: Center(
                            child: Text(
                                create ? 'Trénink vytvořen' : 'Trénik upraven'),
                          ),
                        );
                      });
                  Future.delayed(const Duration(seconds: 1), () {
                    if (!create) {
                      Navigator.pop(context);
                    }
                    Navigator.pop(context);
                    Navigator.pop(context);
                  });
                },
                child: const Text('Uložit', style: TextStyle(fontSize: 20)),
              ),
            ),
          ]),
        ));
  }
}

class TakeAttendance extends StatelessWidget {
  final Training training;
  const TakeAttendance({super.key, required this.training});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final group = db.getGroupFromID(training.groupID);
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text('Opravdu chcete odejít?'),
                          content: const Text(
                              'Pokud odejdete, neuložené změny budou ztraceny.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text('Odejít'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Zůstat'),
                            ),
                          ],
                        ));
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: const Text('Zapsat docházku'),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TrainingProfile(
                                training: training, create: false)));
                  },
                  icon: const Icon(Icons.edit_note))
            ]),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(children: [
              Column(
                children: <Widget>[
                  ListTile(
                    title: Text('Skupina: ${group.name}'),
                    trailing: Text(
                        '${training.hourAndMinute} - ${training.dayAndMonth} ${training.year}'),
                  ),
                  const Divider(),
                  Expanded(
                      child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 50),
                          itemCount: training.attendanceValues.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 10,
                              child: CheckboxListTile(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                ),
                                tristate: true,
                                value: training.attendanceValues[index],
                                onChanged: ((value) {
                                  training.attendanceValues[index] = value;
                                  db.refresh();
                                }),
                                title:
                                    db.isTrainer(training.attendanceKeys[index])
                                        ? Text(
                                            db.getTrainerfullNameFromID(
                                                training.attendanceKeys[index]),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20))
                                        : Text(
                                            db.getMemberfullNameFromID(
                                                training.attendanceKeys[index]),
                                          ),
                              ),
                            );
                          })),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.secondary),
                    foregroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).colorScheme.onSecondary),
                  ),
                  onPressed: () {
                    training.attendanceTaken = true;
                    db.updateTraining(training, false);
                    db.refresh();
                    showModalBottomSheet(
                        isDismissible: false,
                        context: context,
                        builder: (context) {
                          return Container(
                            height: 50,
                            color: Colors.green[400],
                            child: const Center(
                              child: Text('Docházka zapsána'),
                            ),
                          );
                        });
                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    });
                  },
                  child: const Text('Uložit', style: TextStyle(fontSize: 20)),
                ),
              ),
            ])));
  }
}
