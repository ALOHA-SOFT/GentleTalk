import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/models/user_models.dart';
import '../../../core/widgets/app_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/user_type_selector.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  UserType _selectedUserType = UserType.user;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // TODO: Implement login API call
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _navigateToSignup() {
    Navigator.pushNamed(context, '/signup');
  }

  void _navigateToFindId() {
    Navigator.pushNamed(context, '/find-id');
  }

  void _navigateToFindPassword() {
    Navigator.pushNamed(context, '/find-password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 345),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    // Logo
                    const AppLogo(size: 120),
                    const SizedBox(height: 20),
                    // Input Fields
                    CustomTextField(
                      label: '아이디',
                      icon: Icons.person_outline,
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: '비밀번호',
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    // User Type Selector
                    SizedBox(
                      height: 40,
                      child: UserTypeSelector(
                        selectedType: _selectedUserType,
                        onChanged: (type) {
                          setState(() {
                            _selectedUserType = type;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Login Button
                    PrimaryButton(text: '로그인', onPressed: _handleLogin),
                    const SizedBox(height: 10),
                    // Signup Button
                    PrimaryButton(
                      text: '회원가입',
                      onPressed: _navigateToSignup,
                      isOutlined: true,
                    ),
                    const SizedBox(height: 10),
                    // Find ID/Password Buttons
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _navigateToFindId,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.darkBackground,
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                '아이디 찾기',
                                style: AppTextStyles.button.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _navigateToFindPassword,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.darkBackground,
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                '비밀번호 찾기',
                                style: AppTextStyles.button.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
