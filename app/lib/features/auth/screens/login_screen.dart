import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/models/user_models.dart';
import '../../../core/widgets/app_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/user_type_selector.dart';

import '../../../core/constants/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> _handleLogin() async {

  try {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/auth/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim(),
        'userType': _selectedUserType.name, // 혹시 있으면
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

    final name = (data['name'] ?? '').toString();
    final usernameFromApi = (data['username'] ?? data['id'] ?? '').toString();

    final effectiveUsername = usernameFromApi.isNotEmpty
        ? usernameFromApi
        : _usernameController.text.trim();

    // 로그인 응답에서 no를 userNo로 사용
    final user = data['user'] ?? {};
    final int userNo = user['no'] is int
        ? user['no'] as int
        : int.tryParse(user['no'].toString()) ?? 0;

    final token = data['accessToken'];
    final refreshToken = data['refreshToken'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt', token); 
    await prefs.setString('refreshToken', refreshToken);  
    await prefs.setString('userName', name);
    await prefs.setString('userUsername', effectiveUsername);
    await prefs.setInt('userNo', userNo);

    Navigator.pushReplacementNamed(context, '/home');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('로그인 실패: ${response.statusCode}')),
    );
  }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('서버와 통신 중 오류가 발생했습니다')),
    );
  }
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
                      readOnly: false,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: '비밀번호',
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      obscureText: true,
                      readOnly: false,
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
                    PrimaryButton(
                      text: '로그인',
                      onPressed: () {
                        _handleLogin();
                      },
                    ),
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
