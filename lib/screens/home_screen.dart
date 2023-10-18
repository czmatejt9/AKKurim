import 'package:ak_kurim/models/member.dart';
import 'package:ak_kurim/services/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';
import 'package:ak_kurim/services/auth.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:ak_kurim/services/navigation.dart';
import 'package:ak_kurim/screens/actions_screen.dart';
import 'package:ak_kurim/screens/members_screen.dart';
import 'package:ak_kurim/screens/training_screen/training_screen_wrapper.dart';
import 'package:ak_kurim/screens/training_screen/attendance_screen.dart';
import 'package:ak_kurim/screens/training_screen/groups_screen.dart';
import 'package:ak_kurim/models/user.dart';
import 'package:ak_kurim/models/group.dart';
import 'package:ak_kurim/models/training.dart';
import 'package:ak_kurim/services/settings.dart';
import 'package:ak_kurim/screens/measurements_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  const HomeScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of<AuthService>(context);
    final DatabaseService db = Provider.of<DatabaseService>(context);

    final List<String> titles = <String>[
      db.currentTrainer.fullName,
      'Tréninky',
      'Měření',
      'Závody',
      'Členové (${db.members.length})',
    ];

    final Widget homeScreen = (db.currentTrainer.lastName != '' &&
            db.nextWeekLoaded)
        ? Container(
            color: Theme.of(context).colorScheme.background,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  if (db.isNewUpdate)
                    GestureDetector(
                      onTap: () {
                        launchUrl(Uri.parse(db.releasesPage));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Theme.of(context).colorScheme.secondary,
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.info_outline),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'K dispozici je aktualizace. Klikněte pro otevření stránky s novou verzí aplikace.',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text('Vaše nadcházející tréninky',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 10),
                  const NextWeekTrainings(),
                ],
              ),
            ),
          )
        : Container(
            color: Theme.of(context).colorScheme.background,
            child: const Center(child: CircularProgressIndicator()));

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
                        // push settings screen as a new screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SettingsScreen(user: user)),
                        );
                      },
                      icon: const Icon(Icons.settings),
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
                  const MeasurementsScreen(),
                  const ActionsScreen(),
                  const MembersScreen(),
                ],
              ),
              floatingActionButton: navigation.currentIndex == 1 ||
                      navigation.currentIndex == 4
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
                            db.endDate = navigation.selectedDate;
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
                        } else if (navigation.currentIndex == 4) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MemberEdit(
                                  member: Member.empty(),
                                  create: true,
                                ),
                              ));
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
                    db.filterMembers(filter: '', sort: true);
                    db.refresh();
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
                      icon: Icon(Icons.timer_outlined),
                      selectedIcon: Icon(Icons.timer),
                      label: 'Měření'),
                  NavigationDestination(
                    icon: Icon(Icons.emoji_events_outlined),
                    selectedIcon: Icon(Icons.emoji_events),
                    label: 'Závody',
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

class NextWeekTrainings extends StatelessWidget {
  const NextWeekTrainings({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    return db.nextWeekTrainings.isNotEmpty
        ? Column(children: <Widget>[
            for (var training in db.nextWeekTrainings)
              Column(children: <Widget>[
                // display the below container only if the previous training is not in the same day
                if (db.nextWeekTrainings.indexOf(training) == 0 ||
                    !Helper().isSameDay(
                        db
                            .nextWeekTrainings[
                                db.nextWeekTrainings.indexOf(training) - 1]
                            .timestamp
                            .toDate(),
                        training.timestamp.toDate()))
                  Container(
                    padding: const EdgeInsets.only(left: 16, top: 16),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      Helper().getCzechDayAndDate(training.timestamp.toDate()),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                TrainingCard(
                  training: training,
                ),
              ])
          ])
        : SizedBox(
            height: 200,
            child: Center(
              child: Text('Žádné tréninky v příštím týdnu',
                  style: Theme.of(context).textTheme.headlineSmall),
            ),
          );
  }
}
