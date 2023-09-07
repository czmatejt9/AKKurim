class RaceResult {
  final String id;
  final String place;
  final List<String> results;

  RaceResult({
    required this.id,
    required this.place,
    required this.results,
  });

  factory RaceResult.fromMap(Map<dynamic, dynamic> data) {
    return RaceResult(
      id: data['id'],
      place: data['place'],
      results: List<String>.from(data['results']),
    );
  }

  factory RaceResult.empty({String? error}) {
    return RaceResult(
      id: '',
      place: '',
      results: [],
    );
  }
}
