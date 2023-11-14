class Trainer {
  final String memberID;
  final int id;
  final String email;
  final int salary;
  String qualification;

  Trainer({
    required this.memberID,
    required this.id,
    required this.email,
    required this.salary,
    required this.qualification,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      memberID: json['member_id'],
      id: json['id'],
      email: json['email'],
      salary: json['salary'],
      qualification: json['qualification'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberID,
      'id': id,
      'email': email,
      'salary': salary,
      'qualification': qualification,
    };
  }
}
