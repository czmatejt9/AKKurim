import 'package:flutter/material.dart';
import 'package:ak_kurim/models/member_preview.dart';
import 'package:ak_kurim/models/trainer.dart';
import 'package:ak_kurim/services/powersync.dart';
import 'package:ak_kurim/models/cloth.dart';
import 'package:ak_kurim/models/cloth_type.dart';
import 'package:ak_kurim/models/piece_of_cloth.dart';

class DatabaseService extends ChangeNotifier {
  int? count; // count of pending changes to be synced
  bool isLoading =
      true; // used for loading indicator, during fetching data, mainly for the first time
  bool isInitialized =
      false; // used for loading indicator, during fetching data

  bool hasInternet = db.currentStatus
      .connected; // used for loading indicator, during fetching data

  List<MemberPreview> members = <MemberPreview>[];

  List<Trainer> trainers = <Trainer>[];
  Trainer? currentTrainer;

  List<Cloth> clothes = <Cloth>[];
  List<ClothType> clothTypes = <ClothType>[];
  List<PieceOfCloth> piecesOfCloth = <PieceOfCloth>[];

  Future<void> initialize() async {
    initializeStreams();

    members.clear();
    trainers.clear();
    await getMemberPreviews();
    await getTrainers();

    await downloadClothes();

    isLoading = false;
    isInitialized = true;

    notifyListeners();
  }

  Future<void> initializeStreams() async {
    var myStream = getCrud(const Duration(milliseconds: 100));
    myStream.listen((event) {
      if (event != count) {
        count = event;
        notifyListeners();
      }
    });

    var myStream2 = db.statusStream;
    myStream2.listen((event) {
      if (event.connected) {
        hasInternet = true;
      } else {
        hasInternet = false;
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

  Future<void> downloadClothes() async {
    var data = await db.database.getAll('Select * from cloth_type');
    clothTypes = data.map((e) => ClothType.fromJson(e)).toList();

    data = await db.database.getAll('Select * from cloth');
    clothes = data.map((e) => Cloth.fromJson(e)).toList();

    data = await db.database.getAll('Select * from piece_of_cloth');
    piecesOfCloth = data.map((e) => PieceOfCloth.fromJson(e)).toList();
  }

  ClothType getClothType({required String clothTypeID}) {
    return clothTypes.firstWhere((element) => element.id == clothTypeID);
  }

  Cloth getCloth({required String clothID}) {
    return clothes.firstWhere((element) => element.id == clothID);
  }

  void testInsert(
      {required String table,
      required String variables,
      required List values}) async {
    await db.execute('insert into $table $variables', values);
  }

  Stream<int> getCrud(Duration interval) async* {
    while (true) {
      var stream = await db.getAll('Select COUNT(*) from ps_crud');
      yield stream[0]['COUNT(*)'] as int;
      await Future.delayed(interval);
    }
  }
}
