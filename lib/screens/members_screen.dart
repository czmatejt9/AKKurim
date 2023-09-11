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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemberEdit(member: member),
                ),
              );
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
                            db.refresh();
                            Navigator.pop(context);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Člen byl smazán',
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
              if (member.pb == "")
                const Text('PB nenalezeny', style: TextStyle(fontSize: 18)),
              for (var item in member.pb.split('\n'))
                Text(item,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
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

class MemberEdit extends StatelessWidget {
  final bool create;
  final Member member;
  const MemberEdit({super.key, required this.member, this.create = false});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    return Scaffold(
      appBar: AppBar(
        title:
            create ? const Text('Přidat člena') : const Text('Upravit člena'),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: ListView(
              children: [
                Row(
                  children: [
                    const Text("Jméno: "),
                    Expanded(
                      child: TextFormField(
                        initialValue: member.firstName,
                        keyboardType: TextInputType.name,
                        onChanged: (value) {
                          member.firstName = value;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("Příjmení: "),
                    Expanded(
                      child: TextFormField(
                        initialValue: member.lastName,
                        keyboardType: TextInputType.name,
                        onChanged: (value) {
                          member.lastName = value;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("Rodné číslo: "),
                    Expanded(
                      child: TextFormField(
                        initialValue: member.birthNumber,
                        keyboardType: TextInputType.datetime,
                        onChanged: (value) {
                          member.birthNumber = value;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("EAN: "),
                    Expanded(
                      child: TextFormField(
                        initialValue: member.ean,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          member.ean = value;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text("Ulice + ČP: "),
                    Expanded(
                      child: TextFormField(
                        initialValue: member.street,
                        keyboardType: TextInputType.streetAddress,
                        onChanged: (value) {
                          member.street = value;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("Město: "),
                    Expanded(
                      child: TextFormField(
                        initialValue: member.city,
                        onChanged: (value) {
                          member.city = value.trim();
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("PSČ: "),
                    Expanded(
                      child: TextFormField(
                        initialValue: member.zip,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          member.zip = value;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text("Email: "),
                    Expanded(
                      child: TextFormField(
                        initialValue: member.email,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          member.email = value;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("Email rodičů: "),
                    Expanded(
                      child: TextFormField(
                        initialValue: member.emailParent,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          member.emailParent = value;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("Telefon: "),
                    Expanded(
                      child: TextFormField(
                        initialValue: member.phone,
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          member.phone = value;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("Telefon rodičů: "),
                    Expanded(
                      child: TextFormField(
                        initialValue: member.phoneParent,
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          member.phoneParent = value;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
              ],
            ),
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
                if (member.firstName == "" || member.lastName == "") {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Jméno a příjmení musí být vyplněno',
                          textAlign: TextAlign.center),
                      backgroundColor: Color(0xFFE57373),
                    ),
                  );
                  return;
                } else if (member.birthNumber == "" ||
                    member.birthNumber.length < 9) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Rodné číslo musí být vyplněno',
                        textAlign: TextAlign.center),
                    backgroundColor: Color(0xFFE57373),
                  ));
                  return;
                } else if (member.street == "" ||
                    member.city == "" ||
                    member.zip == "") {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Adresa musí být vyplněna',
                        textAlign: TextAlign.center),
                    backgroundColor: Color(0xFFE57373),
                  ));
                  return;
                } else if (member.email == "" && member.emailParent == "") {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Alespoň jeden email musí být vyplněn',
                        textAlign: TextAlign.center),
                    backgroundColor: Color(0xFFE57373),
                  ));
                  return;
                } else if (member.phone == "" && member.phoneParent == "") {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Alespoň jeden telefon musí být vyplněn',
                        textAlign: TextAlign.center),
                    backgroundColor: Color(0xFFE57373),
                  ));
                  return;
                }

                if (create) {
                  db.createMember(member);
                } else {
                  db.updateMember(member);
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(create ? 'Člen vytvořen' : 'Člen upraven',
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
    );
  }
}
