import 'package:cloud_firestore/cloud_firestore.dart';

// keys = [u'born', u'gender', u'firstName', u'lastName',
// u'birhtNumber', u'EAN', u'street', u'city', u'ZIP', u'email',
//  u'emailParent', u'phone', u'phoneParent', u'endOfRegistration',
//   u'isSignedUp', u'isPaid', u'note'

class Member {
  final String id;
  final String born;
  final String gender;
  final String firstName;
  final String lastName;
  final String birthNumber;
  final int? EAN;
  final String street;
  final String city;
  final int ZIP;
  final String? email;
  final String? emailParent;
  final String? phone;
  final String? phoneParent;
  final String? endOfRegistration;
  final Map isSignedUp;
  final Map isPaid;
  final String? note;

  Member(
      {required this.id,
      required this.born,
      required this.gender,
      required this.firstName,
      required this.lastName,
      required this.birthNumber,
      this.EAN,
      required this.street,
      required this.city,
      required this.ZIP,
      this.email,
      this.emailParent,
      this.phone,
      this.phoneParent,
      this.endOfRegistration,
      required this.isSignedUp,
      required this.isPaid,
      this.note});

  String get fullName => '$lastName $firstName';
  String get address => '$street\n $city, $ZIP';
  String get bornYear => born.substring(0, 4);
  String get initials => '${firstName[0]} ${lastName[0]}';

  factory Member.fromMap(Map<dynamic, dynamic> data, String id) {
    return Member(
        id: id,
        born: data['born'],
        gender: data['gender'],
        firstName: data['firstName'],
        lastName: data['lastName'],
        birthNumber: data['birthNumber'] ?? "",
        EAN: data['EAN'] ?? "",
        street: data['street'],
        city: data['city'],
        ZIP: data['ZIP'],
        email: data['email'] ?? "",
        emailParent: data['emailParent'] ?? "",
        phone: data['phone'] ?? "",
        phoneParent: data['phoneParent'] ?? "",
        endOfRegistration: data['endOfRegistration'] ?? "",
        isSignedUp: data['isSignedUp'],
        isPaid: data['isPaid'],
        note: data['note'] ?? "");
  }

  factory Member.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Member.fromMap(data, doc.id);
  }

  // note the document id IS NOT included in the map
  Map<String, dynamic> toMap() => {
        // convert the object to a map
        'born': born,
        'gender': gender,
        'firstName': firstName,
        'lastName': lastName,
        'birthNumber': birthNumber,
        'EAN': EAN,
        'street': street,
        'city': city,
        'ZIP': ZIP,
        'email': email,
        'emailParent': emailParent,
        'phone': phone,
        'phoneParent': phoneParent,
        'endOfRegistration': endOfRegistration,
        'isSignedUp': isSignedUp,
        'isPaid': isPaid,
        'note': note,
      };
}
