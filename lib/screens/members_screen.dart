import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:ak_kurim/models/member.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
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
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Filtr'),
                              content:
                                  StatefulBuilder(builder: (context, setState) {
                                // ignore: sized_box_for_whitespace
                                return Container(
                                  width: double.maxFinite,
                                  height: 300,
                                  child: ListView(
                                    children: <Widget>[
                                      CheckboxListTile(
                                        title: const Text('Rok narození'),
                                        value: db.filterBornYear,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            db.filterBornYear = value!;
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
                                              member:
                                                  db.filteredMembers[index])),
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
      ),
    );
  }
}

// TODO add delete member button and create member and edit member button to member profile
// TODO after that try to show PB and SB in member profile
class MemberProfile extends StatelessWidget {
  final Member member;
  const MemberProfile({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final controllers = <String, TextEditingController>{};
    member.borrowedItems.forEach((key, value) {
      controllers[key] = TextEditingController(text: value);
    });
    // show member profile
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil člena'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO edit member
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Opravdu chcete smazat ${member.fullName}?'),
                      content: const Text('Tato akce je nevratná!'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            db.deleteMember(member);
                            Navigator.pop(context);
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
                    );
                  });
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Center(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  //show alert dialog with member address
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
              Text(
                member.fullName,
                style: const TextStyle(fontSize: 26),
                textAlign: TextAlign.center,
              ),
              Text(member.bornDate,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center),
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
              Row(
                children: [
                  const Text('Půjčené věci', style: TextStyle(fontSize: 24)),
                  const Spacer(),
                  // button for saving borrowed items (text Button)
                  ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).colorScheme.secondary),
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).colorScheme.onSecondary),
                      ),
                      onPressed: () {
                        db.updateMember(member);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Půjčené věci byly uloženy do databáze',
                              textAlign: TextAlign.center),
                          backgroundColor: Color(0xFF81C784),
                        ));
                      },
                      child: const Text('Uložit')),
                ],
              ),
              for (var item in member.borrowedItems.keys)
                Row(
                  children: <Widget>[
                    Text(item,
                        style: const TextStyle(fontSize: 18),
                        textAlign: TextAlign.center),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: controllers[item],
                        onChanged: (value) {
                          member.borrowedItems[item] = value;
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              const Text('PB', style: TextStyle(fontSize: 24)),
              const Text('Comin Soon', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              const Text('Účast na závodech', style: TextStyle(fontSize: 24)),
              Text('2021: ${member.r2021}',
                  style: const TextStyle(fontSize: 18)),
              Text('2022: ${member.r2022}',
                  style: const TextStyle(fontSize: 18)),
              Text('2023: ${member.r2023}',
                  style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
