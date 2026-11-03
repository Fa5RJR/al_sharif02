import 'package:al_sharif/home.dart';
import 'package:flutter/material.dart';
import 'package:al_sharif/signin.dart';
import 'package:al_sharif/signup.dart';
import 'package:al_sharif/onBoarding/onBoarding_first.dart';
import 'package:al_sharif/onBoarding/onBoarding_sec.dart';
import 'package:al_sharif/onBoarding/onBording_three.dart';
import 'package:al_sharif/ai.dart';
import 'package:al_sharif/price.dart';
class AppRoutes {
  AppRoutes._();

  static const String onboarding = '/onboarding';
  static const String onboarding2 = '/onboarding2';
  static const String onboarding3 = '/onboarding3';
  static const String signin = '/signin';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String assistant = '/assistant';
  static const String priceEstimation = '/priceEstimation';

  static Map<String, WidgetBuilder> get routes => {
    onboarding: (context) => const OnboardingOne(),
    onboarding2: (context) => const OnboardingTwo(),
    onboarding3: (context) => const OnboardingThree(),
    signin: (context) => const LoginScreen(),
    signup: (context) => const Signup(),
    home: (context) => const HomeScreen(),
    assistant: (context) => const SmartAssistantScreen(),
    priceEstimation: (context) => const PriceEstimationScreen(),
  };
}