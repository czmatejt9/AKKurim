import 'package:ak_kurim/services/helpers.dart';
import 'package:flutter/material.dart';
import 'package:ak_kurim/models/member_preview.dart';
import 'package:ak_kurim/models/trainer.dart';
import 'package:ak_kurim/services/powersync.dart';
import 'package:ak_kurim/models/cloth.dart';
import 'package:ak_kurim/models/cloth_type.dart';
import 'package:ak_kurim/models/piece_of_cloth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ak_kurim/services/background.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DatabaseService extends ChangeNotifier {
  GetStorage box = GetStorage();

  int? count; // count of pending changes to be synced
  bool isLoading =
      true; // used for loading indicator, during fetching data, mainly for the first time
  bool isInitialized =
      false; // used for loading indicator, during fetching data
  bool areStreamsInitialized =
      false; // used for loading indicator, during fetching data
  String lastSynced = ''; // last time data was synced

  bool hasInternet = db.currentStatus
      .connected; // used for loading indicator, during fetching data

  List<MemberPreview> members = <MemberPreview>[];

  List<Trainer> trainers = <Trainer>[];
  Trainer? currentTrainer;

  List<Cloth> clothes = <Cloth>[];
  List<ClothType> clothTypes = <ClothType>[];
  List<PieceOfCloth> piecesOfCloth = <PieceOfCloth>[];

  Future<void> initialize() async {
    lastSynced = box.read('last_sync') ?? '';

    if (!areStreamsInitialized) {
      await initializeStreams();
      areStreamsInitialized = true;
    }

    refreshData();

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
    // print the device token
    print(await messaging.getToken());
  }

  /// Loads local data and starts background sync.
  Future<void> refreshData() async {
    currentTrainer = null;
    await getMemberPreviews();
    await getTrainers();
    await downloadClothes();

    isLoading = false;
    isInitialized = true;

    notifyListeners();
  }

  Future<void> initializeStreams() async {
    var myStream = pendingChanges(const Duration(milliseconds: 100));
    myStream.listen((event) {
      if (event != count) {
        count = event;
        notifyListeners();
      }
    });

    var myStream2 = db.statusStream;
    myStream2.listen((event) {
      // refresh data if internet connection is restored
      if (event.connected) {
        hasInternet = true;
        isLoading = true;
        isInitialized = false;
        refreshData();

        lastSynced = event.lastSyncedAt.toString();
        box.write('last_sync', lastSynced);
      } else {
        hasInternet = false;
      }
      notifyListeners();
    });
  }

  Future<void> getMemberPreviews() async {
    members.clear();

    var data = await db.database.getAll(
        'Select id, first_name, last_name, birth_number from member where is_active = 1 order by last_name');
    members = data.map((e) => MemberPreview.fromJson(e)).toList();
  }

  Future<void> getTrainers() async {
    trainers.clear();

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

  /// Returns full name of member with given id.
  String getMemberFullName({required String memberID}) {
    return getMemberPreview(memberID: memberID).fullName;
  }

  /// Returns MemberPreview with given id.
  MemberPreview getMemberPreview({required String memberID}) {
    return members.firstWhere((element) => element.id == memberID);
  }

  Future<void> downloadClothes() async {
    // clear all lists
    clothTypes.clear();
    clothes.clear();
    piecesOfCloth.clear();

    var data = await db.database.getAll('Select * from cloth_type');
    clothTypes = data.map((e) => ClothType.fromJson(e)).toList();

    data = await db.database.getAll('Select * from cloth');
    clothes = data.map((e) => Cloth.fromJson(e)).toList();

    data = await db.database.getAll('Select * from piece_of_cloth');
    piecesOfCloth = data.map((e) => PieceOfCloth.fromJson(e)).toList();
  }

  /// Returns ClothType with given id.
  ClothType getClothType({required String clothTypeID}) {
    return clothTypes.firstWhere((element) => element.id == clothTypeID);
  }

  /// Returns Cloth with given id.
  Cloth getCloth({required String clothID}) {
    return clothes.firstWhere((element) => element.id == clothID);
  }

  /// Inserts data into local database and syncs it with remote database.
  void insert(
      {required String table,
      required String variables,
      required List values}) async {
    await db.execute('insert into $table $variables', values);
  }

  /// Stream for count of pending changes to be synced with remote database.
  Stream<int> pendingChanges(Duration interval) async* {
    while (true) {
      var stream = await db.getAll('Select COUNT(*) from ps_crud');
      yield stream[0]['COUNT(*)'] as int;
      await Future.delayed(interval);
    }
  }
}
