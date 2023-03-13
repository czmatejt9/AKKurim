import 'package:ak_kurim/services/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Training {
  final String id;
  String groupID;
  String substituteTrainerID;
  Timestamp timestamp;
  bool attendanceTaken;
  Map<String, dynamic> attendance = {};
  String? note;

  Training(
      {required this.id,
      required this.groupID,
      required this.substituteTrainerID,
      required this.timestamp,
      required this.attendanceTaken,
      required this.attendance,
      required this.note});

  factory Training.fromMap(Map<dynamic, dynamic> data, String id) {
    return Training(
        id: id,
        groupID: data['groupID'],
        substituteTrainerID: data['substituteTrainerID'],
        timestamp: data['date'],
        attendanceTaken: data['attendanceTaken'],
        attendance: data['attendance'],
        note: data['note']);
  }

  get attendanceNumber => attendance.length;
  get attendingNumber => attendance.values.where((e) => e == true).length;

  factory Training.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Training.fromMap(data, doc.id);
  }

  factory Training.empty(
    String groupId,
    Timestamp timestamp,
  ) {
    return Training(
        id: Helper().generateRandomString(20),
        groupID: groupId,
        substituteTrainerID: '',
        timestamp: timestamp,
        attendanceTaken: false,
        attendance: {},
        note: '');
  }

  //note that the is IS NOT included in the map
  Map<String, dynamic> toMap() => {
        'groupID': groupID,
        'substituteTrainerID': substituteTrainerID,
        'date': timestamp,
        'attendance': attendance,
        'attendanceTaken': attendanceTaken,
        'note': note,
      };
}
