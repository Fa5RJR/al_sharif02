import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:al_sharif/colors.dart';

class OnboardingThree extends StatelessWidget {
  const OnboardingThree({super.key});

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
              Expanded(
                child: Image.asset('assets/images/Illustration_3rd.png'),
              ),
              Text(
                'دعم نفسي ومجتمع بجانبك'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'جلسات علاج نفسي وفيديوهات داعمة ومجتمع من أشخاص يشاركونك الرحلة، لأنك لست وحدك'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/signin'),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(AppColors.turquoise),
                  ),
                  child: Text(
                    'ابدأ الآن'.tr(),
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