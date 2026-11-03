import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageButton extends StatelessWidget {
  final Color color;
  const LanguageButton({super.key, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return TextButton.icon(
      onPressed: () => context.setLocale(Locale(isArabic ? 'en' : 'ar')),
      icon: Icon(Icons.language, color: color, size: 20),
      label: Text(
        isArabic ? 'English' : 'العربية',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}