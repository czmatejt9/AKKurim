import 'package:flutter/material.dart';
import 'package:ak_kurim/models/member_preview.dart';
import 'package:ak_kurim/models/trainer.dart';

class DatabaseService extends ChangeNotifier {
  bool isLoading =
      true; // used for loading indicator, during fetching data, mainly for the first time
  bool isInitialized =
      false; // used for loading indicator, during fetching data

  List<MemberPreview> members = <MemberPreview>[];
  List<Trainer> trainers = <Trainer>[];

  Future<void> initialize() async {
    members.clear();
    trainers.clear();
    await getMemberPreviews();
    await getTrainers();
    isLoading = false;
    isInitialized = true;
    notifyListeners();
  }

  Future<void> getMemberPreviews() async {
    final res = await supabase
        .from('member')
        .select('id, first_name, last_name, birth_number')
        .eq('is_active', true);
  }

  Future<void> getTrainers() async {
    // TODO
  }

  bool isTrainer(String memberID) {
    if (trainers.map((e) => e.memberID).contains(memberID)) {
      return true;
    }
    return false;
  }
}
