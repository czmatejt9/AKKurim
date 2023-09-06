import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:ak_kurim/models/member.dart';
import 'package:table_calendar/table_calendar.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);

    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.background,
              child: TextField(
                onChanged: (value) {
                  db.searchString = value;
                  db.filterMembers(filter: value, sort: true);
                },
                decoration: InputDecoration(
                  hintText: 'Hledat',
                  suffixIcon: IconButton(
                    icon: Icon(db.filterBornYear
                        ? Icons.filter_list
                        : Icons.filter_list_off),
                    onPressed: () {
                      //TODO show filter dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          bool _filterBornYear = db.filterBornYear;
                          bool _ascendingOrder = db.ascendingOrder;
                          return AlertDialog(
                            title: const Text('Filtr'),
                            content:
                                StatefulBuilder(builder: (context, setState) {
                              return Container(
                                width: double.maxFinite,
                                height: 300,
                                child: ListView(
                                  children: <Widget>[
                                    CheckboxListTile(
                                      title: const Text('Rok narození'),
                                      value: _filterBornYear,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _filterBornYear = value!;
                                          db.filterBornYear = value;
                                        });
                                      },
                                    ),
                                    if (db.filterBornYear)
                                      RadioListTile(
                                          title: const Text('Vzestupně'),
                                          value: true,
                                          groupValue: db.ascendingOrder,
                                          onChanged: (value) {
                                            setState(() {
                                              _ascendingOrder = true;
                                              db.ascendingOrder = true;
                                            });
                                          }),
                                    if (db.filterBornYear)
                                      RadioListTile(
                                          title: const Text('Sestupně'),
                                          value: false,
                                          groupValue: db.ascendingOrder,
                                          onChanged: (value) {
                                            setState(() {
                                              _ascendingOrder = false;
                                              db.ascendingOrder = false;
                                            });
                                          }),
                                  ],
                                ),
                              );
                            }),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Použít'),
                              ),
                            ],
                          );
                        },
                      ).then((value) {
                        db.filterMembers(filter: db.searchString, sort: true);
                        db.refresh();
                      });
                    },
                  ),
                ),
              ),
            ),
            if (db.members.isNotEmpty && !db.isUpdating)
              ChangeNotifierProvider(
                create: (_) => db,
                child: Expanded(
                  child: db.filteredMembers.isNotEmpty
                      ? ListView.builder(
                          padding: const EdgeInsets.only(bottom: 76),
                          itemCount: db.filteredMembers.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              elevation: 10,
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MemberProfile(
                                            member: db.filteredMembers[index])),
                                  );
                                },
                                title: Text(
                                    '${db.filteredMembers[index].lastName} ${db.filteredMembers[index].firstName}'),
                                trailing:
                                    Text(db.filteredMembers[index].bornYear),
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                          'Nenalen žádný člen',
                          style: TextStyle(fontSize: 20),
                        )),
                ),
              ),
            if (db.isUpdating)
              Column(
                children: const <Widget>[
                  // draw boxes like shimmer effect with dark background
                  SizedBox(height: 10),
                  Text('Načítám členy'),
                  SizedBox(height: 10),
                  LinearProgressIndicator(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

//TODO change the screen to show the member profile
class MemberProfile extends StatelessWidget {
  final Member member;
  const MemberProfile({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    // show member profile
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil - ${member.lastName} ${member.firstName}'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                //show alert dialog with member address¨
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Adresa'),
                      content: Text(member.address,
                          style: const TextStyle(fontSize: 18)),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Zavřít'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  child: Text(member.initials)),
            ),
            const SizedBox(height: 10),
            Text(member.fullName, style: const TextStyle(fontSize: 26)),
            Text(member.bornDate, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text('Kontakty', style: TextStyle(fontSize: 24)),
            Text('email: ${member.email}',
                style: const TextStyle(fontSize: 18)),
            Text('email rodičů: ${member.emailParent}',
                style: const TextStyle(fontSize: 18)),
            Text('číslo: ${member.phone}',
                style: const TextStyle(fontSize: 18)),
            Text('číslo rodičů: ${member.phoneParent}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text('Účast na závodech', style: TextStyle(fontSize: 24)),
            Text('2021: ${member.r2021}', style: const TextStyle(fontSize: 18)),
            Text('2022: ${member.r2022}', style: const TextStyle(fontSize: 18)),
            Text('2023: ${member.r2023}', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
