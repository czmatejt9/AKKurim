class Trainer {
  final String member_id;
  final int id;
  final String email;

  Trainer({
    required this.member_id,
    required this.id,
    required this.email,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      member_id: json['member_id'],
      id: json['id'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': member_id,
      'id': id,
      'email': email,
    };
  }
}
