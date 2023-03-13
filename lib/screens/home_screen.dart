import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lazy_load_indexed_stack/lazy_load_indexed_stack.dart';
import 'package:ak_kurim/services/auth.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:ak_kurim/services/navigation.dart';
import 'package:ak_kurim/services/theme.dart';
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
            child: Column(
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

    final List<String> titles = <String>['Domů', 'Tréninky', 'Členové'];

    if (db.currentTrainer.lastName == '') {
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
          length: 2,
          initialIndex: 0,
          child: Builder(builder: (context) {
            return Scaffold(
              appBar: AppBar(
                  title: Text(titles[navigation.currentIndex]),
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
                      icon: const Icon(Icons.logout),
                      onPressed: () {
                        auth.signOut();
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
                          ],
                        )
                      : null),
              // main body
              body: LazyLoadIndexedStack(
                index: navigation.currentIndex,
                children: <Widget>[
                  homeScreen,
                  const TrainingScreen(),
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
                            DefaultTabController.of(context).index == 0 &&
                            db.trainerGroups.isNotEmpty) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TrainingProfile(
                                    // use selected date from navigation service and default time 17:00
                                    training: Training.empty(
                                        db.trainerGroups[0].id,
                                        Timestamp.fromDate(navigation
                                            .selectedDate
                                            .add(const Duration(hours: 17)))),
                                    create: true),
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
