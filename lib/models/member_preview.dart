class MemberPreview {
  final String id;
  final String firstName;
  final String lastName;
  final String birthNumber;

  String get fullName => '$firstName $lastName';
  String get birthYear {
    if (int.parse(birthNumber.substring(0, 2)) > 40) {
      return '19${birthNumber.substring(0, 2)}';
    }
    return '20${birthNumber.substring(0, 2)}';
  }

  MemberPreview({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthNumber,
  });

  factory MemberPreview.fromJson(Map<String, dynamic> json) {
    return MemberPreview(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      birthNumber: json['birth_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'birth_number': birthNumber,
    };
  }
}
