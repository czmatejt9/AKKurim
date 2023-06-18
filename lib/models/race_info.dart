import 'dart:math';

class RaceInfo {
  final String id;
  final String name;
  final String place;
  final String infoUrl;
  final List<String> racers;
  final List<String> racersWithDisciplines;
  final String schedule;
  final List<String> scheduleWithRacers;

  RaceInfo({
    required this.id,
    required this.name,
    required this.place,
    required this.infoUrl,
    required this.racers,
    required this.racersWithDisciplines,
    required this.schedule,
    required this.scheduleWithRacers,
  });

  factory RaceInfo.fromMap(Map<dynamic, dynamic> data) {
    return RaceInfo(
      id: data['id'],
      name: data['name'],
      place: data['place'],
      infoUrl: data['info_url'],
      racers: List<String>.from(data['racers']),
      racersWithDisciplines: List<String>.from(data['racers_with_disciplines']),
      schedule: data['schedule'],
      scheduleWithRacers: List<String>.from(data['schedule_with_racers']),
    );
  }

  factory RaceInfo.empty({String? error}) {
    return RaceInfo(
      id: '',
      name: '',
      place: '',
      infoUrl: error ?? '',
      racers: [],
      racersWithDisciplines: [],
      schedule: '',
      scheduleWithRacers: [],
    );
  }
}
