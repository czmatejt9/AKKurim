class PieceOfCloth {
  final String id;
  final String clothID;
  final String? memberID;

  PieceOfCloth({
    required this.id,
    required this.clothID,
    this.memberID,
  });

  factory PieceOfCloth.fromJson(Map<String, dynamic> json) {
    return PieceOfCloth(
      id: json['id'],
      clothID: json['cloth_id'],
      memberID: json['member_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cloth_id': clothID,
      'member_id': memberID,
    };
  }

  String toSQLVariables() {
    return "(id, cloth_id, member_id) VALUES (?, ?, ?)";
  }

  List toSQLValues() {
    return [id, clothID, memberID];
  }
}
