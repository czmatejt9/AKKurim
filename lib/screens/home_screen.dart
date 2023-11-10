import 'package:flutter/material.dart';
import 'package:ak_kurim/main.dart';
import 'package:ak_kurim/services/navigation.dart';
import 'package:ak_kurim/services/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as spb;
import 'package:provider/provider.dart';
import 'package:ak_kurim/screens/members_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final navigation = Provider.of<NavigationService>(context);

    final List<Widget> screens = [
      const Placeholder(),
      const Placeholder(),
      const Placeholder(),
      const MembersScreen(),
    ];

    final List<String> titles = [
      'Domů',
      'Tréninky',
      'Akce',
      'Členové',
    ];

    return Scaffold(
      backgroundColor: const Color.fromRGBO(58, 66, 86, 1.0),
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: const Color.fromRGBO(58, 66, 86, 1.0),
        title: Text(
          titles[navigation.currentIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              auth.logout();
            },
          )
        ],
      ),
      body: screens[navigation.currentIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color.fromRGBO(58, 66, 86, 1.0),
        selectedIndex: navigation.currentIndex,
        onDestinationSelected: (int index) {
          navigation.currentIndex = index;
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
            label: 'Tréninky',
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
  }
}
