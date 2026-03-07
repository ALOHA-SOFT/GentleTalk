import 'dart:convert';
import 'package:app/core/widgets/step_indicator.dart';
import 'package:app/features/formal_notice/screens/formal_notice_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormalNoticeGeneratingScreen extends StatefulWidget {
  final Map<String, dynamic> requestPayload;

  const FormalNoticeGeneratingScreen({super.key, required this.requestPayload});

  @override
  State<FormalNoticeGeneratingScreen> createState() =>
      _FormalNoticeGeneratingScreenState();
}

class _FormalNoticeGeneratingScreenState
    extends State<FormalNoticeGeneratingScreen> {
  String? _error;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final result = await _callBackend(widget.requestPayload);
      if (!mounted) return;

      setState(() => _done = true);

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
      setState(() => _error = e.toString());
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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
                  padding: const EdgeInsets.all(16),
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
                              onPressed: () {
                                setState(() => _error = null);
                                _start();
                              },
                              child: const Text('다시 시도'),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('잠시만 기다려주세요'),
                            const SizedBox(height: 16),
                            const CircularProgressIndicator(),
                            const SizedBox(height: 18),
                            _ProgressCard(num: 1, text: '사건 분석', done: _done),
                            const SizedBox(height: 10),
                            _ProgressCard(
                              num: 2,
                              text: '법적 문장 정리',
                              done: _done,
                            ),
                            const SizedBox(height: 10),
                            _ProgressCard(num: 3, text: '내용증명 생성', done: _done),
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
  final bool done;

  const _ProgressCard({
    required this.num,
    required this.text,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9EAEC)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE6E8EE),
            child: Text(
              '$num',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
          ),
          if (done) const Icon(Icons.check_circle, color: Color(0xFF00ADB5)),
        ],
      ),
    );
  }
}
