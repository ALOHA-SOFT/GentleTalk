import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/config.dart';
import '../../user/widgets/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpponentOpinionSubmitScreen extends StatefulWidget {
  const OpponentOpinionSubmitScreen({super.key});

  @override
  State<OpponentOpinionSubmitScreen> createState() =>
      _OpponentOpinionSubmitScreenState();
}

class _OpponentOpinionSubmitScreenState
    extends State<OpponentOpinionSubmitScreen> {
  final TextEditingController _opinionController = TextEditingController();

  String? _issueNo;
  bool _initialized = false;
  bool _isSubmitting = false;

  // 🔥 추가된 상태
  bool _alreadySubmitted = false;
  String? _existingOpponentReq;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    _issueNo = args?['issueNo']?.toString();

    if (_issueNo != null) {
      _fetchExistingOpinion();
    }
  }

  @override
  void dispose() {
    _opinionController.dispose();
    super.dispose();
  }

  /// 🔍 기존 의견 조회
  Future<void> _fetchExistingOpinion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/issues/$_issueNo');
      debugPrint('📡 GET (existing opinion): $uri');

      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = json.decode(utf8.decode(res.bodyBytes));
        _existingOpponentReq = data['opponentRequirements'];

        if (_existingOpponentReq != null &&
            _existingOpponentReq!.trim().isNotEmpty) {
          setState(() {
            _alreadySubmitted = true;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('이미 발송된 의견이 있습니다.')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('❌ 기존 의견 조회 오류: $e');
    }
  }

  /// 제출하기
  Future<void> _submitOpinion() async {
    if (_alreadySubmitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 발송된 의견이 있습니다.')),
      );
      return;
    }

    final opinion = _opinionController.text.trim();

    debugPrint('📝 submitOpinion called / issueNo=$_issueNo');

    if (opinion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('의견을 입력해주세요.')),
      );
      return;
    }

    if (_issueNo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이슈 번호가 없습니다. 다시 시도해주세요.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final uri = Uri.parse(
        '${AppConfig.baseUrl}/api/v1/issues/$_issueNo/opponent-requirements',
      );
      debugPrint('📡 PUT $uri');

      final body = {
        'opponentRequirements': opinion,
      };

      final res = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        debugPrint('✅ 의견 저장 성공');

        if (!mounted) return;
        Navigator.pushNamed(
          context,
          '/opponent-opinion-complete',
          arguments: {
            'issueNo': _issueNo,
          },
        );
      } else {
        debugPrint('❌ 저장 실패: ${res.statusCode} / ${res.body}');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('의견 제출에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      debugPrint('❌ 예외 발생: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('의견 제출 중 오류가 발생했습니다: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          '의견 제출하기',
                          style: AppTextStyles.heading.copyWith(fontSize: 21),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 🔷 안내 메시지
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00949F),
                        ),
                        child: const Center(
                          child: Text(
                            '협상 제안 요청에 대하여,\n요청자에게 의견을 제출해주세요.',
                            style: TextStyle(
                              fontFamily: 'NanumSquare_ac',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // 🔷 의견 입력 박스
                      Container(
                        width: double.infinity,
                        height: 303,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 110,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: const Center(
                                child: Text(
                                  '의견',
                                  style: TextStyle(
                                    fontFamily: 'NanumSquare_ac',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),

                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: TextField(
                                  enabled: !_alreadySubmitted,
                                  controller: _opinionController,
                                  maxLines: null,
                                  expands: true,
                                  textAlignVertical: TextAlignVertical.top,
                                  decoration: const InputDecoration(
                                    hintText: '의견을 작성해주세요.',
                                    border: InputBorder.none,
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'NanumSquare_ac',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 🔽 제출 버튼
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  onPressed:
                      (_isSubmitting || _alreadySubmitted) ? null : _submitOpinion,
                  child: Text(
                    _alreadySubmitted
                        ? '이미 제출됨'
                        : (_isSubmitting ? '제출 중...' : '제출하기'),
                    style: const TextStyle(
                      fontFamily: 'NanumSquare_ac',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) => BottomNavBar.navigateToIndex(context, index),
      ),
    );
  }
}
