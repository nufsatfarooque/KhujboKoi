import 'package:flutter/material.dart';
import 'package:khujbokoi/routes/admin_bottomnav.dart';
import 'package:khujbokoi/screen/admin_home.dart';
import 'package:khujbokoi/screen/manage_users.dart';
import '../screen/onboarding_screen.dart';
import '../screen/login_screen.dart';
import '../screen/sign_up_screen.dart';
import '../screen/home.dart';
import '../screen/reviews.dart';
import '../routes/bottomnav.dart';
import '../screen/notice.dart';

class AppRoutes {
  static const String onboardingScreen = '/onboarding_screen';
  static const String signUpScreen = '/sign_up_screen';
  static const String loginScreen = '/login_screen';
  static const String homePage = '/home';
  static const String bottomnav = '/bottom_nav';
  static const String adminNav =
      '/admin_nav'; // @rafid : I added this for admin dashboard
  static const String adminHomePage = '/admin_home_page';
  static const String reviews = '/reviews';
  static const String notice = '/notices';

  static const String initialRoute = '/initialRoute';
  static const String manageUsersRoute = '/manage_users';

  static Map<String, WidgetBuilder> routes = {
    homePage: (context) => HomePage(
          onLoginPress: () {
            Navigator.pushNamed(context,
                loginScreen); // Navigate to LoginScreen on button press
          },
        ),
    reviews: (context) => ReviewsPage(),
    notice: (context) => NoticeBoardScreen(),
    loginScreen: (context) => LoginScreen(),
    signUpScreen: (context) => SignUpScreen(),
    onboardingScreen: (context) => OnboardingScreen(),
    manageUsersRoute: (context) => ManageUsersPage(),
    bottomnav: (context) => BottomNav(),
    adminNav: (context) =>
        AdminBottomNav(), // @rafid : I added this for admin dashboard
    adminHomePage: (context) => AdminDashboard(
          onLoginPress: () {
            Navigator.pushNamed(context, loginScreen);
          },
        ),
    initialRoute: (context) => OnboardingScreen()
  };
}
