import 'package:flutter/material.dart';
import 'package:ak_kurim/models/member_preview.dart';
import 'package:ak_kurim/main.dart';
import 'package:ak_kurim/models/trainer.dart';

class DatabaseService extends ChangeNotifier {
  List<MemberPreview> members = <MemberPreview>[];
  List<Trainer> trainers = <Trainer>[];

  Future<void> getMemberPreviews() async {
    if (trainers.isEmpty) {
      await getTrainers();
    }

    final res = await supabase
        .from('member')
        .select('id, first_name, last_name, birth_number')
        .eq('is_active', true);
    var members_ = res.map((e) {
      return MemberPreview.fromJson(e);
    }).toList();
    for (var member in members_) {
      members.add(member);
    }
    members.sort((a, b) => a.lastName.compareTo(b.lastName));
    notifyListeners();
  }

  Future<void> getTrainers() async {
    final res = await supabase.from('trainer').select('*');
    var trainers_ = res.map((e) {
      return Trainer.fromJson(e);
    }).toList();
    for (var trainer in trainers_) {
      trainers.add(trainer);
    }
  }

  bool isTrainer(String member_id) {
    if (trainers.map((e) => e.member_id).contains(member_id)) {
      return true;
    }
    return false;
  }
}
