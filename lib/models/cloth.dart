class Cloth {
  final String id;
  final String size;
  final String clothTypeID;

  Cloth({
    required this.id,
    required this.size,
    required this.clothTypeID,
  });

  factory Cloth.fromJson(Map<String, dynamic> json) {
    return Cloth(
      id: json['id'],
      size: json['size'],
      clothTypeID: json['cloth_type_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'size': size,
      'cloth_type_id': clothTypeID,
    };
  }
}
