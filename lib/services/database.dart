import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ak_kurim/models/member.dart';
import 'package:ak_kurim/models/trainer.dart';
import 'package:ak_kurim/models/user.dart';
import 'package:ak_kurim/models/group.dart';
import 'package:ak_kurim/models/training.dart';

class DatabaseService extends ChangeNotifier {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  List<Member> _members = <Member>[]; // List of members
  List<Member> get members => _members;

  List<Member> _filteredMembers = <Member>[]; // List of filtered members
  List<Member> get filteredMembers => _filteredMembers;

  Trainer _trainer = Trainer(
      id: '', memberID: '', firstName: '', lastName: '', email: '', phone: '');
  Trainer get currentTrainer => _trainer;
  List<Trainer> _trainers = <Trainer>[];
  List<Trainer> get allTrainers => _trainers;

  List<Trainer> _filteredTrainers = <Trainer>[];
  List<Trainer> get filteredTrainers =>
      _filteredTrainers; // List of filtered trainers

  List<Group> _trainerGroups = <Group>[];
  List<Group> get trainerGroups => _trainerGroups;

  List<Training> _trainerTrainings = <Training>[];
  List<Training> get trainerTrainings => _trainerTrainings;

  bool isChangedTrainingGroup = false;

  void refresh() {
    notifyListeners();
  }

  String getMemberfullNameFromID(String id) {
    final String memberFullName = _members.firstWhere((member) {
      return member.id == id;
    },
        orElse: () => Member(
            id: "",
            born: "born",
            gender: "gender",
            firstName: "firstName",
            lastName: "lastName",
            birthNumber: "birthNumber",
            street: "street",
            city: "city",
            zip: 0,
            isSignedUp: {},
            isPaid: {})).fullName;
    return memberFullName;
  }

  String getTrainerFullNameFromID(String id) {
    final String trainerFullName = _trainers.firstWhere((trainer) {
      return trainer.id == id;
    },
        orElse: () => Trainer(
            id: "",
            memberID: "memberID",
            firstName: "Náhradní trenér",
            lastName: "",
            email: "email",
            phone: "phone")).fullName;
    return trainerFullName;
  }

  bool isTrainer(String id) {
    final bool isTrainer = _trainers.any((trainer) {
      return trainer.id == id;
    });
    return isTrainer;
  }

  String getGroupNameFromID(String id) {
    final group = getGroupFromID(id);
    return group.name;
  }

  Group getGroupFromID(String id) {
    final Group group = _trainerGroups.firstWhere((group) {
      return group.id == id;
    },
        orElse: () => Group(
            id: "",
            name: "Skupina",
            trainerIDs: <String>[],
            memberIDs: <String>[]));
    return group;
  }

  Future<void> updateTrainers({required User user, bool init = false}) async {
    db.settings = const Settings(persistenceEnabled: true);
    db.collection('trainers').get().then(
      (QuerySnapshot querySnapshot) {
        _trainers = querySnapshot.docs.map((QueryDocumentSnapshot doc) {
          return Trainer.fromFirestore(doc);
        }).toList();
        _trainer = _trainers.firstWhere((trainer) {
          return trainer.email == user.email;
        },
            orElse: () => Trainer(
                id: '',
                memberID: '',
                firstName: '',
                lastName: '',
                email: '',
                phone: ''));
        if (init) {
          updateGroups(init: init);
        }
      },
    );
  }

  // download all groups which contain the current trainer in the trainersIDs list
  Future<void> updateGroups({bool init = false}) async {
    db.settings = const Settings(persistenceEnabled: true);
    db.collection("groups").get().then(
      (QuerySnapshot querySnapshot) {
        _trainerGroups = querySnapshot.docs.map((QueryDocumentSnapshot doc) {
          return Group.fromFirestore(doc);
        }).toList();
        _trainerGroups = _trainerGroups.where((group) {
          return group.trainerIDs.contains(_trainer.id);
        }).toList();
        if (init) {
          updateMembers(init: init);
        }
      },
    );
  }

  // + month to the current date and -month to the current date
  Future<void> updateTrainings() async {
    db.settings = const Settings(persistenceEnabled: true);
    db
        .collection('trainings')
        .where('groupID', whereIn: _trainerGroups.map((group) => group.id))
        .where('date',
            isGreaterThan: Timestamp.fromDate(
                DateTime.now().subtract(const Duration(days: 30))))
        //.where('date',
        //  isLessThan:
        //    DateTime.now().add(Duration(days: 30)).toIso8601String()) idk if this is needed to speed up the query
        .get()
        .then(
      (QuerySnapshot querySnapshot) {
        _trainerTrainings = querySnapshot.docs.map((QueryDocumentSnapshot doc) {
          return Training.fromFirestore(doc);
        }).toList();

        // add the trainings where the current trainer is the substitute trainer
        db
            .collection('trainings')
            .where('substituteTrainerID', isEqualTo: _trainer.id)
            .where('date',
                isGreaterThan: Timestamp.fromDate(
                    DateTime.now().subtract(const Duration(days: 30))))
            //.where('date',
            //  isLessThan:
            //    DateTime.now().add(Duration(days: 30)).toIso8601String()) idk if this is needed to speed up the query
            .get()
            .then(
          (QuerySnapshot querySnapshot) {
            _trainerTrainings
                .addAll(querySnapshot.docs.map((QueryDocumentSnapshot doc) {
              return Training.fromFirestore(doc);
            }).toList());
            // sort trainings by date
            sortTrainingsByDate();
          },
        );
      },
    );
  }

