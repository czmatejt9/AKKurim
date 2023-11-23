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
    SplayTreeMap<String, Map<String, List<PieceOfCloth>>> piecesOfCloth =
        SplayTreeMap();

    for (PieceOfCloth piece in db.piecesOfCloth) {
      Cloth cloth = db.getCloth(clothID: piece.clothID);
      ClothType clothType = db.getClothType(clothTypeID: cloth.clothTypeID);

      String owner = piece.memberID != null
          ? db.getMemberPreview(memberID: piece.memberID!).id
          : 'sklad';
      String size = cloth.size;
      String clothName = clothType.name;
      String gender = clothType.gender == 'M'
          ? 'pánské'
          : clothType.gender == 'F'
              ? 'dámské'
              : 'unisex';
      String key =
          '$clothName-$gender-$size-${clothType.isBorrowable.toString()}-$owner';

      if (piecesOfCloth.containsKey('$clothName $gender')) {
        if (piecesOfCloth['$clothName $gender']!.containsKey(key)) {
          piecesOfCloth['$clothName $gender']![key] =
              piecesOfCloth['$clothName $gender']![key]!..add(piece);
        } else {
          piecesOfCloth['$clothName $gender']![key] = [piece];
        }
      } else {
        piecesOfCloth['$clothName $gender'] = {
          key: [piece]
        };
      }
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
                    ? Text(db.getMemberFullName(
                        memberID: entry.key.split('-').last))
                    : null,
                leading: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                      entry.key.contains('sklad') ? Icons.store : Icons.person),
                  Text("${entry.value.length}x"),
                ]),
                // button for borrowing piece of cloth to member
                trailing: entry.key.split('-')[3] == '1'
                    ? entry.key.contains('sklad')
                        ? IconButton(
                            onPressed: () {
                              // show alert dialog for with list of members to borrow piece of cloth to
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                          'Půjčit ${entry.key.split('-').sublist(0, 3).join(' ')}?'),
                                      content: DropdownMenu<MemberPreview>(
                                        controller: TextEditingController(),
                                        enableFilter: true,
                                        label: const Text('Člen'),
                                        onSelected: (value) {
                                          db.selectedMember = value;
                                        },
                                        dropdownMenuEntries: [
                                          for (MemberPreview member_
                                              in db.members)
                                            DropdownMenuEntry(
                                              value: member_,
                                              label: member_.fullName,
                                            )
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Zrušit')),
                                        TextButton(
                                            onPressed: () {
                                              if (db.selectedMember == null) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    backgroundColor: Colors.red,
                                                    content:
                                                        Text('Vyberte člena'),
                                                  ),
                                                );
                                                return;
                                              }
                                              db.borrowPieceOfCloth(
                                                  pieceOfCloth:
                                                      entry.value.first,
                                                  memberID:
                                                      db.selectedMember!.id);
                                              Navigator.of(context).pop();
                                              // show snackbar
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  backgroundColor: Colors.green,
                                                  content:
                                                      Text('Oblečení půjčeno'),
                                                ),
                                              );
                                            },
                                            child: const Text('Půjčit')),
                                      ],
                                    );
                                  });
                            },
                            icon: const Icon(Icons.arrow_forward,
                                color: Colors.green))
                        : IconButton(
                            onPressed: () {
                              // show alert dialog for returning piece of cloth
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                          'Vrátit kus oblečení do skladu?'),
                                      content: Text(
                                          'Opravdu chcete vrátit ${entry.key.split('-').sublist(0, 3).join(' ')} (od člena ${db.getMemberFullName(memberID: entry.key.split('-').last)}) do skladu?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Zrušit')),
                                        TextButton(
                                            onPressed: () {
                                              db.returnPieceOfCloth(
                                                  pieceOfCloth:
                                                      entry.value.first);
                                              Navigator.of(context).pop();
                                              // show snackbar
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  backgroundColor: Colors.green,
                                                  content: Text(
                                                      'Oblečení vráceno do skladu'),
                                                ),
                                              );
                                            },
                                            child: const Text('Vrátit')),
                                      ],
                                    );
                                  });
                            },
                            icon:
                                const Icon(Icons.arrow_back, color: Colors.red))
                    : IconButton(
                        onPressed: () {
                          // show alert dialog for removing piece of cloth
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Smazat kus oblečení?'),
                                  content: Text(
                                      'Opravdu chcete smazat ${entry.key.split('-').sublist(0, 3).join(' ')}?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Zrušit')),
                                    TextButton(
                                        onPressed: () {
                                          db.deletePieceOfCloth(
                                              pieceOfClothID:
                                                  entry.value.first.id);
                                          Navigator.of(context).pop();
                                          // show snackbar
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              backgroundColor: Colors.green,
                                              content: Text('Oblečení smazáno'),
                                            ),
                                          );
                                        },
                                        child: const Text('Smazat')),
                                  ],
                                );
                              });
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
