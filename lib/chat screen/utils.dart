//import 'package:flutter_projects/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:flutter_projects/services/alert_service.dart';

//import 'package:flutter_projects/services/media_service.dart';
//import 'package:flutter_projects/services/storage_service.dart';
import 'package:get_it/get_it.dart';
import 'package:khujbokoi/chat%20screen/services/database_service.dart';
import 'package:khujbokoi/chat%20screen/services/navigation_service.dart';
import 'package:khujbokoi/firebase_options.dart';
import 'package:khujbokoi/services/auth_service.dart';
//import 'package:khujbokoi/services/auth_service.dart';

Future<void> setupFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> registerServices() async {
  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<AuthService>(
    AuthService(),
  );
  getIt.registerSingleton<NavigationService>(
    NavigationService(),
  );

  // getIt.registerSingleton<AlertService>(
  //   AlertService(),
  // );

  // getIt.registerSingleton<MediaService>(
  //   MediaService(),
  // );

  // getIt.registerSingleton<StorageService>(
  //   StorageService(),
  // );

  getIt.registerSingleton<MueedDatabaseService>(
    MueedDatabaseService(),
  );
}

String generateChatID({
  required String uid1,
  required String uid2,
}) {
  // Ensure IDs are sorted to maintain consistency
  List<String> uids = [uid1, uid2];
  uids.sort();

  // Concatenate the sorted IDs
  return uids
      .join('_'); // Use an underscore as a separator for better readability
}
