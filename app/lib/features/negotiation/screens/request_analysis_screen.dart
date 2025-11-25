import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/config.dart'; // baseUrl 사용

class RequestAnalysisScreen extends StatefulWidget {
  const RequestAnalysisScreen({super.key});

  @override
  State<RequestAnalysisScreen> createState() => _RequestAnalysisScreenState();
}

class _RequestAnalysisScreenState extends State<RequestAnalysisScreen> {
  bool _initialized = false;

  bool _isLoading = true;
  String? _errorMessage;
  String? _analysisResult;
  String? _issueNo; // arguments에서 받아올 값

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    // ✅ 이전 화면에서 넘겨준 arguments 받기 (예: {'issueNo': 'TEST001'})
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    _issueNo = args?['issueNo']?.toString();

    _fetchAnalysis();
  }

  Future<void> _fetchAnalysis() async {
    if (_issueNo == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = '이슈 번호가 전달되지 않았습니다.';
      });
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken'); // 토큰 쓰고 있으면

      final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/issues/$_issueNo/analyze');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ✅ 백엔드 Issue 엔티티 JSON 구조에 맞춰서 필드명 확인
        // 예: { "id": "...", "conflictSituation": "...", "requirements": "...", "analysisResult": "..." }
        final analysis =
            data['analysisResult'] ?? data['analysis_result'] ?? '';

        setState(() {
          _analysisResult =
              (analysis as String).isNotEmpty ? analysis : '분석 결과가 없습니다.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = '서버 오류 (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '요청 중 오류가 발생했습니다.\n$e';
        _isLoading = false;
      });
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
          '나의 요청 분석',
          style: AppTextStyles.heading.copyWith(fontSize: 21),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 345),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildBotBubble('안젠틀님의,\n요구조건을 고려하여 분석한 결과입니다.'),
                        const SizedBox(height: 12),
                        _buildBody(), // ✅ 로딩/에러/결과 처리
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildPrimaryButton(
                '협상 요청',
                () => Navigator.pushNamed(context, '/send-request'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 로딩/에러/결과를 한 번에 처리하는 위젯
  Widget _buildBody() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 40.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Text(
          _errorMessage!,
          style: AppTextStyles.body.copyWith(
            fontSize: 14,
            color: Colors.red,
          ),
        ),
      );
    }

    // 정상 결과
    return _buildAnalysisResult(_analysisResult ?? '분석 결과가 없습니다.');
  }

  Widget _buildBotBubble(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 344),
        decoration: BoxDecoration(
          color: AppColors.primary,
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
          text,
          style: AppTextStyles.body.copyWith(
            fontSize: 16,
            height: 1.4,
            color: const Color(0xFFF2F2F2),
          ),
        ),
      ),
    );
  }

  // 🔥 분석 결과를 서버에서 받아온 텍스트로 표시
  Widget _buildAnalysisResult(String resultText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xCC46D2FD),
            Color(0xCC5351F0),
          ],
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
        resultText,
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
                offset: const Offset(0, 4),
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
