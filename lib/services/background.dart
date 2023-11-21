import 'package:ak_kurim/services/powersync.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.

  print('Handling a background message ${message.messageId} ${message.data}');
  if (message.data['type'] == 'background_sync') {
    backgroundSync();
  }
}

Future<bool> backgroundSync() async {
  await GetStorage.init();
  final box = GetStorage();

  try {
    try {
      await openDatabase();
    } on Exception catch (e) {
      print(e);
    }
    DateTime now = DateTime.now();
    // refresh session if needed
    AuthResponse res = await Supabase.instance.client.auth.refreshSession();
    DateTime expiresAt = now.add(Duration(seconds: res.session!.expiresIn!));
    box.write('access_token_expiration', expiresAt.toIso8601String());

    String email = res.session!.user.email!;
    await db.execute('''UPDATE trainer 
          SET last_background_sync = ?
          WHERE email = ?''', [now.toIso8601String(), email]);

    await SupabaseConnector(db).uploadData(db);
    box.write('last_sync', now.toIso8601String());
    box.write('background_sync', 'success');

    // todo send health chceck

    return Future.value(true);
  } catch (e) {
    box.write('background_sync', 'error');
    return Future.value(false);
  }
}
