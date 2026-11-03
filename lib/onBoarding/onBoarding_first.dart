import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:al_sharif/colors.dart';

class OnboardingOne extends StatelessWidget {
  const OnboardingOne({super.key});

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
                child: Image.asset('assets/images/Illustration_first.png'),
              ),
              Text(
                'اختيارات أكثر خطوة أقرب إليك'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'استخدم الذكاء الاصطناعي لتقدير نوع الطرف الصناعي المناسب لحالتك وتكلفته التقريبية في دقائق'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/onboarding2'),
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