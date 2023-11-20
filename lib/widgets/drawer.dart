import 'package:flutter/material.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:provider/provider.dart';
import 'package:ak_kurim/services/navigation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ak_kurim/services/auth.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final nav = Provider.of<NavigationService>(context);
    final AuthService auth = Provider.of<AuthService>(context, listen: false);
    final lightGrey = Colors.grey.shade400;
    final darkGrey = Colors.grey.shade500;
    return Drawer(
      child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                child: Row(
              children: [
                Text(db.currentTrainer != null
                    ? db.getMemberFullName(
                        memberID: db.currentTrainer!.memberID)
                    : 'Načítání'),
                const Spacer(),
                IconButton(
                    onPressed: () {
                      auth.refreshSession();
                    },
                    icon: const Icon(Icons.refresh)),
                const SizedBox(width: 10),
                IconButton(
                    onPressed: () {
                      auth.logout_();
                    },
                    icon: const Icon(Icons.logout))
              ],
            )),
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
                nav.currentIndex = 0;
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0),
              child: Text('Tréninky', style: TextStyle(color: darkGrey)),
            ),
            ListTile(
              tileColor:
                  nav.currentIndex == 1 ? Colors.blueGrey.shade800 : null,
              leading: Icon(
                Icons.calendar_today_outlined,
                color: lightGrey,
              ),
              title: Text('Docházka', style: TextStyle(color: lightGrey)),
              onTap: () {
                Navigator.pop(context);
                nav.currentIndex = 1;
              },
            ),
            ListTile(
              tileColor:
                  nav.currentIndex == 2 ? Colors.blueGrey.shade800 : null,
              leading: Icon(
                Icons.people_alt_outlined,
                color: lightGrey,
              ),
              title: Text('Skupiny', style: TextStyle(color: lightGrey)),
              onTap: () {
                Navigator.pop(context);
                nav.currentIndex = 2;
              },
            ),
            ListTile(
              tileColor:
                  nav.currentIndex == 3 ? Colors.blueGrey.shade800 : null,
              leading: Icon(
                Icons.query_stats,
                color: lightGrey,
              ),
              title: Text('Statistiky', style: TextStyle(color: lightGrey)),
              onTap: () {
                Navigator.pop(context);
                nav.currentIndex = 3;
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0),
              child: Text('Správa', style: TextStyle(color: darkGrey)),
            ),
            ListTile(
              tileColor:
                  nav.currentIndex == 4 ? Colors.blueGrey.shade800 : null,
              leading: FaIcon(
                FontAwesomeIcons.shirt,
                color: lightGrey,
              ),
              title: Text('Oblečení', style: TextStyle(color: lightGrey)),
              onTap: () {
                Navigator.pop(context);
                nav.currentIndex = 4;
              },
            ),
          ]),
    );
  }
}
