import 'package:ak_kurim/services/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';
import 'package:ak_kurim/services/auth.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:ak_kurim/services/navigation.dart';
import 'package:ak_kurim/services/theme.dart';
import 'package:ak_kurim/screens/actions_screen.dart';
import 'package:ak_kurim/screens/members_screen.dart';
import 'package:ak_kurim/screens/training_screen/training_screen_wrapper.dart';
import 'package:ak_kurim/screens/training_screen/attendance_screen.dart';
import 'package:ak_kurim/screens/training_screen/groups_screen.dart';
import 'package:ak_kurim/models/user.dart';
import 'package:ak_kurim/models/group.dart';
import 'package:ak_kurim/models/training.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  const HomeScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of<AuthService>(context);
    final ThemeService theme = Provider.of<ThemeService>(context);
    final DatabaseService db = Provider.of<DatabaseService>(context);

    final Widget homeScreen = (db.currentTrainer.lastName != '')
        ? Container(
            color: Theme.of(context).colorScheme.background,
            child: ListView(
              children: [
                Center(
                  child: Text(
                    'Vítejte ${db.currentTrainer.fullName}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                )
              ],
            ))
        : Container(
            color: Theme.of(context).colorScheme.background,
            child: const LinearProgressIndicator());

    final List<String> titles = <String>['Domů', 'Tréninky', 'Akce', 'Členové'];

    if (db.currentTrainer.lastName == '' ||
        db.currentTrainer.email != user.email) {
      db.initializeData(user);
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NavigationService>(
          create: (BuildContext context) => NavigationService(),
        ),
      ],
      child: Consumer<NavigationService>(
          builder: (BuildContext context, NavigationService navigation, child) {
        return DefaultTabController(
          length: 3,
          initialIndex: 0,
          child: Builder(builder: (context) {
            return Scaffold(
              appBar: AppBar(
                  title: Text(titles[navigation.currentIndex]),
                  actions: <IconButton>[
                    IconButton(
                        onPressed: () {
                          // alert dialog asking for confirmation if user wants to sync data
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Synchronizace dat'),
                                  content: const Text(
                                      'Opravdu chcete synchronizovat data?\n(Data se automaticky synchronizují při spuštění aplikace.)'),
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
                                        db.initializeData(user);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                        icon: const Icon(Icons.sync)),
                    IconButton(
                      icon: const Icon(
                        Icons.brightness_4_outlined,
                      ),
                      onPressed: () {
                        theme.changeTheme();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () {
                        // alert dialog asking for confirmation if user wants to logout
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Odhlášení'),
                                content:
                                    const Text('Opravdu se chcete odhlásit?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Zrušit'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Odhlásit'),
                                    onPressed: () {
                                      auth.signOut();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                      },
                    ),
                  ],
                  bottom: navigation.currentIndex == 1
                      ? const TabBar(
                          tabs: <Widget>[
                            Tab(
                              text: 'Docházka',
                            ),
                            Tab(
                              text: 'Skupiny',
                            ),
                            Tab(text: 'Statistiky')
                          ],
                        )
                      : null),
              // main body
              body: LazyLoadIndexedStack(
                index: navigation.currentIndex,
                children: <Widget>[
                  homeScreen,
                  const TrainingScreen(),
                  const ActionsScreen(),
                  const MembersScreen(),
                ],
              ),
              floatingActionButton: navigation.currentIndex != 0
                  ? FloatingActionButton(
                      onPressed: () {
                        if (navigation.currentIndex == 1 &&
                            DefaultTabController.of(context).index == 1) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupProfile(
                                  group: Group.empty(db.currentTrainer.id),
                                  create: true,
                                ),
                              ));
                        } else if (navigation.currentIndex == 1 &&
                            DefaultTabController.of(context).index == 0) {
                          if (db.trainerGroups.isNotEmpty) {
                            db.endDate = navigation.selectedDate
                                .add(const Duration(days: 29));
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TrainingProfile(
                                      // use selected date from navigation service and default time 17:00
                                      training: Training.empty(
                                        '',
                                        Timestamp.fromDate(
                                          Helper()
                                              .midnight(navigation.selectedDate)
                                              .add(const Duration(hours: 17)),
                                        ), // default time 17:00
                                      ),
                                      create: true),
                                ));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color(0xFFE57373),
                                content: Center(
                                    child: Text('Nejdříve vytvořte skupinu')),
                              ),
                            );
                          }
                        } else if (navigation.currentIndex == 1 &&
                            DefaultTabController.of(context).index == 2) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Aktualizovat statistiky?'),
                                  content: const Text(
                                      'Opravdu chcete aktualizovat statistiky?\n(Statistiky se automaticky aktualizují každý den)'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Zrušit'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('Aktualizovat'),
                                      onPressed: () {
                                        db.statsLoaded = false;
                                        db.statsLastUpdated = db
                                            .statsLastUpdated
                                            .subtract(const Duration(days: 1));
                                        db.updateStats();
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              });
                        }
                      },
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: const Icon(Icons.add),
                    )
                  : null,
              bottomNavigationBar: NavigationBar(
                selectedIndex: navigation.currentIndex,
                onDestinationSelected: (int index) {
                  navigation.currentIndex = index;
                  if (index == 2) {
                    db.filterMembers(filter: '');
                  }
                },
                destinations: const <NavigationDestination>[
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Domů',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.event_note_outlined),
                    selectedIcon: Icon(Icons.event_note),
                    label: 'Tréniky',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.emoji_events_outlined),
                    selectedIcon: Icon(Icons.emoji_events),
                    label: 'Akce',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.people_outlined),
                    selectedIcon: Icon(Icons.people),
                    label: 'Členové',
                  ),
                ],
              ),
            );
          }),
        );
      }),
    );
  }
}
