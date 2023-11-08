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
    final supabase = spb.Supabase.instance.client;

    return Scaffold(
        appBar: AppBar(
      title: Text(supabase.auth.currentUser!.email!),
      actions: [
        IconButton(
            onPressed: () => auth.logout(), icon: const Icon(Icons.logout))
      ],
    ));
  }
}