  Future<void> updateMembers({bool forceUpdate = false, bool init = false}) {
    db.settings = const Settings(persistenceEnabled: true);
    // Get members from Firestore
    if (_isUpdating && !forceUpdate) {
      return Future<void>.value();
    }
    db.collection('members').get().then((QuerySnapshot querySnapshot) {
      _members = querySnapshot.docs.map((QueryDocumentSnapshot doc) {
        return Member.fromFirestore(doc);
      }).toList();
      // sort members by last name
      _members.sort((Member a, Member b) => a.lastName.compareTo(b.lastName));
      filterMembers(filter: '');
    });
    if (init) {
      updateTrainings();
    }
    return Future<void>.value();
  }

  void filterMembers({required String filter, Group? group}) {
    if (filter == '') {
      // clone the list
      _filteredMembers = List<Member>.from(_members);
    } else {
      _filteredMembers = _members
          .where((Member member) =>
              member.firstName.toLowerCase().contains(filter.toLowerCase()) ||
              member.lastName.toLowerCase().contains(filter.toLowerCase()))
          .toList();
    }

    if (group != null) {
      _filteredMembers.removeWhere((Member member) {
        return group.memberIDs.contains(member.id);
      });
    }
    notifyListeners();
  }

  // filter trainers by name and remove trainers which are already in the group
  void filterTrainers({required String filter, required Group group}) {
    if (filter == '') {
      // clone the list
      _filteredTrainers = List<Trainer>.from(_trainers);
    } else {
      _filteredTrainers = _trainers
          .where((Trainer trainer) =>
              trainer.firstName.toLowerCase().contains(filter.toLowerCase()) ||
              trainer.lastName.toLowerCase().contains(filter.toLowerCase()))
          .toList();
    }

    _filteredTrainers.removeWhere((Trainer trainer) {
      return group.trainerIDs.contains(trainer.id);
    });
    notifyListeners();
  }

  // initial data for the app (members, trainers, groups, trainings) - only for the first time
  // use the functions above to update the data
  Future<void> initializeData(User user) async {
    _isUpdating = true;
    db.settings = const Settings(persistenceEnabled: true);
    await updateTrainers(user: user, init: true);
    _isUpdating = false;
  }

  // group functions - create, update, delete
  Future<void> createGroup(Group group) async {
    db.settings = const Settings(persistenceEnabled: true);
    _trainerGroups.add(group);
    await db.collection('groups').doc(group.id).set(group.toMap());
  }

  Future<void> updateGroup(Group group) async {
    db.settings = const Settings(persistenceEnabled: true);
    _trainerGroups[
        _trainerGroups.indexWhere((element) => element.id == group.id)] = group;
    await db.collection('groups').doc(group.id).update(group.toMap());
  }

  Future<void> deleteGroup(Group group) async {
    db.settings = const Settings(persistenceEnabled: true);
    _trainerGroups.removeWhere((element) => element.id == group.id);
    await db.collection('groups').doc(group.id).delete();
  }

  void sortTrainingsByDate() {
    _trainerTrainings
        .sort((Training a, Training b) => a.timestamp.compareTo(b.timestamp));
  }

  // training functions - create, update, delete
  Future<void> createTraining(Training training) async {
    db.settings = const Settings(persistenceEnabled: true);
    // prepare the attendance list
    Group group = getGroupFromID(training.groupID);
    training.attendanceKeys = []; // just to be sure to have an empty list
    training.attendanceValues = []; // true = present, false = absent
    // add all trainers to the attendance list
    for (String trainerID in group.trainerIDs) {
      training.attendanceKeys.add(trainerID);
      training.attendanceValues.add(false);
    }
    if (training.substituteTrainerID != '') {
      training.attendanceKeys.add(training.substituteTrainerID);
      training.attendanceValues.add(false);
    }
    // add all members to the attendance list
    for (String memberID in group.memberIDs) {
      training.attendanceKeys.add(memberID);
      training.attendanceValues.add(false);
    }

    _trainerTrainings.add(training);
    sortTrainingsByDate();
    await db.collection('trainings').doc(training.id).set(training.toMap());
  }

  Future<void> updateTraining(Training training, bool groupChange) async {
    db.settings = const Settings(persistenceEnabled: true);
    if (groupChange) {
      training.attendanceTaken = false;
      Group group = getGroupFromID(training.groupID);
      training.attendanceKeys = [];
      training.attendanceValues = [];
      // add all trainers to the attendance list
      for (String trainerID in group.trainerIDs) {
        training.attendanceKeys.add(trainerID);
        training.attendanceValues.add(false);
      }
      if (training.substituteTrainerID != '') {
        training.attendanceKeys.add(training.substituteTrainerID);
        training.attendanceValues.add(false);
      }
      // add all members to the attendance list
      for (String memberID in group.memberIDs) {
        training.attendanceKeys.add(memberID);
        training.attendanceValues.add(false);
      }
    }

    _trainerTrainings[_trainerTrainings
        .indexWhere((element) => element.id == training.id)] = training;
    sortTrainingsByDate();
    await db.collection('trainings').doc(training.id).update(training.toMap());
  }

  Future<void> deleteTraining(Training training) async {
    db.settings = const Settings(persistenceEnabled: true);
    _trainerTrainings.removeWhere((element) => element.id == training.id);
    await db.collection('trainings').doc(training.id).delete();
  }
}
