import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:ak_kurim/services/database.dart';
import 'package:provider/provider.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const MyAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);

    return AppBar(
      elevation: 0.1,
      backgroundColor: const Color.fromRGBO(58, 66, 86, 1.0),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: db.isInitialized == false && db.isLoading == true
              ? const Icon(Icons.cloud_download, color: Colors.white)
              : db.count == null
                  ? const Icon(Icons.question_mark, color: Colors.white)
                  : db.hasInternet == true && db.count == 0
                      ? const Icon(
                          Icons.cloud_done,
                          color: Colors.green,
                        )
                      : db.hasInternet == true && db.count! > 0
                          ? badges.Badge(
                              badgeAnimation: const badges.BadgeAnimation.scale(
                                  toAnimate: false),
                              badgeStyle: const badges.BadgeStyle(
                                  badgeColor: Colors.blue),
                              badgeContent: Text(db.count.toString(),
                                  style: const TextStyle(color: Colors.white)),
                              child: const Icon(
                                Icons.cloud_upload,
                                color: Colors.yellow,
                              ),
                            )
                          : badges.Badge(
                              showBadge: db.count! > 0,
                              badgeAnimation: const badges.BadgeAnimation.scale(
                                  toAnimate: false),
                              badgeStyle: const badges.BadgeStyle(
                                  badgeColor: Colors.blue),
                              badgeContent: Text(db.count.toString(),
                                  style: const TextStyle(color: Colors.white)),
                              child: const Icon(
                                Icons.cloud_off,
                                color: Colors.red,
                              ),
                            ),
          onPressed: () {
            // show alert dialog with info about internet connection
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Sync status'),
                  content: Container(
                    height: 400,
                    width: double.maxFinite,
                    child: ListView(
                      children: <Widget>[
                        const ListTile(
                          leading:
                              Icon(Icons.cloud_download, color: Colors.white),
                          title: Text('Data se stahují'),
                        ),
                        const ListTile(
                          leading: Icon(Icons.cloud_done, color: Colors.green),
                          title: Text('Data synchronizována'),
                        ),
                        const ListTile(
                          leading: badges.Badge(
                            badgeAnimation:
                                badges.BadgeAnimation.scale(toAnimate: false),
                            badgeStyle:
                                badges.BadgeStyle(badgeColor: Colors.blue),
                            badgeContent: Text(
                              "1",
                            ),
                            child:
                                Icon(Icons.cloud_upload, color: Colors.yellow),
                          ),
                          title: Text('Probíhající synchronizace'),
                        ),
                        ListTile(
                          leading: badges.Badge(
                              badgeAnimation: const badges.BadgeAnimation.scale(
                                  toAnimate: false),
                              badgeStyle: const badges.BadgeStyle(
                                  badgeColor: Colors.blue),
                              badgeContent: Text(
                                db.count == 0 ? "1" : db.count.toString(),
                              ),
                              child: const Icon(Icons.cloud_off,
                                  color: Colors.red)),
                          title: const Text('Žádné připojení k internetu'),
                        ),
                        Text('Poslední synchronizace: ${db.lastSynced}'),
                        const Divider(),
                        const Text(
                            'Data se synchronizují automaticky při připojení k internetu.\nČíslo v kolečku označuje počet změn, které se ještě nesynchronizovaly.')
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
