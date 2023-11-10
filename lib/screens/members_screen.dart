import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ak_kurim/services/database.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<DatabaseService>(context);
    if (database.members.isEmpty) {
      database.getMemberPreviews();
    }

    if (database.members.isNotEmpty) {
      return Container(
        color: const Color.fromRGBO(58, 66, 86, 1.0),
        child: Column(children: [
          const Text('Search bar here'),
          Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: database.members.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      elevation: 20.0,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 6.0),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.only(right: 12.0),
                          decoration: const BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      width: 1.0, color: Colors.white24))),
                          child: database.isTrainer(database.members[index].id)
                              ? const Icon(Icons.accessibility,
                                  color: Colors.white)
                              : const Icon(Icons.child_care,
                                  color: Colors.white),
                        ),
                        tileColor: const Color.fromRGBO(64, 75, 96, .8),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        title: Text(
                          database.members[index].fullName,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          database.members[index].birthYear,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }))
        ]),
      );
    } else {
      return const CircularProgressIndicator();
      // TODO return shimmer
    }
  }
}
