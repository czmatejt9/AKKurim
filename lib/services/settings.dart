import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:ak_kurim/models/user.dart';
import 'package:ak_kurim/services/auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ak_kurim/services/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  final User user;
  const SettingsScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final auth = Provider.of<AuthService>(context);
    final ThemeService theme = Provider.of<ThemeService>(context);
    final oldPassword = TextEditingController();
    final newPassword = TextEditingController();
    final newPassword2 = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nastavení'),
        actions: <IconButton>[
          IconButton(
            icon: const Icon(
              Icons.brightness_4_outlined,
            ),
            onPressed: () {
              theme.changeTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              // alert dialog asking for confirmation if user wants to sync data
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Synchronizace dat'),
                    content: const Text(
                        'Opravdu chcete stáhnout aktuální data?\n(Data se automaticky stahují při spuštění aplikace)'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Zrušit'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Synchronizovat'),
                        onPressed: () {
                          Future.wait(<Future<void>>[
                            db.initializeData(user),
                          ]).then(
                            (List<void> results) {
                              // show snackbar
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      db.dataOnline
                                          ? 'Data byla úspěšně synchronizována'
                                          : 'Nepodařilo se synchronizovat data',
                                      textAlign: TextAlign.center),
                                  backgroundColor:
                                      db.dataOnline ? Colors.green : Colors.red,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: Theme.of(context).colorScheme.background,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                // create a button for bug report/feature request, launch db.bugReportPage
                ListTile(
                  title: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            // use secondary color from theme,
                            MaterialStateProperty.all<Color>(Colors.red),
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).colorScheme.onPrimary)),
                    onPressed: () {
                      launchUrl(Uri.parse(db.bugReportPage));
                    },
                    child: const Text(
                      'Nahlásit chybu/žádost o funkci',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                // change password
                Card(
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        const Text(
                          'Změna hesla',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: oldPassword,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Staré heslo',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: newPassword,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Nové heslo',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: newPassword2,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Nové heslo znovu',
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();

                            // check if old password is correct
                            // check if new passwords match
                            if (newPassword.text == newPassword2.text &&
                                newPassword.text.length > 5) {
                              // change password
                              // wait for result
                              Future.wait(<Future<String>>[
                                auth.changePassword(
                                    oldPassword.text, newPassword.text),
                              ]).then((List<String> results) {
                                // show snackbar

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(results[0],
                                      textAlign: TextAlign.center),
                                  backgroundColor:
                                      results[0] == 'Heslo bylo úspěšně změněno'
                                          ? Colors.green
                                          : Colors.red,
                                ));
                              });
                            } else {
                              // show snackbar
                              if (newPassword.text.length < 6) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                      'Nové heslo musí mít alespoň 6 znaků',
                                      textAlign: TextAlign.center),
                                  backgroundColor: Colors.red,
                                ));
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Nová hesla se neshodují',
                                      textAlign: TextAlign.center),
                                  backgroundColor: Colors.red,
                                ));
                              }
                            }
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  // use secondary color from theme,

                                  MaterialStateProperty.all<Color>(
                                      Theme.of(context).colorScheme.secondary),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Theme.of(context).colorScheme.onSecondary)),
                          child: const Text('Změnit heslo'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // show info about app after clicking on it show about dialog
                ListTile(
                  title: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            // use secondary color from theme,
                            MaterialStateProperty.all<Color>(
                                Theme.of(context).colorScheme.primary),
                        foregroundColor: MaterialStateProperty.all<Color>(
                            Theme.of(context).colorScheme.onPrimary)),
                    onPressed: () {
                      PackageInfo.fromPlatform()
                          .then((PackageInfo packageInfo) {
                        String appName = packageInfo.appName;
                        String version = packageInfo.version;
                        showAboutDialog(
                          context: context,
                          applicationName: appName,
                          applicationVersion: 'Verze $version',
                          applicationLegalese: '© 2023 Matěj Tajovský',
                        );
                      });
                    },
                    child: const Text(
                      'O aplikaci',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // back button on the bottom center
    );
  }
}
