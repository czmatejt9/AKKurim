import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:ak_kurim/services/database.dart';
import 'package:ak_kurim/widgets/appbar.dart';
import 'package:ak_kurim/widgets/drawer.dart';
import 'package:ak_kurim/models/cloth.dart';
import 'package:ak_kurim/models/cloth_type.dart';
import 'package:ak_kurim/models/piece_of_cloth.dart';
import 'package:ak_kurim/services/powersync.dart' as powersync;

class ClothesScreen extends StatelessWidget {
  const ClothesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    const uuid = Uuid();

    return Scaffold(
      appBar: const MyAppBar(
        title: "Oblečení",
      ),
      drawer: const MyDrawer(),
      body: ListView.builder(
        itemCount: db.piecesOfCloth.length,
        itemBuilder: (context, index) {
          Cloth cloth = db.getCloth(clothID: db.piecesOfCloth[index].clothID);
          return ListTile(
            title: Text(
                '${db.getClothType(clothTypeID: cloth.clothTypeID).name} ${cloth.size}'),
            trailing: db.piecesOfCloth[index].memberID == null
                ? const Text('sklad')
                : Text(db
                    .getMemberPreview(
                        memberID: db.piecesOfCloth[index].memberID!)
                    .fullName),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddClothes()),
            );
          },
          label: const Text('Přidat oblečení')),
    );
  }
}

class AddClothes extends StatefulWidget {
  const AddClothes({super.key});

  @override
  State<AddClothes> createState() => _AddClothesState();
}

class _AddClothesState extends State<AddClothes> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sizeCreatorController = TextEditingController();

  final TextEditingController clothTypeController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController countController = TextEditingController();

  int radioIndex = 0;
  ClothType? clothType;
  Cloth? cloth;
  int? count;

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    const uuid = Uuid();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Přidat oblečení'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            const Text('Přidat kusy oblečení', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                DropdownMenu<ClothType>(
                  width: 150,
                  controller: clothTypeController,
                  enableFilter: true,
                  label: const Text('Typ oblečení'),
                  onSelected: (value) {
                    setState(() {
                      clothType = value;
                    });
                  },
                  dropdownMenuEntries: [
                    for (ClothType clothType_ in db.clothTypes)
                      DropdownMenuEntry(
                        value: clothType_,
                        label:
                            '${clothType_.name} - ${clothType_.gender == 'M' ? 'pánské' : clothType_.gender == 'F' ? 'dámské' : 'unisex'}',
                      )
                  ],
                ),
                const Spacer(),
                DropdownMenu<Cloth>(
                  width: 150,
                  enabled: clothType != null,
                  controller: sizeController,
                  enableFilter: true,
                  label: const Text('Velikost'),
                  onSelected: (value) {
                    setState(() {
                      cloth = value;
                    });
                  },
                  dropdownMenuEntries: [
                    if (clothType != null)
                      for (Cloth cloth_ in db.clothes
                          .where(
                              (element) => element.clothTypeID == clothType!.id)
                          .toList())
                        DropdownMenuEntry(
                          value: cloth_,
                          label: cloth_.size,
                        )
                  ],
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownMenu<int>(
                  width: 150,
                  controller: countController,
                  enableFilter: true,
                  label: const Text('Počet'),
                  onSelected: (value) {
                    setState(() {
                      count = value;
                    });
                  },
                  dropdownMenuEntries: [
                    for (var i in List.generate(100, (i) => i + 1))
                      DropdownMenuEntry(
                        value: i,
                        label: i.toString(),
                      )
                  ],
                ),
                const Spacer(),
                // show button here to add the clothes (count) to the database
                ElevatedButton(
                  onPressed: () {
                    if (cloth != null && count != null) {
                      for (var i = 0; i < count!; i++) {
                        PieceOfCloth pieceOfCloth = PieceOfCloth(
                          id: uuid.v4(),
                          clothID: cloth!.id,
                          memberID: null,
                        );
                        db.piecesOfCloth.add(pieceOfCloth);
                        db.testInsert(
                            table: 'piece_of_cloth',
                            variables: pieceOfCloth.toSQLVariables(),
                            values: pieceOfCloth.toSQLValues());
                      }
                      Navigator.pop(context);
                      // show snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('Oblečení přidáno'),
                        ),
                      );
                    } else {
                      // show snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Vyplňte všechny údaje'),
                        ),
                      );
                    }
                  },
                  child: const Text('Přidat'),
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            const Text('Vytvořit nové oblečení',
                style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            TextFormField(
              key: formKey,
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Jméno oblečení',
              ),
            ),
            const SizedBox(height: 10),
            // create row with 3 radio buttons for gender selection
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Pohlaví: ', style: TextStyle(fontSize: 16)),
                Radio<int>(
                  value: 0,
                  groupValue: radioIndex,
                  onChanged: (value) {
                    setState(() {
                      radioIndex = value!;
                    });
                  },
                ),
                const Text('Pánské'),
                Radio<int>(
                  value: 1,
                  groupValue: radioIndex,
                  onChanged: (value) {
                    setState(() {
                      radioIndex = value!;
                    });
                  },
                ),
                const Text('Dámské'),
                Radio<int>(
                  value: 2,
                  groupValue: radioIndex,
                  onChanged: (value) {
                    setState(() {
                      radioIndex = value!;
                    });
                  },
                ),
                const Text('Unisex'),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: sizeCreatorController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Velikosti oblečení (oddělené čárkou s mezerou)',
              ),
            ),
            const SizedBox(height: 10),
            // create button here to add the sizes to the database
            ElevatedButton(
                onPressed: () {
                  // TODO check if all fields are filled later
                  List<String> sizes = sizeCreatorController.text.split(', ');
                  String gender = ['M', 'F', 'U'][radioIndex];

                  // create cloth type
                  ClothType ct = ClothType(
                      id: uuid.v4(), name: nameController.text, gender: gender);
                  db.clothTypes.add(ct);
                  db.testInsert(
                      table: 'cloth_type',
                      variables: ct.toSQLVariables(),
                      values: ct.toSQLValues());

                  // create clothes
                  String ctID = ct.id;
                  for (String size in sizes) {
                    Cloth cloth =
                        Cloth(id: uuid.v4(), size: size, clothTypeID: ctID);
                    db.clothes.add(cloth);
                    db.testInsert(
                        table: 'cloth',
                        variables: cloth.toSQLVariables(),
                        values: cloth.toSQLValues());
                  }

                  Navigator.pop(context);
                  // show snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('Oblečení vytvořeno'),
                    ),
                  );
                },
                child: const Text('Vytvořit')),
          ],
        ),
      ),
    );
  }
}
