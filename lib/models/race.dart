import 'package:ak_kurim/services/helpers.dart';
import 'package:flutter/material.dart';

class Race {
  String id;
  String name;
  String? description;
  String datetimeStart;
  String datetimeEnd;
  int sync;
  String place;

  Race({
    required this.id,
    required this.name,
    required this.description,
    required this.datetimeStart,
    required this.datetimeEnd,
    required this.sync,
    required this.place,
  });

  factory Race.fromJson(Map<String, dynamic> json) {
    return Race(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      datetimeStart: json['datetime_start'],
      datetimeEnd: json['datetime_end'],
      sync: json['sync'],
      place: json['place'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'datetime_start': datetimeStart,
        'datetime_end': datetimeEnd,
        'sync': sync,
        'place': place,
      };

  bool isInProgress() {
    final DateTime raceTimeStart = DateTime.parse(datetimeStart);
    final DateTime raceTimeEnd = DateTime.parse(datetimeEnd);
    final DateTime now = DateTime.now();
    return Helper.midnight(raceTimeStart).isBefore(now) &&
        now.isBefore(raceTimeEnd);
  }
}
