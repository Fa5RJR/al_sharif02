import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:al_sharif/routing/routing.dart';
import 'package:al_sharif/theme_app.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dzaxbrfnzijrmcdwnxvz.supabase.co',
    publishableKey: 'sb_publishable_ryltILM76W3XZS1jrjvhWQ_oad2Yb_V',
  );

  // نقرأ الثيم المحفوظ ونبدأ بيه
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDark') ?? false;

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: MyApp(initTheme: isDark ? AppThemes.dark : AppThemes.light),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ThemeData initTheme;
  const MyApp({super.key, required this.initTheme});

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      initTheme: initTheme,
      builder: (context, theme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: theme, // الثيم الحالي بييجي من الـ provider
          // ThemeSwitchingArea بيلف كل الصفحات (الـ Navigator)
          builder: (context, child) => ThemeSwitchingArea(child: child!),
          home: const SplashScreen(),
          routes: AppRoutes.routes,
        );
      },
    );
  }
}