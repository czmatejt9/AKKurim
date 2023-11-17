import 'package:flutter/material.dart';
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
    final uuid = Uuid();

    return Scaffold(
      appBar: const MyAppBar(
        title: "Oblečení",
      ),
      drawer: const MyDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Clothes Screen',
            ),
            for (Cloth cloth in db.clothes)
              ElevatedButton(
                  onPressed: () {
                    print('pressed');
                    PieceOfCloth pieceOfCloth = PieceOfCloth(
                      id: uuid.v4(),
                      clothID: cloth.id,
                      memberID: null,
                    );
                    db.testInsert(
                        table: 'piece_of_cloth',
                        variables: pieceOfCloth.toSQLVariables(),
                        values: pieceOfCloth.toSQLValues());
                  },
                  child: Text(
                      "${db.getClothType(clothTypeID: cloth.clothTypeID).name} ${cloth.size}")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {}, label: const Text('Přidat oblečení')),
    );
  }
}
