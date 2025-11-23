import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/config.dart';
import '../../../core/models/user_models.dart';
import '../../auth/widgets/custom_text_field.dart';
import '../../auth/widgets/gender_selector.dart';
import '../widgets/bottom_nav_bar.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final _usernameController = TextEditingController();   // 로그인 ID / username
  final _passwordController = TextEditingController();   // 새 비밀번호 (UI에만 사용)
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthdateController = TextEditingController();
  Gender _selectedGender = Gender.male;

  bool _isLoading = false;
  bool _passwordEdited = false; // 비밀번호를 실제로 수정했는지 여부

  static const String _passwordMask = '***********';

  @override
  void initState() {
    super.initState();
    _loadMyInfo();

    // 비밀번호 컨트롤러 리스너: 사용자가 마스킹값에서 변경했는지 체크
    _passwordController.addListener(() {
      if (!_passwordEdited && _passwordController.text != _passwordMask) {
        setState(() {
          _passwordEdited = true;
        });
      }
    });
  }

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

  /// 내 정보 조회
  Future<void> _loadMyInfo() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다')),
        );
        return;
      }

      final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/auth/me');

      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final user = data['user'] ?? {};

        setState(() {
          _usernameController.text = user['username'] ?? '';
          _emailController.text = user['email'] ?? '';
          _phoneController.text = user['tel'] ?? '';
          _nameController.text = user['name'] ?? '';
          final birth = user['birth']?.toString() ?? '';
          if (birth.isNotEmpty) {
            // 예: "1992-05-06" → "1992.05.06"
            final parts = birth.split('-');
            if (parts.length == 3) {
              _birthdateController.text = '${parts[0]}.${parts[1]}.${parts[2]}';
            } else {
              _birthdateController.text = birth; // 일단 그대로
            }
          } else {
            _birthdateController.text = '';
          }

          final genderStr = (user['gender'] ?? '').toString().toLowerCase();
          if (genderStr == 'female') {
            _selectedGender = Gender.female;
          } else {
            _selectedGender = Gender.male;
          }

          _passwordController.text = _passwordMask;
          _passwordEdited = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('내 정보 조회 실패: ${res.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서버와 통신 중 오류가 발생했습니다')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 내 정보 수정
  Future<void> _handleUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다')),
        );
        return;
      }

      final body = <String, dynamic>{
        'username': _usernameController.text.trim(),
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'tel': _phoneController.text.trim(),
        'birth': _birthdateController.text.trim(),
        'gender': _selectedGender.name, // 'male' / 'female'
        'type': 'USER',
      };

      if (_passwordEdited &&
          _passwordController.text.isNotEmpty &&
          _passwordController.text != _passwordMask) {
        body['newPassword'] = _passwordController.text.trim();
      }

      final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/auth/me');
      final res = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 수정되었습니다')),
        );
        setState(() {
          _passwordEdited = false;
          _passwordController.text = _passwordMask;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 실패: ${res.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서버와 통신 중 오류가 발생했습니다')),
      );
    }
  }

  void _handleWithdraw() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text('정말 탈퇴하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // 🔹 탈퇴 API 호출 자리 (DELETE /api/v1/users/me 등)
              // 탈퇴 후 SharedPreferences 비우고 로그인 화면으로 이동 등 처리
            },
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );
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
          '마이 페이지',
          style: AppTextStyles.heading.copyWith(fontSize: 21),
        ),
        centerTitle: false,
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
                    if (_isLoading) ...[
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 20),
                    ],
                    // Profile Image
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Input Fields
                    CustomTextField(
                      label: '아이디',
                      icon: Icons.person_outline,
                      controller: _usernameController,
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    // 비밀번호: 마스킹된 값 보여주고, 사용자가 수정하면 새 비밀번호로 반영
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
                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              '수정하기',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Withdraw Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _handleWithdraw,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: AppColors.white,
                        ),
                        child: Text(
                          '탈퇴하기',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
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
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          BottomNavBar.navigateToIndex(context, index);
        },
      ),
    );
  }
}
