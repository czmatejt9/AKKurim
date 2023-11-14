import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:shimmer/shimmer.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<DatabaseService>(context);

    if (database.isInitialized && !database.isLoading) {
      return Container(
        color: const Color.fromRGBO(58, 66, 86, 1.0),
        child: Column(children: [
          const Text('Search bar here'), // TODO implement search bar
          Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: database.members.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2.0, horizontal: 4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(228, 79, 95, 123),
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0, 2),
                              blurRadius: 6.0,
                            ),
                          ],
                        ),
                        child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            leading: Container(
                              padding: const EdgeInsets.only(right: 12.0),
                              decoration: const BoxDecoration(
                                  border: Border(
                                      right: BorderSide(
                                          width: 1.0, color: Colors.white24))),
                              child:
                                  database.isTrainer(database.members[index].id)
                                      ? const Icon(Icons.accessibility,
                                          color: Colors.white)
                                      : const Icon(Icons.child_care,
                                          color: Colors.white),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            title: Text(
                              database.members[index].fullName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            trailing: Text(
                              database.members[index].birthYear,
                              style: const TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              // TODO go to member profile
                            }),
                      ),
                    );
                  }))
        ]),
      );
    } else {
      return Container(
        color: const Color.fromRGBO(58, 66, 86, 1.0),
        child: Column(children: [
          const Text('Search bar here'),
          Expanded(
              child: Shimmer.fromColors(
                  baseColor: Color.fromARGB(239, 128, 152, 194),
                  highlightColor: Color.fromARGB(238, 96, 119, 159),
                  period: const Duration(milliseconds: 800),
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: 10,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(228, 79, 95, 123),
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0, 2),
                                  blurRadius: 6.0,
                                ),
                              ],
                            ),
                            child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          right: BorderSide(
                                              width: 1.0,
                                              color: Colors.white24))),
                                  child: const Icon(Icons.child_care,
                                      color: Colors.white),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10.0),
                                title: Container(
                                  height: 10.0,
                                  width: 100.0,
                                  color: Colors.white,
                                ),
                                trailing: Container(
                                  height: 10.0,
                                  width: 100.0,
                                  color: Colors.white,
                                ),
                                onTap: () {
                                  // TODO go to member profile
                                }),
                          ),
                        );
                      })))
        ]),
      );
    }
  }
}
