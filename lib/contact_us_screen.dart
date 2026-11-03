import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  // دالة فتح الروابط العامة (فيسبوك، واتساب، مكالمات)
  Future<void> _launchUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $urlString');
    }
  }

  // روابط التواصل الخاصة بمراكز الشريف للأطراف الصناعية بالرقم الجديد
  void _openFacebook() => _launchUrl('https://www.facebook.com'); // استبدلها برابط صفحة الفيس بوك الفعلية
  void _openWhatsApp() => _launchUrl('https://wa.me/201126588499');
  void _makePhoneCall() => _launchUrl('tel:+201126588499');

  @override
  Widget build(BuildContext context) {
    context.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تواصل معنا'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF05857F), Color(0xFF0E1C4C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 10,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.support_agent, size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'نحن هنا لمساعدتك دائماً'.tr(),
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'تواصل معنا عبر وسائل الاتصال التالية لأي استفسار أو حجز'.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // زر واتساب
                    _buildContactButton(
                      title: 'تواصل عبر واتساب'.tr(),
                      icon: Icons.chat,
                      color: const Color(0xFF25D366),
                      onPressed: _openWhatsApp,
                    ),
                    const SizedBox(height: 16),

                    // زر فيسبوك
                    _buildContactButton(
                      title: 'صفحتنا على فيسبوك'.tr(),
                      icon: Icons.facebook,
                      color: const Color(0xFF1877F2),
                      onPressed: _openFacebook,
                    ),
                    const SizedBox(height: 16),

                    // زر الاتصال الهاتفي
                    _buildContactButton(
                      title: 'اتصل بنا مباشرة'.tr(),
                      icon: Icons.phone,
                      color: Colors.teal,
                      onPressed: _makePhoneCall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // تصميم موحد وصحيح 100% لأزرار التواصل باستخدام ElevatedButton.icon
  Widget _buildContactButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
        icon: Icon(icon, size: 24),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}