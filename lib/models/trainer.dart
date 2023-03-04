import 'package:cloud_firestore/cloud_firestore.dart';

class Trainer {
  final String id;
  final String memberID;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  Trainer(
      {required this.id,
      required this.memberID,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.phone});

  get fullName => '$lastName $firstName';

  factory Trainer.fromMap(Map<dynamic, dynamic> data, String id) {
    return Trainer(
        id: id,
        memberID: data['memberID'],
        firstName: data['firstName'],
        lastName: data['lastName'],
        email: data['email'],
        phone: data['phone']);
  }

  factory Trainer.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Trainer.fromMap(data, doc.id);
  }

  //note that the is IS NOT included in the map
  Map<String, dynamic> toMap() => {
        'memberID': memberID,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
      };
}
