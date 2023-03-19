import 'package:ak_kurim/screens/training_screen/attendance_screen.dart';
import 'package:ak_kurim/models/group.dart';
import 'package:flutter/material.dart';
import 'package:ak_kurim/models/training.dart';
import 'package:provider/provider.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:ak_kurim/services/helpers.dart';

class TrainingCard extends StatelessWidget {
  final Training training;
  const TrainingCard({super.key, required this.training});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    Group group = db.getGroupFromID(training.groupID);
    String names = group.trainerIDs.map((id) {
      return db.getTrainerFullNameFromID(id);
    }).join(', ');
    if (training.substituteTrainerID != '') {
      names += ', ${db.getTrainerFullNameFromID(training.substituteTrainerID)}';
    }
    return Card(
      elevation: 10,
      child: ListTile(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        onTap: () {
          // push to take attendance screen
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TakeAttendance(training: training),
              ));
        },
        title: Text(
            '${Helper().getHourMinute(training.timestamp.toDate())} - ${db.getGroupNameFromID(training.groupID)}'),
        subtitle: Text(names, style: const TextStyle(fontSize: 10)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${training.attendingNumber}/${training.attendanceNumber}'),
            const Icon(Icons.people),
            training.attendanceTaken
                ? const Icon(Icons.check, color: Colors.green)
                : const Icon(Icons.close, color: Colors.red)
          ],
        ),
      ),
    );
  }
}
