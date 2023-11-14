import 'package:flutter/material.dart';
import 'package:ak_kurim/models/member_preview.dart';
import 'package:ak_kurim/models/trainer.dart';
import 'package:ak_kurim/services/powersync.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DatabaseService extends ChangeNotifier {
  bool isLoading =
      true; // used for loading indicator, during fetching data, mainly for the first time
  bool isInitialized =
      false; // used for loading indicator, during fetching data

  bool? hasInternet; // used for loading indicator, during fetching data

  List<MemberPreview> members = <MemberPreview>[];
  List<Trainer> trainers = <Trainer>[];
  Trainer? currentTrainer;

  Future<void> initialize() async {
    await getConnectionInfo();

    members.clear();
    trainers.clear();
    await getMemberPreviews();
    await getTrainers();

    isLoading = false;
    isInitialized = true;
    notifyListeners();
  }

  Future<void> getConnectionInfo() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none ||
        connectivityResult == ConnectivityResult.bluetooth) {
      hasInternet = false;
    } else {
      hasInternet = true;
    }

    var subscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none ||
          result == ConnectivityResult.bluetooth) {
        hasInternet = false;
      } else {
        hasInternet = true;
      }
      notifyListeners();
    });
  }

  Future<void> getMemberPreviews() async {
    var data = await db.database.getAll(
        'Select id, first_name, last_name, birth_number from member where is_active = 1 order by last_name');
    members = data.map((e) => MemberPreview.fromJson(e)).toList();
  }

  Future<void> getTrainers() async {
    var data = await db.database.getAll('Select * from trainer');
    trainers = data.map((e) => Trainer.fromJson(e)).toList();

    if (trainers.isNotEmpty) {
      currentTrainer =
          trainers.firstWhere((element) => element.email == getUserEmail());
    }
  }

  bool isTrainer({required String memberID}) {
    if (trainers.map((e) => e.memberID).contains(memberID)) {
      return true;
    }
    return false;
  }

  String getTrainerFullName({required String memberID}) {
    return getMemberPreview(memberID: memberID).fullName;
  }

  MemberPreview getMemberPreview({required String memberID}) {
    return members.firstWhere((element) => element.id == memberID);
  }
}
