import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/config.dart';

class SendRequestScreen extends StatefulWidget {
  const SendRequestScreen({super.key});

  @override
  State<SendRequestScreen> createState() => _SendRequestScreenState();
}

class _SendRequestScreenState extends State<SendRequestScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // ⭐ negotiationMessage 상태 변수
  String? _negotiationMessage;
  bool _loadingMessage = true;
  String? _issueNo;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    _issueNo = args?['issueNo']?.toString();

    _fetchNegotiationMessage();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  
  void _handleSend() async {
    final receiverName = _nameController.text.isEmpty ? "상대방" : _nameController.text;
    final phone = _phoneController.text.trim();
    final rawMessage = _negotiationMessage ?? "";

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("전화번호를 입력해주세요")));
      return;
    }

    // ✔️ 1) 먼저 서버에 상대방 정보 저장 요청
    final ok = await updateOpponentInfo(_issueNo!, receiverName, phone);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("상대방 정보를 저장하지 못했습니다.")),
      );
      return;
    }

    // ✔️ 2) 메시지 렌더링
    final finalMessage = rawMessage.replaceAll("[상대방 이름]", receiverName);

    // ✔️ 3) 문자 발송
    final success = await sendSmsApi(_issueNo!, phone, finalMessage);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("문자 발송에 실패했습니다. 다시 시도해주세요.")),
      );
      return;
    }

    // ✔️ 4) 완료 페이지 이동
    Navigator.pushNamed(context, '/request-complete');
  }

    Future<bool> sendSmsApi(String issueNo, String phone, String message) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/v1/sms/send');

    final body = {
      "msg": message,
      "receiver": phone,
      "rdate": "",
      "rtime": "",
      "testmode_yn": "Y", // 필요에 따라 N으로
      "issueNo" : _issueNo ?? "" };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        return false;
      }

      final respText = response.body;
      // 디버깅용
      debugPrint('📨 SMS 응답: $respText');

      // 🔹 실패 패턴: 인증오류, 전송 실패, -101 등 포함 시 실패로 간주
      if (respText.contains('인증오류') ||
          respText.contains('전송 실패') ||
          respText.contains('-101')) {
        return false;
      }

      // 🔹 성공 패턴: result_code=1 이라는 문자열 포함되면 성공으로 간주
      if (respText.contains('result_code=1') ||
          respText.contains('result_code=01')) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint("문자 API 예외 발생: $e");
      return false;
    }
  }

  // ⭐ API 호출: negotiationMessage 가져오기
  Future<void> _fetchNegotiationMessage() async {
    if (_issueNo == null) {
      setState(() {
        _negotiationMessage = "이슈 번호가 없습니다.";
        _loadingMessage = false;
      });
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/issues/$_issueNo');

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _negotiationMessage =
              data['negotiationMessage'] ?? '협상 메시지가 존재하지 않습니다.';
          _loadingMessage = false;
        });
      } else {
        setState(() {
          _negotiationMessage =
              "서버 오류(${response.statusCode}). 메시지를 가져올 수 없습니다.";
          _loadingMessage = false;
        });
      }
    } catch (e) {
      setState(() {
        _negotiationMessage = "오류 발생: $e";
        _loadingMessage = false;
      });
    }
  }

  Future<bool> updateOpponentInfo(String issueNo, String name, String phone) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/v1/issues/$issueNo/opponent');

    final body = {
      "opponentName": name,
      "opponentContact": phone,
    };

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
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
          '협상 요청 발송',
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
                    const SizedBox(height: 20),

                    _buildInputField(
                      controller: _nameController,
                      icon: Icons.person_outline,
                      hint: '상대방 이름',
                    ),

                    const SizedBox(height: 20),

                    _buildInputField(
                      controller: _phoneController,
                      icon: Icons.phone_outlined,
                      hint: '전화번호',
                    ),

                    const SizedBox(height: 20),

                    Text(
                      '아래와 같이 메세지가 발송됩니다.',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ⭐ 협상 메시지 프리뷰
                    _buildMessagePreview(),

                    const SizedBox(height: 30),

                    _buildPrimaryButton('발송 하기', _handleSend),

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

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: AppColors.textSecondary),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (_) {
                // 상대방 이름 바뀔 때 프리뷰 다시 그리기
                if (controller == _nameController) {
                  setState(() {});
                }
              },
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.body.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ⭐ negotiationMessage 표시
  Widget _buildMessagePreview() {
    if (_loadingMessage) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    String previewText = _negotiationMessage ?? "";
    previewText = previewText.replaceAll(
      "[상대방 이름]",
      _nameController.text.isEmpty ? "상대방" : _nameController.text,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xCC46D2FD), Color(0xCC5351F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        previewText,
        style: AppTextStyles.body.copyWith(
          fontSize: 14,
          height: 1.5,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: AppTextStyles.button.copyWith(color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }
}
