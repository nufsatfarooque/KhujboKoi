import 'package:flutter/material.dart';
import '../screen/onboarding_screen.dart';
import '../screen/login_screen.dart';
/*import '../presentation/onboarding_screen/sign_up_screen.dart';

import '../presentation/onboarding_screen/home.dart';*/

class AppRoutes{
  static const String onboardingScreen = '/onboarding_screen';
  static const String signUpScreen = '/sign_up_screen';
  static const String loginScreen = '/login_screen';
  static const String homePage = '/home_page';

  static const String initialRoute = '/initialRoute';

  static Map<String, WidgetBuilder> routes = {
    //homePage: (context) => HomePage(),
    loginScreen: (context) => LoginScreen(),
    /*signUpScreen: (context) => SignUpScreen(),*/
    onboardingScreen: (context) => OnboardingScreen(),
    initialRoute: (context) => OnboardingScreen()
  };
}