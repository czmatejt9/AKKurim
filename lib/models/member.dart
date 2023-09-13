import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ak_kurim/services/helpers.dart';

// keys = [u'born', u'gender', u'firstName', u'lastName',
// u'birhtNumber', u'EAN', u'street', u'city', u'ZIP', u'email',
//  u'emailParent', u'phone', u'phoneParent', u'endOfRegistration',
//   u'isSignedUp', u'isPaid', u'note'

class Member {
  final String id;
  String born;
  String gender;
  String firstName;
  String lastName;
  String birthNumber;
  String? ean;
  String street;
  String city;
  String zip;
  String? email;
  String? emailParent;
  String? phone;
  String? phoneParent;
  String? endOfRegistration;
  Map isSignedUp;
  Map isPaid;
  String? note;
  String pb;
  Map<String, dynamic> borrowedItems = {};
  Map<String, dynamic> attendanceCount;
  Map<String, dynamic> racesCount;

  Member(
      {required this.id,
      required this.born,
      required this.gender,
      required this.firstName,
      required this.lastName,
      required this.birthNumber,
      this.ean,
      required this.street,
      required this.city,
      required this.zip,
      this.email,
      this.emailParent,
      this.phone,
      this.phoneParent,
      this.endOfRegistration,
      required this.isSignedUp,
      required this.isPaid,
      this.note,
      required this.pb,
      required this.borrowedItems,
      required this.attendanceCount,
      required this.racesCount});

  String get fullName => '$lastName $firstName';
  String get address => '$street\n$city, $zip';
  String get bornYear => born.substring(0, 4);
  String get initials => '${firstName[0]} ${lastName[0]}';
  String get r2021 => racesCount.containsKey('2021')
      ? racesCount['2021'].length.toString()
      : '0';
  String get r2022 => racesCount.containsKey('2022')
      ? racesCount['2022'].length.toString()
      : '0';
  String get r2023 => racesCount.containsKey('2023')
      ? racesCount['2023'].length.toString()
      : '0';
  // the format in born is yyyy-mm-dd, I want mm. dd. yyyy
  String get bornDate =>
      '${born.substring(8, 10)}. ${born.substring(5, 7)}. ${born.substring(0, 4)}';

  factory Member.fromMap(Map<dynamic, dynamic> data, String id) {
    return Member(
        id: id,
        born: data['born'] ?? "",
        gender: data['gender'] ?? "",
        firstName: data['firstName'] ?? "",
        lastName: data['lastName'] ?? "",
        birthNumber: data['birthNumber'] ?? "",
        ean: data['EAN'].toString(),
        street: data['street'],
        city: data['city'] ?? "",
        zip: data['ZIP'].toString(),
        email: data['email'] ?? "",
        emailParent: data['emailParent'] ?? "",
        phone: data['phone'] ?? "",
        phoneParent: data['phoneParent'] ?? "",
        endOfRegistration: data['endOfRegistration'] ?? "",
        isSignedUp: data['isSignedUp'] ?? {},
        isPaid: data['isPaid'] ?? {},
        note: data['note'] ?? "",
        pb: data['pb'] ?? "",
        borrowedItems: data.containsKey('borrowedItems')
            ? data['borrowedItems']
            : {'tretry': '', 'dres': ''},
        attendanceCount: data.containsKey('attendanceCount')
            ? data['attendanceCount']
            : {
                'all': {'present': 0, 'absent': 0, 'excused': 0, 'total': 0}
              },
        racesCount:
            data.containsKey('racesCount') ? data['racesCount'] : {'all': []});
  }

  factory Member.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Member.fromMap(data, doc.id);
  }

  factory Member.empty() {
    return Member(
        id: Helper().generateRandomString(20),
        born: "",
        gender: "",
        firstName: "",
        lastName: "",
        birthNumber: "",
        street: "",
        city: "",
        ean: "",
        zip: "",
        isSignedUp: {},
        isPaid: {},
        borrowedItems: {"tretry": "", "dres": ""},
        attendanceCount: {
          'all': {'present': 0, 'absent': 0, 'excused': 0, 'total': 0}
        },
        racesCount: {'all': []},
        pb: "",
        note: "",
        email: "",
        emailParent: "",
        phone: "",
        phoneParent: "",
        endOfRegistration: "");
  }

  // note the document id IS NOT included in the map
  Map<String, dynamic> toMap() => {
        // convert the object to a map
        'born': born,
        'gender': gender,
        'firstName': firstName,
        'lastName': lastName,
        'birthNumber': birthNumber,
        'EAN': ean,
        'street': street,
        'city': city,
        'ZIP': zip,
        'email': email,
        'emailParent': emailParent,
        'phone': phone,
        'phoneParent': phoneParent,
        'endOfRegistration': endOfRegistration,
        'isSignedUp': isSignedUp,
        'isPaid': isPaid,
        'note': note,
        'pb': pb,
        'borrowedItems': borrowedItems,
        'attendanceCount': attendanceCount,
        'racesCount': racesCount,
      };
}
