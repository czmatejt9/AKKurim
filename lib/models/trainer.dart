import 'package:cloud_firestore/cloud_firestore.dart';

class Trainer {
  final String id;
  final String memberID;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String salutation;

  Trainer(
      {required this.id,
      required this.memberID,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.phone,
      required this.salutation});

  get fullName => '$lastName $firstName';

  factory Trainer.fromMap(Map<dynamic, dynamic> data, String id) {
    return Trainer(
        id: id,
        memberID: data['memberID'],
        firstName: data['firstName'],
        lastName: data['lastName'],
        email: data['email'],
        phone: data['phone'],
        salutation: data['salutation'] ?? '');
  }

  factory Trainer.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Trainer.fromMap(data, doc.id);
  }

  factory Trainer.empty() {
    return Trainer(
        id: "",
        memberID: "memberID",
        firstName: "Náhradní trenér",
        lastName: "",
        email: "email",
        phone: "phone",
        salutation: "");
  }

  //note that the is IS NOT included in the map
  Map<String, dynamic> toMap() => {
        'memberID': memberID,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'salutation': salutation
      };
}
