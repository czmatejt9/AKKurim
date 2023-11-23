import 'package:flutter/material.dart';
import 'package:ak_kurim/models/member_preview.dart';
import 'package:ak_kurim/services/helpers.dart';
import 'package:uuid/uuid.dart';
import 'package:ak_kurim/models/trainer.dart';
import 'package:ak_kurim/services/powersync.dart';
import 'package:ak_kurim/models/cloth.dart';
import 'package:ak_kurim/models/cloth_type.dart';
import 'package:ak_kurim/models/piece_of_cloth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DatabaseService extends ChangeNotifier {
  Uuid uuid = const Uuid();
  GetStorage box = GetStorage();

  int? count = 0; // count of pending changes to be synced
  bool isLoading =
      true; // used for loading indicator, during fetching data, mainly for the first time
  bool isInitialized =
      false; // used for loading indicator, during fetching data
  bool areStreamsInitialized =
      false; // used for loading indicator, during fetching data
  String lastSynced = ''; // last time data was synced
  bool hasInternet = db.currentStatus
      .connected; // used for loading indicator, during fetching data
  String? allowedNotifications;

  List<MemberPreview> members = <MemberPreview>[];
  MemberPreview? selectedMember;

  List<Trainer> trainers = <Trainer>[];
  Trainer? currentTrainer;

  List<Cloth> clothes = <Cloth>[];
  List<ClothType> clothTypes = <ClothType>[];
  List<PieceOfCloth> piecesOfCloth = <PieceOfCloth>[];

  Future<void> initialize() async {
    lastSynced = box.read('last_sync') ?? '';
    allowedNotifications = box.read('allowed_notifications') ?? 'false';

    if (!areStreamsInitialized) {
      await initializeStreams();
      areStreamsInitialized = true;
    }
    refreshData();

    askForNotifications();
  }

  /// Loads local data and starts background sync.
  Future<void> refreshData({bool notify = true}) async {
    currentTrainer = null;
    await getMemberPreviews();
    await getTrainers();
    await downloadClothes();

    isLoading = false;
    isInitialized = true;

    if (notify) {
      notifyListeners();
    }
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
        lastSynced = event.lastSyncedAt.toString();
        box.write('last_sync', lastSynced);
        notifyListeners();

        refreshData(notify: false);
      } else {
        hasInternet = false;
        notifyListeners();
      }
    });

    // listen to on token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await updateFCMToken(newToken);
    });
  }

  Future<void> askForNotifications() async {
    // ask for permission to send notifications (required for bg sync)
    GetStorage box = GetStorage();
    String allowedNotifications_ = box.read('allowed_notifications') ?? '';
    if (allowedNotifications_.isEmpty) {
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
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        box.write('allowed_notifications', 'true');
        allowedNotifications = 'true';
        String? token = await messaging.getToken();
        await updateFCMToken(token!);
      } else {
        box.write('allowed_notifications', 'false');
        allowedNotifications = 'false';
      }
    }
  }

  Future<void> updateFCMToken(String token) async {
    String now = DateTime.now().toIso8601String();
    print('Updating FCM token to $token');
    await db.execute('''
      UPDATE trainer
      SET fcm_token = ?, last_fcm_token_update = ?
      WHERE email = ?
    ''', [token, now, getUserEmail()]);
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
    print(memberID);
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

  Future<void> deletePieceOfCloth({required String pieceOfClothID}) async {
    await db.execute('''
      DELETE FROM piece_of_cloth
      WHERE id = ?
    ''', [pieceOfClothID]);
    piecesOfCloth.removeWhere((element) => element.id == pieceOfClothID);
    notifyListeners();
  }

  Future<void> createClothes(
      {required String clothName,
      required String gender,
      required List<String> sizes}) async {
    // create cloth type
    ClothType ct = ClothType(id: uuid.v4(), name: clothName, gender: gender);
    clothTypes.add(ct);
    insert(
        table: 'cloth_type',
        variables: ct.toSQLVariables(),
        values: ct.toSQLValues());

    // create clothes
    String ctID = ct.id;
    for (String size in sizes) {
      Cloth cloth = Cloth(id: uuid.v4(), size: size, clothTypeID: ctID);
      clothes.add(cloth);
      insert(
          table: 'cloth',
          variables: cloth.toSQLVariables(),
          values: cloth.toSQLValues());
    }
    notifyListeners();
  }

  Future<void> addClothes({required int count_, required Cloth cloth}) async {
    for (var i = 0; i < count_; i++) {
      PieceOfCloth pieceOfCloth = PieceOfCloth(
        id: uuid.v4(),
        clothID: cloth.id,
        memberID: null,
      );
      piecesOfCloth.add(pieceOfCloth);
      insert(
          table: 'piece_of_cloth',
          variables: pieceOfCloth.toSQLVariables(),
          values: pieceOfCloth.toSQLValues());
    }
    notifyListeners();
  }

  Future<void> borrowPieceOfCloth(
      {required PieceOfCloth pieceOfCloth, required String memberID}) async {
    pieceOfCloth.memberID = memberID;
    db.execute('''
      UPDATE piece_of_cloth
      SET member_id = ?
      WHERE id = ?
    ''', [memberID, pieceOfCloth.id]);

    selectedMember = null; // reset selected member
    notifyListeners();
  }

  Future<void> returnPieceOfCloth({required PieceOfCloth pieceOfCloth}) async {
    pieceOfCloth.memberID = null;
    db.execute('''
      UPDATE piece_of_cloth
      SET member_id = ?
      WHERE id = ?
    ''', [null, pieceOfCloth.id]);
    notifyListeners();
  }

  /// Inserts data into local database and syncs it with remote database.
  Future<void> insert(
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
