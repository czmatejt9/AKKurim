import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:ak_kurim/models/member.dart';

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
                onChanged: (value) => db.filterMembers(filter: value),
                decoration: const InputDecoration(
                    hintText: 'Hledat', suffixIcon: Icon(Icons.search)),
              ),
            ),
            Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.background,
                child: const Text('')),
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
            CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                child: Text(member.initials)),
            Text(member.fullName),
            Text('email: ${member.email}'),
            Text('email rodičů: ${member.emailParent}'),
            Text('číslo: ${member.phone}'),
            Text('číslo rodičů: ${member.phoneParent}'),
          ],
        ),
      ),
    );
  }
}
