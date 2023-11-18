class ClothType {
  final String id;
  final String name;
  final String? imagePath;
  final String gender;
  final int isBorrowable;

  ClothType({
    required this.id,
    required this.name,
    this.imagePath,
    required this.gender,
    this.isBorrowable = 0,
  });

  factory ClothType.fromJson(Map<String, dynamic> json) {
    return ClothType(
        id: json['id'],
        name: json['name'],
        imagePath: json['image_src'],
        gender: json['gender'],
        isBorrowable: json['is_borrowable'] != null
            ? int.parse(json['is_borrowable'])
            : 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_src': imagePath,
      'gender': gender,
      'is_borrowable': isBorrowable
    };
  }

  String toSQLVariables() {
    return "(id, name, image_src, gender, is_borrowable) VALUES (?, ?, ?, ?, ?)";
  }

  List toSQLValues() {
    return [id, name, imagePath, gender, isBorrowable];
  }
}
