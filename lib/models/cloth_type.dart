class ClothType {
  final String id;
  final String name;
  final String? imagePath;
  final String gender;

  ClothType({
    required this.id,
    required this.name,
    this.imagePath,
    required this.gender,
  });

  factory ClothType.fromJson(Map<String, dynamic> json) {
    return ClothType(
        id: json['id'],
        name: json['name'],
        imagePath: json['image_src'],
        gender: json['gender']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'image_src': imagePath, 'gender': gender};
  }

  String toSQLVariables() {
    return "(id, name, image_src, gender) VALUES (?, ?, ?, ?)";
  }

  List toSQLValues() {
    return [id, name, imagePath, gender];
  }
}
