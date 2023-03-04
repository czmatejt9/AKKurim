import 'package:ak_kurim/models/group.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ak_kurim/services/navigation.dart';
import 'package:ak_kurim/models/training.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: <Widget>[
        AttendanceScreen(),
        GroupsScreen(),
      ],
    );
  }
}

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);

    return Consumer<NavigationService>(
        builder: (BuildContext context, NavigationService navigation, child) {
      return Container(
        color: Theme.of(context).colorScheme.background,
        child: ListView(
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
          ],
        ),
      );
    });
  }
}

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const ListTile(
              title: Text('Vaše skupiny', style: TextStyle(fontSize: 20)),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: db.trainerGroups.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 10,
                      child: ListTile(
                        title: Text(db.trainerGroups[index].name),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                        ),
                        subtitle: Text(db.trainerGroups[index].trainerIDs
                            .map((e) => db.getTrainerfullNameFromID(e))
                            .join(', ')),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(db.trainerGroups[index].memberIDs.length
                                .toString()),
                            const Icon(Icons.people),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GroupProfile(
                                    group: db.trainerGroups[index])),
                          );
                        },
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}

class GroupProfile extends StatelessWidget {
  final bool create;
  final Group group;
  const GroupProfile({super.key, required this.group, this.create = false});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    return Scaffold(
      appBar: AppBar(
        title: create
            ? const Text('Vytvořit skupinu')
            : const Text('Upravit skupinu'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: ((context) => AlertDialog(
                        title:
                            const Text('Opravdu chcete smazat tuto skupinu?'),
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
                                db.deleteGroup(group);
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
                                        child: Text('Skupina smazána'),
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
        child: Stack(children: [
          ListView(
            children: [
              TextFormField(
                initialValue: group.name,
                onChanged: (value) {
                  group.name = value;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Trenéři'),
                trailing: IconButton(
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () {
                    db.filterTrainers(filter: '', group: group);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AddScreen(type: 'trainers', group: group)));
                  },
                  icon: const Icon(Icons.add),
                ),
              ),
              for (var trainerID in group.trainerIDs)
                Card(
                  elevation: 10,
                  child: ListTile(
                    title: Text(db.getTrainerfullNameFromID(trainerID)),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        group.trainerIDs.remove(trainerID);
                        db.refresh();
                      },
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Členové'),
                trailing: IconButton(
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () {
                    db.filterMembers(filter: '', group: group);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                AddScreen(type: 'members', group: group)));
                  },
                  icon: const Icon(Icons.add),
                ),
              ),
              for (var memberID in group.memberIDs)
                Card(
                  elevation: 10,
                  child: ListTile(
                    title: Text(db.getMemberfullNameFromID(memberID)),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        group.memberIDs.remove(memberID);
                        db.refresh();
                      },
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                    ),
                  ),
                ),
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
                  db.createGroup(group);
                } else {
                  db.updateGroup(group);
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
                          child: Text(create
                              ? 'Skupina vytvořena'
                              : 'Skupina upravena'),
                        ),
                      );
                    });
                Future.delayed(const Duration(seconds: 1), () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                });
              },
              child: const Text('Uložit'),
            ),
          ),
        ]),
      ),
    );
  }
}

class AddScreen extends StatelessWidget {
  final String type; // trainers or members
  final Group group;
  const AddScreen({super.key, required this.type, required this.group});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(type == 'trainers' ? 'Přidat trenéra' : 'Přidat člena'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              initialValue: '',
              decoration: const InputDecoration(
                hintText: 'Hledat',
              ),
              onChanged: (value) {
                if (type == 'trainers') {
                  db.filterTrainers(filter: value, group: group);
                } else {
                  db.filterMembers(filter: value, group: group);
                }
              },
            ),
            ChangeNotifierProvider(
              create: (context) => db,
              child: Expanded(
                child: ListView.builder(
                    itemCount: type == 'trainers'
                        ? db.filteredTrainers.length
                        : db.filteredMembers.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 10,
                        child: ListTile(
                          title: Text(type == 'trainers'
                              ? db.filteredTrainers[index].fullName
                              : db.filteredMembers[index].fullName),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              if (type == 'trainers') {
                                group.trainerIDs
                                    .add(db.filteredTrainers[index].id);
                                db.filteredTrainers
                                    .remove(db.filteredTrainers[index]);
                              } else {
                                group.memberIDs
                                    .add(db.filteredMembers[index].id);
                                db.filteredMembers
                                    .remove(db.filteredMembers[index]);
                              }
                              db.refresh();
                            },
                            icon: const Icon(Icons.add),
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      );
                    }),
              ),
            )
          ],
        ),
      ),
    );
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
