import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ak_kurim/services/helpers.dart';

class Measurement {
  final String id;
  bool isRun;
  String name;
  String discipline;
  Map<String, String> measurements = {};

  Measurement({
    required this.id,
    required this.isRun,
    required this.name,
    required this.discipline,
    required this.measurements,
  });

  factory Measurement.fromMap(Map<dynamic, dynamic> json) {
    return Measurement(
      id: json['id'],
      isRun: json['isRun'],
      name: json['name'],
      discipline: json['discipline'],
      measurements: json['measurements'],
    );
  }

  factory Measurement.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Measurement.fromMap(data);
  }

  factory Measurement.empty() {
    return Measurement(
      id: Helper().generateRandomString(20),
      isRun: false,
      name: '',
      discipline: '',
      measurements: {},
    );
  }

  // id not included
  Map<String, dynamic> toMap() => {
        'isRun': isRun,
        'name': name,
        'discipline': discipline,
        'measurements': measurements,
      };
}
