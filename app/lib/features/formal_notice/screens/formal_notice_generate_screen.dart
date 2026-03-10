import 'dart:async';
import 'dart:convert';

import 'package:app/core/widgets/step_indicator.dart';
import 'package:app/features/formal_notice/screens/formal_notice_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormalNoticeGeneratingScreen extends StatefulWidget {
  final Map<String, dynamic> requestPayload;

  const FormalNoticeGeneratingScreen({
    super.key,
    required this.requestPayload,
  });

  @override
  State<FormalNoticeGeneratingScreen> createState() =>
      _FormalNoticeGeneratingScreenState();
}

class _FormalNoticeGeneratingScreenState
    extends State<FormalNoticeGeneratingScreen> {
  String? _error;
  bool _done = false;

  /// 프론트에서만 사용하는 진행 단계
  int _activeStep = 1;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _runFakeProgress() async {
    if (!mounted) return;

    setState(() {
      _activeStep = 1;
      _done = false;
    });

    // 1번 단계가 먼저 켜진 상태로 잠깐 보이게
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _activeStep = 2;
    });

    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;

    setState(() {
      _activeStep = 3;
    });

    // 3번 단계가 보이는 시간을 조금 줌
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    setState(() {
      _done = true;
    });
  }

  Future<void> _start() async {
    try {
      final backendFuture = _callBackend(widget.requestPayload);
      final progressFuture = _runFakeProgress();

      final result = await backendFuture;
      await progressFuture;

      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FormalNoticePreviewScreen(
            previewData: result,
            requestPayload: widget.requestPayload,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _done = false;
      });
    }
  }

  Future<Map<String, dynamic>> _callBackend(
    Map<String, dynamic> payload,
  ) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/formal-notice/generate');

    final prefs = await SharedPreferences.getInstance();

    debugPrint('=== prefs keys === ${prefs.getKeys()}');
    debugPrint('=== jwt === ${prefs.getString('jwt')}');
    debugPrint('=== token === ${prefs.getString('token')}');
    debugPrint('=== accessToken === ${prefs.getString('accessToken')}');

    final token = prefs.getString('jwt');

    debugPrint('=== stored jwt === $token');

    if (token == null || token.isEmpty) {
      throw Exception('로그인 정보가 없습니다. 다시 로그인해주세요.');
    }

    final res = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    debugPrint('=== statusCode === ${res.statusCode}');
    debugPrint('=== response body === ${res.body}');

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('서버 오류: ${res.statusCode} / ${res.body}');
    }

    final decoded = jsonDecode(utf8.decode(res.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw Exception('응답 형식이 올바르지 않습니다.');
    }

    return decoded;
  }

  void _retry() {
    setState(() {
      _error = null;
      _done = false;
      _activeStep = 1;
    });

    _start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const SizedBox(height: 6),
              const Text(
                '내용 증명 작성',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              const StepIndicator(currentStep: 3, totalSteps: 5),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF00949F),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'AI가 내용을 정리하고 있습니다.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 34, 16, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE9EAEC)),
                  ),
                  child: _error != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _retry,
                              child: const Text('다시 시도'),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            const Text(
                              '잠시만 기다려주세요',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                              ),
                            ),
                            const SizedBox(height: 34),
                            _ProgressCard(
                              num: 1,
                              text: '사건 분석',
                              isActive: _activeStep >= 1,
                              isDone: _done && _activeStep >= 1,
                            ),
                            const SizedBox(height: 10),
                            _ProgressCard(
                              num: 2,
                              text: '법적 문장 정리',
                              isActive: _activeStep >= 2,
                              isDone: _done && _activeStep >= 2,
                            ),
                            const SizedBox(height: 10),
                            _ProgressCard(
                              num: 3,
                              text: '내용증명 생성',
                              isActive: _activeStep >= 3,
                              isDone: _done && _activeStep >= 3,
                            ),
                            const Spacer(),
                          ],
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

class _ProgressCard extends StatelessWidget {
  final int num;
  final String text;
  final bool isActive;
  final bool isDone;

  const _ProgressCard({
    required this.num,
    required this.text,
    required this.isActive,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF00A8B5);
    const inactiveBorder = Color(0xFFE9EAEC);
    const inactiveCircle = Color(0xFFE6E8EE);
    const inactiveText = Color(0xFF222222);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? activeColor.withOpacity(0.35) : inactiveBorder,
          width: isActive ? 1.4 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: activeColor.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? activeColor.withOpacity(0.14)
                  : inactiveCircle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$num',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isActive ? activeColor : const Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isActive ? activeColor : inactiveText,
              ),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: isDone ? 1 : 0,
            child: const Icon(
              Icons.check_circle,
              color: activeColor,
            ),
          ),
        ],
      ),
    );
  }
}