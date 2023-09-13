class RaceResult {
  final String id;
  final String place;
  final List<String> names;
  final List<String> results;

  RaceResult({
    required this.id,
    required this.place,
    required this.names,
    required this.results,
  });

  factory RaceResult.fromMap(Map<dynamic, dynamic> data) {
    return RaceResult(
      id: data['id'],
      place: data['place'],
      names: List<String>.from(data['names']),
      results: List<String>.from(data['results']),
    );
  }

  factory RaceResult.empty({String? error}) {
    return RaceResult(
      id: error ?? '',
      place: '',
      names: [],
      results: [],
    );
  }
}
