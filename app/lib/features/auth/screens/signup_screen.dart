import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/models/user_models.dart';
import '../../../core/widgets/app_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gender_selector.dart';
import '../widgets/primary_button.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/config.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthdateController = TextEditingController();
  Gender? _selectedGender;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('성별을 선택해주세요')),
      );
      return;
    }

    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/auth/join');

      final body = {
        'id': _usernameController.text.trim(),        // 로그인 ID
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim(),
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'tel': _phoneController.text.trim(),
        'birth': _birthdateController.text.trim(),   
        'gender': _selectedGender!.name,          
        'type': 'USER',
        'address' : '',                             // 주소 필드가 없으므로 빈 문자열로 전달
      };

      // 디버깅용 로그 (원하면)
      // print('Signup body: $body');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('📡 회원가입 응답: ${response.statusCode}');
      debugPrint('📡 응답 본문: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/signup-success');
      } else {
        // 서버 응답 본문 파싱 시도
        String errorMessage = '회원가입 실패';
        try {
          final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
          if (responseBody is Map && responseBody['message'] != null) {
            errorMessage = responseBody['message'];
          } else if (responseBody is Map && responseBody['error'] != null) {
            errorMessage = responseBody['error'];
          }
        } catch (_) {
          errorMessage = '회원가입 실패 (${response.statusCode}): ${response.body}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ 회원가입 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('서버와 통신 중 오류가 발생했습니다\n상세: $e'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showTerms() {
    Navigator.pushNamed(context, '/terms');
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
                child: Form(
                  key: _formKey,
                  child: Column(
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
                      CustomTextField(
                        label: '이메일',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: false,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: '전화번호',
                        icon: Icons.phone_outlined,
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        readOnly: false,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: '이름',
                        icon: Icons.badge_outlined,
                        controller: _nameController,
                        readOnly: false,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: '생년월일',
                        icon: Icons.calendar_today_outlined,
                        controller: _birthdateController,
                        keyboardType: TextInputType.datetime,
                        readOnly: false,
                      ),
                      const SizedBox(height: 20),
                      // Gender Selector
                      GenderSelector(
                        selectedGender: _selectedGender,
                        onChanged: (gender) {
                          setState(() {
                            _selectedGender = gender;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      // Terms Button
                      GestureDetector(
                        onTap: _showTerms,
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '이용약관 확인하기',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Signup Button
                      PrimaryButton(text: '가입하기', onPressed: _handleSignup),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
