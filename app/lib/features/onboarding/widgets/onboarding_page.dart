import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/models/onboarding_content.dart';

class OnboardingPage extends StatelessWidget {
  final OnboardingContent content;

  const OnboardingPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageHeight = size.height * 0.35; // 화면 높이의 35%

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.06), // 화면 높이의 6%
            // Image Container
            Container(
              width: size.width - 48,
              height: imageHeight,
              constraints: const BoxConstraints(
                maxWidth: 345,
                maxHeight: 370,
                minHeight: 250,
              ),
              decoration: BoxDecoration(
                color: AppColors.grey,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Image.asset(content.image, fit: BoxFit.cover),
            ),
            SizedBox(height: size.height * 0.03), // 화면 높이의 3%
            // Title
            SizedBox(
              width: double.infinity,
              child: Text(
                content.title,
                style: AppTextStyles.responsiveHeading(context),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: size.height * 0.02), // 화면 높이의 2%
            // Description
            SizedBox(
              width: double.infinity,
              child: Text(
                content.description,
                style: AppTextStyles.responsiveBody(context),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: size.height * 0.02), // 추가 여백
          ],
        ),
      ),
    );
  }
}
