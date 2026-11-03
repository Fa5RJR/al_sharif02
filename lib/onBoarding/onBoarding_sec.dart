import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:al_sharif/colors.dart';

class OnboardingTwo extends StatelessWidget {
  const OnboardingTwo({super.key});

  @override
  Widget build(BuildContext context) {
    context.locale; // يخلي الشاشة تتحدث لما اللغة تتغير

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/signin'),
                  child: Text('تخطي'.tr()),
                ),
              ),
              Expanded(
                child: Image.asset('assets/images/Illustration_sec.png'),
              ),
              Text(
                'احجز وتابع طلبك'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'احجز موعدك وتابع حالة طلبك خطوة بخطوة، واستقبل تذكيرات بمواعيد الصيانة الدورية'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/onboarding3'),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(AppColors.turquoise),
                  ),
                  child: Text(
                    'التالي'.tr(),
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}