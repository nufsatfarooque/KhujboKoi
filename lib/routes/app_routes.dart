import 'package:flutter/material.dart';
import 'package:khujbokoi/reviews/house_review.dart';
import 'package:khujbokoi/reviews/restaurant_review.dart';
import 'package:khujbokoi/reviews/upload_restaurant_info.dart';
import '../reviews/reviews.dart';
import '../screen/onboarding_screen.dart';
import '../login-signup/login_screen.dart';
import '../login-signup/sign_up_screen.dart';
import '../screen/home.dart';
import '../routes/bottomnav.dart';
import '../screen/notice.dart';
import '../screen/homeOwnerScreen.dart';
import '../homeOwner/addhouse.dart';
import '../homeOwner/viewListings.dart';
import 'package:khujbokoi/routes/admin_bottomnav.dart';
import 'package:khujbokoi/screen/admin_home.dart';

class AppRoutes{
  static const String onboardingScreen = '/onboarding_screen';
  static const String signUpScreen = '/sign_up_screen';
  static const String loginScreen = '/login_screen';
  static const String homePage = '/home';
  static const String bottomnav = '/bottom_nav';
  static const String adminNav = '/admin_nav';
  static const String adminHomePage = '/admin_home_page';
  static const String reviews = '/reviews';
  static const String notice = '/notices';
  static const String openmap = '/map_page';
  static const String homeowner = '/homeOwnerScreen';
  static const String addhouse = '/addhouse';
  static const String ownerlistings ='/viewListings';
  static const String restaurantReview = '/restaurant_review';
  static const String houseReview = '/house_review';
  static const String uploadRestaurantInfo = '/upload_restaurant_info';

  static const String initialRoute = '/initialRoute';

  static Map<String, WidgetBuilder> routes = {
    homePage: (context) => HomePage(
      onLoginPress: () {
        Navigator.pushNamed(context, loginScreen); // Navigate to LoginScreen on button press
      },
    ),
    reviews: (context) => ReviewsPage(),
    notice: (context) => NoticeBoardScreen(),
    loginScreen: (context) => LoginScreen(),
    signUpScreen: (context) => SignUpScreen(),
    onboardingScreen: (context) => OnboardingScreen(),
    bottomnav: (context) => BottomNav(),
    initialRoute: (context) => OnboardingScreen(),
    homeowner: (context) => HomeOwnerScreen(),
    addhouse: (context) => AddHouse(),
    ownerlistings:(context)=> ViewListings(),
    restaurantReview: (context) => RestaurantReview(),
    houseReview: (context) => HouseReview(),
    uploadRestaurantInfo: (context) => UploadRestaurantInfoScreen(),
    adminNav: (context) =>
        AdminBottomNav(), // @rafid : I added this for admin dashboard
    adminHomePage: (context) => AdminDashboard(
        onLoginPress: () {
          Navigator.pushNamed(context, loginScreen);
          },
       ),
    //openmap: (context)=> MapPage()
  };
}