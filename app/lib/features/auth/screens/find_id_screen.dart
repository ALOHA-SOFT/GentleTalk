import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/widgets/app_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class FindIdScreen extends StatefulWidget {
  const FindIdScreen({super.key});

  @override
  State<FindIdScreen> createState() => _FindIdScreenState();
}

class _FindIdScreenState extends State<FindIdScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleFindId() {
    // TODO: Implement find ID API call : /api/v1/users/find-username
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('아이디 찾기 기능 구현 예정')));
  }

  void _navigateToFindPassword() {
    Navigator.pushReplacementNamed(context, '/find-password');
  }

  void _navigateToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '아이디 찾기',
          style: AppTextStyles.heading.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 345),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    // Logo
                    const AppLogo(size: 120),
                    const SizedBox(height: 20),
                    // Email Input
                    CustomTextField(
                      label: '이메일',
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      readOnly: false,
                    ),
                    const SizedBox(height: 20),
                    // Find ID Button
                    PrimaryButton(text: '아이디 찾기', onPressed: _handleFindId),
                    const SizedBox(height: 10),
                    // Find Password Button
                    PrimaryButton(
                      text: '비밀번호 찾기',
                      onPressed: _navigateToFindPassword,
                      isOutlined: true,
                    ),
                    const SizedBox(height: 10),
                    // Login Button
                    PrimaryButton(
                      text: '로그인',
                      onPressed: _navigateToLogin,
                      isOutlined: true,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
