import 'package:flutter/material.dart';
import 'package:ak_kurim/screens/training_screen/attendance_screen.dart';
import 'package:ak_kurim/screens/training_screen/groups_screen.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: <Widget>[
        AttendanceScreen(),
        GroupsScreen(),
      ],
    );
  }
}
