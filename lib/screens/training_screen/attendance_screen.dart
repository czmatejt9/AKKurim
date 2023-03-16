import 'package:cloud_firestore/cloud_firestore.dart';
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
                Group group =
                    db.getGroupFromID(db.trainerTrainings[index - 1].groupID);
                String names = group.trainerIDs.map((id) {
                  return db.getTrainerFullNameFromID(id);
                }).join(', ');
                if (db.trainerTrainings[index - 1].substituteTrainerID != '') {
                  names +=
                      ', ${db.getTrainerFullNameFromID(db.trainerTrainings[index - 1].substituteTrainerID)}';
                }
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
                          '${Helper().getHourMinute(db.trainerTrainings[index - 1].timestamp.toDate())} - ${db.getGroupNameFromID(db.trainerTrainings[index - 1].groupID)}'),
                      subtitle:
                          Text(names, style: const TextStyle(fontSize: 10)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              '${db.trainerTrainings[index - 1].attendingNumber}/${db.trainerTrainings[index - 1].attendanceNumber}'),
                          const Icon(Icons.people),
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
    final Group group = db.getGroupFromID(training.groupID);
    final noteController = TextEditingController(text: training.note);
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
                                // show snackbar
                                Navigator.pop(context);
                                Navigator.pop(context);
                                if (!create) {
                                  Navigator.pop(context);
                                }
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Trénink smazán',
                                      textAlign: TextAlign.center),
                                  backgroundColor: Color(0xFFE57373),
                                ));
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
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // dismiss keyboard
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(children: [
              ListView(
                children: <Widget>[
                  ListTile(
                    title: Row(
                      children: [
                        const Icon(Icons.groups),
                        const SizedBox(width: 20),
                        Text(
                          group.name,
                          style: TextStyle(
                              color: group.id == ''
                                  ? Colors.grey
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color),
                        ),
                      ],
                    ),
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
                                        title:
                                            Text(db.trainerGroups[index].name),
                                        onTap: () {
                                          if (training.groupID ==
                                              db.trainerGroups[index].id) {
                                            Navigator.pop(context);
                                            return;
                                          }
                                          db.isChangedTrainingGroup = true;
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
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_add_alt_1),
                        const SizedBox(width: 18),
                        Text(
                          db.getTrainerFullNameFromID(
                              training.substituteTrainerID),
                          style: TextStyle(
                              color: training.substituteTrainerID == ''
                                  ? Colors.grey
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color),
                        ),
                      ],
                    ),
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
                                            db.isChangedTrainingGroup = true;
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
                                            db.isChangedTrainingGroup = true;
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
                  ListTile(
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.notes_rounded),
                        const SizedBox(width: 20),
                        Expanded(
                          child: TextField(
                            controller: noteController,
                            onChanged: (value) {
                              training.note = value;
                            },
                            maxLines: null,
                            decoration: const InputDecoration(
                                hintText: 'Poznámka',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.grey)),
                          ),
                        )
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 20),
                        Text(
                          Helper().getDayMonthYear(training.timestamp.toDate()),
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color),
                        ),
                      ],
                    ),
                    onTap: () {
                      showDatePicker(
                              context: context,
                              initialDate: training.timestamp.toDate(),
                              firstDate: DateTime(2023, 1, 1),
                              lastDate: DateTime(2033, 12, 31))
                          .then((value) {
                        if (value != null) {
                          DateTime oldTime = training.timestamp.toDate();
                          value = value.add(Duration(
                              hours: oldTime.hour, minutes: oldTime.minute));
                          training.timestamp = Timestamp.fromDate(value);
                          db.refresh();
                        }
                      });
                    },
                  ),

                  // use time picker
                  ListTile(
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time),
                        const SizedBox(width: 20),
                        Text(
                          Helper().getHourMinute(training.timestamp.toDate()),
                          style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge!.color),
                        ),
                      ],
                    ),
                    onTap: () {
                      showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                  training.timestamp.toDate()))
                          .then((value) {
                        if (value != null) {
                          DateTime oldTime = training.timestamp.toDate();
                          oldTime = DateTime(oldTime.year, oldTime.month,
                              oldTime.day, 0, 0, 0, 0, 0);
                          DateTime newTime = oldTime.add(Duration(
                              hours: value.hour, minutes: value.minute));
                          training.timestamp = Timestamp.fromDate(newTime);
                          db.refresh();
                        }
                      });
                    },
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
                    if (group.id == '') {
                      // show snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nejdříve vyberte skupinu',
                              textAlign: TextAlign.center),
                          backgroundColor: Color(0xFFE57373),
                        ),
                      );
                      return;
                    }

                    if (create) {
                      db.createTraining(training);
                    } else {
                      db.updateTraining(training, db.isChangedTrainingGroup);
                      db.isChangedTrainingGroup = false;
                    }
                    db.refresh();
                    // show snackbar
                    Navigator.pop(context);
                    if (!create) {
                      Navigator.pop(context);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            create ? 'Trénink vytvořen' : 'Trénink upraven',
                            textAlign: TextAlign.center),
                        backgroundColor: const Color(0xFF81C784),
                      ),
                    );
                  },
                  child: const Text('Uložit', style: TextStyle(fontSize: 20)),
                ),
              ),
            ]),
          ),
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
    final noteController = TextEditingController(text: training.note);
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
                  // show dialog asking to refresh the training and set the attendance for everyone to false
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text(
                                'Opravdu chcete obnovit tento trénink?'),
                            content: const Text(
                                'Touto akcí se smaže veškerá docházka a obnoví se členové tréninku.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  db.updateTraining(training, true);
                                  db.refresh(); // set attendance to false for everyone and refresh members
                                  Navigator.pop(context);
                                  // show snackbar with orange color
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Trénink obnoven',
                                          textAlign: TextAlign.center),
                                      backgroundColor: Color(0xFFFFB74D),
                                    ),
                                  );
                                },
                                child: const Text('Obnovit'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Zrušit'),
                              ),
                            ],
                          ));
                },
                icon: const Icon(Icons.rotate_left)),
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(children: [
            Column(
              children: <Widget>[
                ListTile(
                  title: Text('Skupina: ${group.name}'),
                  trailing: Text(
                      '${training.dayAndMonth} ${training.year} - ${training.hourAndMinute}'),
                ),
                ListTile(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Poznámka: ',
                      ),
                      Expanded(
                          child: TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Poznámka',
                        ),
                        onChanged: (value) {
                          training.note = value;
                        },
                      ))
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 50),
                    itemCount: training.attendanceValues.length,
                    itemBuilder: (context, index) {
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
                          trailing: Checkbox(
                            tristate: true,
                            value: training.attendanceValues[index],
                            activeColor:
                                training.attendanceValues[index] == true
                                    ? Colors.green
                                    : Colors.yellow,
                            onChanged: ((value) {
                              training.attendanceValues[index] = value;
                              db.refresh();
                            }),
                          ),
                          title: db.isTrainer(training.attendanceKeys[index])
                              ? Text(
                                  db.getTrainerFullNameFromID(
                                      training.attendanceKeys[index]),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ) // the color should work
                              : Text(
                                  db.getMemberfullNameFromID(
                                      training.attendanceKeys[index]),
                                ),
                        ),
                      );
                    },
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
                  training.attendanceTaken = true;
                  db.updateTraining(training, false);
                  // write attendance data to members profile for easier access later TODO

                  db.refresh();
                  // show snackbar
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Docházka zapsána', textAlign: TextAlign.center),
                      backgroundColor: Color(0xFF81C784),
                    ),
                  );
                },
                child: const Text('Uložit', style: TextStyle(fontSize: 20)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
