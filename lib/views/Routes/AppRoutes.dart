// ignore_for_file: file_names, constant_identifier_names, prefer_const_constructors

import 'package:get/get.dart';
import '../screens/HealthDashboardScreen.dart';
import '../screens/HealthGoalsScreen.dart';
import '../screens/HomeScreen.dart';
import '../screens/HomeFirst.dart';
import '../screens/SignInScreen.dart';
import '../screens/ProfileScreen.dart';
import '../screens/SplashScreen.dart';
import '../screens/TermsAndConditionsScreen.dart';
import '../screens/StepGoalScreen.dart';
import '../screens/NameInputScreen.dart';
import '../screens/GenderInputScreen.dart';
import '../screens/AgeInputScreen.dart';
import '../screens/HeightInputScreen.dart';
import '../screens/WeightGoalScreen.dart';
import '../screens/WeightInputScreen.dart';
import '../screens/WelcomeScreen.dart';
import '../screens/HealthConditionsScreen.dart';
import '../screens/WeightFrequencyScreen.dart';

class AppRoutes {
  static const SIGNINSCREEN = '/signin_screen';
  static const HOMESCREEN = '/home';
  static const HOMEFIRSTSCREEN = '/home_first';
  static const TERMSANDCONDITIONS = '/terms_and_conditions';
  static const STEP_GOAL_SCREEN = '/step_goal';
  static const NAME_INPUT_SCREEN = '/name_input';
  static const GENDER_INPUT_SCREEN = '/gender_input';
  static const AGE_INPUT_SCREEN = '/age_input';
  static const HEIGHT_INPUT_SCREEN = '/height_input';
  static const WEIGHT_INPUT_SCREEN = '/weight_input';
  static const WELCOME_SCREEN = '/welcome';
  static const HEALTH_GOALS_SCREEN = '/health_goals';
  static const HEALTH_CONDITION_SCREEN = '/health_condition';
  static const WEIGHT_GOALS_SCREEN = '/weight_goals';
  static const WEIGHT_FREQUENCY_SCREEN = '/weight_frequency';
  static const HEALTH_DASHBOARD = '/health_dashboard';
  static const SPLASH_SCREEN = '/';

  static final routes = [
    GetPage(
      name: SPLASH_SCREEN,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: SIGNINSCREEN,
      page: () => const SignInScreen(),
    ),
    GetPage(
      name: HOMESCREEN,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: HOMEFIRSTSCREEN,
      page: () => const HomeFirst(),
    ),
    GetPage(
      name: TERMSANDCONDITIONS,
      page: () => const TermsAndConditionsScreen(),
    ),
    GetPage(
      name: STEP_GOAL_SCREEN,
      page: () => const StepGoalScreen(),
    ),
    GetPage(
      name: NAME_INPUT_SCREEN,
      page: () => NameInputScreen(),
    ),
    GetPage(
      name: GENDER_INPUT_SCREEN,
      page: () => const GenderInputScreen(),
    ),
    GetPage(
      name: AGE_INPUT_SCREEN,
      page: () => const AgeInputScreen(),
    ),
    GetPage(
      name: HEIGHT_INPUT_SCREEN,
      page: () => const HeightInputScreen(),
    ),
    GetPage(
      name: WEIGHT_INPUT_SCREEN,
      page: () => const WeightInputScreen(),
    ),
    GetPage(
      name: WELCOME_SCREEN,
      page: () => const WelcomeScreen(),
    ),
    GetPage(
      name: HEALTH_GOALS_SCREEN,
      page: () => const HealthGoalsScreen(),
    ),
    GetPage(
      name: HEALTH_CONDITION_SCREEN,
      page: () => const HealthConditionsScreen(),
    ),
    GetPage(
      name: WEIGHT_GOALS_SCREEN,
      page: () => const WeightGoalScreen(),
    ),
    GetPage(
      name: WEIGHT_FREQUENCY_SCREEN,
      page: () => const WeightFrequencyScreen(),
    ),
    GetPage(
      name: HEALTH_DASHBOARD,
      page: () => HealthDashboardScreen(),
    ),
    GetPage(
      name: '/profile',
      page: () {
        final userId =
            Get.parameters['userId'] ?? ''; // Lấy userId từ parameters
        return ProfileScreen(
            userId: userId); // Cung cấp userId khi khởi tạo ProfileScreen
      },
    ),
  ];
}
