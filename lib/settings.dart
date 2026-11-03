import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_app.dart';
import 'contact_us_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color primaryTeal = Color(0xFF20A6A0);

  Future<void> _changeTheme(BuildContext switcherContext, bool goingDark) async {
    ThemeSwitcher.of(switcherContext).changeTheme(
      theme: goingDark ? AppThemes.dark : AppThemes.light,
      isReversed: !goingDark, // الرجوع للأبيض: الدايرة تنكمش
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', goingDark);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إعدادات التطبيق'.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary, // بيتغير مع الثيم
              ),
            ),
            const Divider(height: 25),

            // خيار تغيير اللغة
            ListTile(
              leading: const Icon(Icons.language, color: primaryTeal),
              title: Text('تغيير اللغة (Language)'.tr()),
              trailing: Text(
                context.locale.languageCode == 'ar' ? 'العربية' : 'English',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryTeal,
                ),
              ),
              onTap: () async {
                if (context.locale.languageCode == 'ar') {
                  await context.setLocale(const Locale('en'));
                } else {
                  await context.setLocale(const Locale('ar'));
                }
                if (mounted) setState(() {});
              },
            ),

            // خيار الوضع الليلي
            ListTile(
              leading: const Icon(Icons.brightness_6, color: primaryTeal),
              title: Text('الوضع الليلي (Dark Mode)'.tr()),
              // ThemeSwitcher حوالين الـ Switch بس، عشان الدايرة تطلع من مكانه
              trailing: ThemeSwitcher(
                clipper: const ThemeSwitcherCircleClipper(),
                builder: (switcherContext) {
                  return Switch(
                    value: isDarkMode,
                    activeColor: primaryTeal,
                    onChanged: (value) => _changeTheme(switcherContext, value),
                  );
                },
              ),
            ),

            const Divider(height: 15),


            ListTile(
              leading: const Icon(Icons.support_agent, color: primaryTeal),
              title: Text('تواصل معنا'.tr()),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactUsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}