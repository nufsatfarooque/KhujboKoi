// AppRoutes.dart
import 'dart:core'; // Ensure this import is present for core Dart types like String

import 'package:flutter/material.dart';
import 'package:khujbokoi/reviews/house_review.dart';
import 'package:khujbokoi/reviews/restaurant_review.dart';
import 'package:khujbokoi/reviews/upload_restaurant_info.dart';
import '../reviews/reviews.dart';
import '../screen/onboarding_screen.dart';
import '../screen/manage_users.dart';
import '../login-signup/login_screen.dart';
import '../login-signup/sign_up_screen.dart';
import '../screen/home.dart';
import '../routes/bottomnav.dart';
import '../screen/notice.dart';
import '../homeOwner/addhouse.dart';
import '../homeOwner/viewListings.dart';
import '../homeOwner/rentedProperties.dart';
import '../reviews/search_dish_screen.dart';
import 'package:khujbokoi/routes/admin_bottomnav.dart';
import 'package:khujbokoi/screen/admin_home.dart';
import '../homeOwner/HomeOwnerWrapper.dart';

class AppRoutes {
  static const String onboardingScreen = '/onboarding_screen';
  static const String signUpScreen = '/sign_up_screen';
  static const String loginScreen = '/login_screen';
  static const String homePage = '/home';
  static const String bottomnav = '/bottom_nav';
  static const String adminNav = '/admin_nav';
  static const String adminHomePage = '/admin_home_page';
  static const String manageUsersRoute = '/manage_users';
  static const String reviews = '/reviews';
  static const String searchDish = '/search_dish_screen';
  static const String notice = '/notices';
  static const String openmap = '/map_page';
  static const String homeowner = '/homeOwnerScreen';
  static const String addhouse = '/addhouse';
  static const String ownerlistings = '/viewListings';
  static const String viewReviews = '/viewReviews';
  static const String rentedProperties = '/rentedProperties';
  static const String restaurantReview = '/restaurant_review';
  static const String houseReview = '/house_review';
  static const String uploadRestaurantInfo = '/upload_restaurant_info';
  static const String settings = '/settings';
  static const String marketplace = '/marketplace';
  static const String initialRoute = '/initialRoute';

  static Map<String, WidgetBuilder> routes = {
    homePage: (context) => HomePage(
      onLoginPress: () {
        Navigator.pushNamed(context, loginScreen);
      },
    ),
    reviews: (context) => ReviewsPage(),
    searchDish: (context) => SearchDishScreen(),
    notice: (context) => NoticeBoardTabs(),
    loginScreen: (context) => LoginScreen(),
    signUpScreen: (context) => SignUpScreen(),
    onboardingScreen: (context) => OnboardingScreen(),
    bottomnav: (context) => BottomNav(),
    initialRoute: (context) => OnboardingScreen(),
    addhouse: (context) => const AddHouse(),
    ownerlistings: (context) => const ViewListings(),
    rentedProperties: (context) => const RentedPropertiesScreen(),
    restaurantReview: (context) => const RestaurantReview(),
    houseReview: (context) => const HouseReview(),
    uploadRestaurantInfo: (context) => const UploadRestaurantInfoScreen(),
    manageUsersRoute: (context) => const ManageUsersPage(),
    adminNav: (context) => const AdminBottomNav(),
    adminHomePage: (context) => AdminDashboard(
      onLoginPress: () {
        Navigator.pushNamed(context, loginScreen);
      },
    ),
    homeowner: (context) => const HomeOwnerWrapper(initialIndex: 0),
    marketplace: (context) => const HomeOwnerWrapper(initialIndex: 1),
    settings: (context) => const HomeOwnerWrapper(initialIndex: 3),
    viewReviews: (context) => const HomeOwnerWrapper(initialIndex: 2),
  };
}