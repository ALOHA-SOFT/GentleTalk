import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../widgets/primary_button.dart';

class SignupSuccessScreen extends StatelessWidget {
  const SignupSuccessScreen({super.key});

  void _navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(
                  Icons.check,
                  size: 72,
                  color: AppColors.white,
                ),
              ),
              SizedBox(height: size.height * 0.05),
              // Success Message
              Text(
                '회원가입\n성공하였습니다!',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading.copyWith(fontSize: 26),
              ),
              SizedBox(height: size.height * 0.1),
              // Login Button
              PrimaryButton(
                text: '로그인',
                onPressed: () => _navigateToLogin(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
