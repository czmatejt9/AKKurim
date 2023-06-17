import 'package:cloud_firestore/cloud_firestore.dart';

class RacePreview {
  final String name;
  final String id;
  final Timestamp timestamp;
  final String place;
  final String clubname;
  final List<dynamic> members;

  RacePreview(
      {required this.name,
      required this.id,
      required this.timestamp,
      this.place = '',
      this.clubname = '',
      this.members = const []});

  factory RacePreview.fromMap(Map data) {
    return RacePreview(
      name: data['name'],
      id: data['id'],
      // THE VALUE IN THE MAP IS DOUBLE, NOT TIMESTAMP
      timestamp: Timestamp.fromDate(
        DateTime.fromMillisecondsSinceEpoch(data['timestamp'].round() * 1000),
      ),
      place: data['place'],
      clubname: data['clubname'],
      members: data['members'],
    );
  }
}
