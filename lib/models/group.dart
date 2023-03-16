import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ak_kurim/services/helpers.dart';

class Group {
  final String id;
  List<dynamic> trainerIDs;
  String name;
  List<dynamic> memberIDs;

  Group(
      {required this.id,
      required this.trainerIDs,
      required this.name,
      required this.memberIDs});

  factory Group.fromMap(Map<dynamic, dynamic> data, String id) {
    return Group(
        id: id,
        trainerIDs: data['trainerIDs'],
        name: data['name'],
        memberIDs: data['memberIDs']);
  }

  factory Group.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Group.fromMap(data, doc.id);
  }

  factory Group.empty(String trainerID) {
    return Group(
        id: Helper().generateRandomString(20),
        trainerIDs: <dynamic>[trainerID],
        name: '',
        memberIDs: <dynamic>[]);
  }

  //note that the is IS NOT included in the map
  Map<String, dynamic> toMap() => {
        'trainerIDs': trainerIDs,
        'name': name,
        'memberIDs': memberIDs,
      };
}
