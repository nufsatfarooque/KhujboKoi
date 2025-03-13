import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:khujbokoi/routes/bottomnav.dart';
import 'package:khujbokoi/screen/manage_users.dart';
import 'package:khujbokoi/services/firebase_api.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();
final navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initNotification(); // call init notification from messaging api (Required for push notification)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.green,
  ));
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations ([DeviceOrientation.portraitUp]);
  runApp (MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KhujboKoi?',
      theme: ThemeData(
     
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.routes, 
        onGenerateRoute: (RouteSettings settings) {
    if (settings.name == AppRoutes.manageUsersRoute) {
      return MaterialPageRoute(
        builder: (context) => ManageUsersPage(),
        settings: settings,
      );
    }
    // Handle other routes if needed.
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(child: Text("No route defined for ${settings.name}")),
      ),
    );
  },
      home: BottomNav(),  );
      
  }
}



