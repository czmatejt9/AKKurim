import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:ak_kurim/models/group.dart';

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
                        subtitle: Text(
                            db.trainerGroups[index].trainerIDs
                                .map((e) => db.getTrainerfullNameFromID(e))
                                .join(', '),
                            style: const TextStyle(fontSize: 12)),
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
                              builder: (context) =>
                                  GroupProfile(group: db.trainerGroups[index]),
                            ),
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
                      title: const Text('Opravdu chcete smazat tuto skupinu?'),
                      content: const Text('Tato akce je nevratná.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            if (!create) {
                              db.deleteGroup(group);
                            }
                            db.refresh();
                            // show snackbar
                            Navigator.pop(context);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Skupina smazána',
                                    textAlign: TextAlign.center),
                                // use the same color as in attendance_screen
                                backgroundColor: Color(0xFFE57373),
                              ),
                            );
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
                    )),
              );
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
                decoration: const InputDecoration(
                  hintText: 'Název skupiny',
                ),
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
                // show snackbar
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        create ? 'Skupina vytvořena' : 'Skupina upravena',
                        textAlign: TextAlign.center),
                    // use the same color as in attendance_screen
                    backgroundColor: const Color(0xFF81C784),
                  ),
                );
              },
              child: const Text('Uložit', style: TextStyle(fontSize: 20)),
            ),
          ),
        ]),
      ),
    );
  }
}

class AddScreen extends StatelessWidget {
  // for members or trainers into group
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
