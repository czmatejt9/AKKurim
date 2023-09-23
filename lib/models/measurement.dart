import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ak_kurim/services/helpers.dart';

// TODO add author id (trainer id)
class Measurement {
  final String id;
  final String authorId;
  final Timestamp? createdAt;
  bool isRun;
  String name;
  String discipline;
  Map<String, dynamic> measurements = {};

  Measurement({
    required this.id,
    required this.authorId,
    this.createdAt,
    required this.isRun,
    required this.name,
    required this.discipline,
    required this.measurements,
  });

  factory Measurement.fromMap(Map<dynamic, dynamic> json) {
    return Measurement(
      id: json['id'],
      authorId: json['authorId'] ?? '',
      createdAt: json['createdAt'],
      isRun: json['isRun'],
      name: json['name'],
      discipline: json['discipline'],
      measurements: json['measurements'],
    );
  }

  factory Measurement.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return Measurement.fromMap(data);
  }

  factory Measurement.empty(authorId) {
    return Measurement(
      id: Helper().generateRandomString(20),
      authorId: authorId,
      createdAt: Timestamp.now(),
      isRun: false,
      name: '',
      discipline: '',
      measurements: {},
    );
  }

  // id not included
  Map<String, dynamic> toMap() => {
        'authorId': authorId,
        'createdAt': createdAt,
        'isRun': isRun,
        'name': name,
        'discipline': discipline,
        'measurements': measurements,
      };
}
