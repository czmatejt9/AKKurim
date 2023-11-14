import 'package:flutter/material.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:provider/provider.dart';
import 'package:ak_kurim/services/navigation.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final nav = Provider.of<NavigationService>(context);
    final lightGrey = Colors.grey.shade400;
    final darkGrey = Colors.grey.shade500;
    return Drawer(
      child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text(
                  db.getTrainerFullName(memberID: db.currentTrainer!.memberID)),
            ),
            ListTile(
              tileColor:
                  nav.currentIndex == 0 ? Colors.blueGrey.shade800 : null,
              leading: Icon(
                Icons.home_outlined,
                color: lightGrey,
              ),
              title: Text(
                'Domů',
                style: TextStyle(color: lightGrey),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0),
              child: Text('Tréninky', style: TextStyle(color: darkGrey)),
            ),
            ListTile(
              leading: Icon(
                Icons.calendar_today_outlined,
                color: lightGrey,
              ),
              title: Text('Docházka', style: TextStyle(color: lightGrey)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.people_alt_outlined,
                color: lightGrey,
              ),
              title: Text('Skupiny', style: TextStyle(color: lightGrey)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ]),
    );
  }
}
