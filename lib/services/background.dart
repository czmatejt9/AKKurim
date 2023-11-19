import 'package:workmanager/workmanager.dart';
import 'package:ak_kurim/services/powersync.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await sync();
    return Future.value(true);
  });
}
