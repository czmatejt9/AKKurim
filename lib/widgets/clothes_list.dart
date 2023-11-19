import 'package:flutter/material.dart';
import 'package:ak_kurim/models/member_preview.dart';
import 'package:ak_kurim/models/cloth.dart';
import 'package:ak_kurim/models/cloth_type.dart';
import 'package:ak_kurim/models/piece_of_cloth.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:provider/provider.dart';
import 'dart:collection';

class ClothesList extends StatelessWidget {
  const ClothesList({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService db = Provider.of<DatabaseService>(context);
    SplayTreeMap<String, Map<String, int>> piecesOfCloth = SplayTreeMap();

    for (PieceOfCloth piece in db.piecesOfCloth) {
      Cloth cloth = db.getCloth(clothID: piece.clothID);
      ClothType clothType = db.getClothType(clothTypeID: cloth.clothTypeID);

      String owner = piece.memberID != null
          ? db.getMemberPreview(memberID: piece.memberID!).fullName
          : 'sklad';

      String size = cloth.size;
      String clothName = clothType.name;
      String gender = clothType.gender == 'M'
          ? 'pánské'
          : clothType.gender == 'F'
              ? 'dámské'
              : 'unisex';
      String isBorrowable = clothType.isBorrowable == 1 ? '1' : '0';
      String key = '$clothName-$gender-$size-$isBorrowable-$owner';

      if (piecesOfCloth.containsKey('$clothName $gender')) {
        if (piecesOfCloth['$clothName $gender']!.containsKey(key)) {
          piecesOfCloth['$clothName $gender']![key] =
              piecesOfCloth['$clothName $gender']![key]! + 1;
        } else {
          piecesOfCloth['$clothName $gender']![key] = 1;
        }
      } else {
        piecesOfCloth['$clothName $gender'] = {key: 1};
      }

      // sort alphabetically
      piecesOfCloth['$clothName $gender'] = Map.fromEntries(
          piecesOfCloth['$clothName $gender']!.entries.toList()
            ..sort((e1, e2) => e1.key.compareTo(e2.key)));
    }

    return ListView(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 80),
      children: piecesOfCloth.entries.map((entry) {
        return Card(
          elevation: 10,
          child: ExpansionTile(
            title: Text(entry.key),
            children: entry.value.entries.map((entry) {
              return ListTile(
                title: Text(entry.key.split('-').sublist(0, 3).join(' ')),
                subtitle: entry.key.split('-').last != 'sklad'
                    ? Text(entry.key.split('-').last)
                    : null,
                leading: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                      entry.key.contains('sklad') ? Icons.store : Icons.person),
                  Text("${entry.value}x"),
                ]),
                // button for borrowing piece of cloth to member
                trailing: entry.key.split('-')[3] == '1'
                    ? entry.key.contains('sklad')
                        ? IconButton(
                            onPressed: () {
                              // TODO implement borrowing
                            },
                            icon: const Icon(Icons.arrow_forward,
                                color: Colors.green))
                        : IconButton(
                            onPressed: () {
                              // TODO implement returning
                            },
                            icon:
                                const Icon(Icons.arrow_back, color: Colors.red))
                    : IconButton(
                        onPressed: () {
                          // TODO implement removing
                        },
                        icon: const Icon(Icons.remove, color: Colors.red)),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
