import 'package:flutter/material.dart';
import 'package:ak_kurim/main.dart';
import 'package:ak_kurim/services/navigation.dart';
import 'package:ak_kurim/services/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as spb;
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final navigation = Provider.of<NavigationService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("name here"),
        actions: [
          IconButton(
              onPressed: () => auth.logout(), icon: const Icon(Icons.logout))
        ],
      ),
      body: Placeholder(),
      bottomNavigationBar: NavigationBar(
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
  }
}
