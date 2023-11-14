import 'package:flutter/material.dart';
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
          icon: db.hasInternet == true
              ? const Icon(
                  Icons.cloud_done,
                  color: Colors.green,
                )
              : db.hasInternet == false
                  ? const Icon(
                      Icons.cloud_off,
                      color: Colors.red,
                    )
                  : const Icon(
                      Icons.question_mark,
                      color: Colors.white,
                    ),
          onPressed: () {
            // TODO
          },
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
