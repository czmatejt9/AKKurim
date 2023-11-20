class Trainer {
  final String memberID;
  final String id;
  final String email;
  final int salary;
  String qualification;
  String lastBackgroundSync;

  Trainer({
    required this.memberID,
    required this.id,
    required this.email,
    required this.salary,
    required this.qualification,
    required this.lastBackgroundSync,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      memberID: json['member_id'],
      id: json['id'],
      email: json['email'],
      salary: json['salary'] ?? 0,
      qualification: json['qualification'] ?? '',
      lastBackgroundSync: json['last_background_sync'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberID,
      'id': id,
      'email': email,
      'salary': salary,
      'qualification': qualification,
      'last_background_sync': lastBackgroundSync,
    };
  }
}
