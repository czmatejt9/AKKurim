class Trainer {
  final String memberID;
  final String id;
  final String email;
  final int salary;
  String qualification;
  String bgSyncTime;

  Trainer({
    required this.memberID,
    required this.id,
    required this.email,
    required this.salary,
    required this.qualification,
    required this.bgSyncTime,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      memberID: json['member_id'],
      id: json['id'],
      email: json['email'],
      salary: json['salary'] ?? 0,
      qualification: json['qualification'] ?? '',
      bgSyncTime: json['bg_sync_time'] ?? '22:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberID,
      'id': id,
      'email': email,
      'salary': salary,
      'qualification': qualification,
      'bg_sync_time': bgSyncTime,
    };
  }
}
