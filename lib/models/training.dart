import 'package:ak_kurim/services/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Training {
  final String id;
  String groupID;
  String substituteTrainerID;
  Timestamp timestamp;
  bool attendanceTaken;
  // split the map into two lists, one for keys and one for values, because
  // the map is not ordered and we need to keep the order of the keys
  List<dynamic> attendanceKeys;
  List<dynamic> attendanceValues;
  String? note;

  Training(
      {required this.id,
      required this.groupID,
      required this.substituteTrainerID,
      required this.timestamp,
      required this.attendanceTaken,
      required this.attendanceKeys,
      required this.attendanceValues,
      required this.note});

  factory Training.fromMap(Map<dynamic, dynamic> data, String id) {
    return Training(
        id: id,
        groupID: data['groupID'],
        substituteTrainerID: data['substituteTrainerID'],
        timestamp: data['date'],
        attendanceTaken: data['attendanceTaken'],
        attendanceKeys: data['attendanceKeys'],
        attendanceValues: data['attendanceValues'],
        note: data['note']);
  }

  factory Training.copy(Training training) {
    return Training(
        id: Helper().generateRandomString(20),
        groupID: training.groupID,
        substituteTrainerID: training.substituteTrainerID,
        timestamp: training.timestamp,
        attendanceTaken: training.attendanceTaken,
        attendanceKeys: training.attendanceKeys,
        attendanceValues: training.attendanceValues,
        note: training.note);
  }

  int get attendanceNumber => attendanceValues.length;
  int get attendingNumber => attendanceValues
      .where((e) => e == true)
      .length; // == true is used because the values are bool? (nullable)

  String get hourAndMinute => Helper().getHourMinute(timestamp.toDate());
  String get dayAndMonth => Helper().getDayMonth(timestamp.toDate());
  int get year => timestamp.toDate().year;

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
        attendanceKeys: [],
        attendanceValues: [],
        note: '');
  }

  //note that the is IS NOT included in the map
  Map<String, dynamic> toMap() => {
        'groupID': groupID,
        'substituteTrainerID': substituteTrainerID,
        'date': timestamp,
        'attendanceKeys': attendanceKeys,
        'attendanceValues': attendanceValues,
        'attendanceTaken': attendanceTaken,
        'note': note,
      };
}
