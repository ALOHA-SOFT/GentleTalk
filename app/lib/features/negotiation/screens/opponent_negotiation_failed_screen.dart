import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/config.dart';
import '../../user/widgets/bottom_nav_bar.dart';

class OpponentNegotiationFailedScreen extends StatefulWidget {
  const OpponentNegotiationFailedScreen({super.key});

  @override
  State<OpponentNegotiationFailedScreen> createState() =>
      _OpponentNegotiationFailedScreenState();
}

class _OpponentNegotiationFailedScreenState
    extends State<OpponentNegotiationFailedScreen> {
  bool _isExpanded = false;

  String? _issueNo;
  String _proposalText = '';
  bool _isLoading = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    _issueNo = args?['issueNo']?.toString();
    debugPrint('📌 [OpponentNegotiationFailed] issueNo = $_issueNo');

    if (_issueNo != null) {
      _loadIssueDetail();
    } else {
      setState(() {
        _proposalText = '이슈 번호가 없습니다.';
        _isLoading = false;
      });
    }
  }

  /// 🔥 issues/{issueNo} 조회 → selectedMediationProposal 가져오기
  Future<void> _loadIssueDetail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/issues/$_issueNo');
      debugPrint('📡 GET $uri (opponent negotiation failed)');

      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode != 200) {
        throw Exception('이슈 정보를 불러오지 못했습니다. (${res.statusCode})');
      }

      final data =
          json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

      final raw = data['selectedMediationProposal'];

      String text;
      if (raw == null) {
        text = '선택된 최종 협상안이 없습니다.';
      } else if (raw is String) {
        text = raw;
      } else {
        // Map / List 인 경우 보기 좋게 JSON 문자열로 변환
        text = const JsonEncoder.withIndent('  ').convert(raw);
      }

      setState(() {
        _proposalText = text;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ 이슈 조회 오류(opponent negotiation failed): $e');
      setState(() {
        _proposalText = '최종 협상안을 불러오지 못했습니다.';
        _isLoading = false;
      });
    }
  }

  /// 축약본 텍스트 (전체보기 전)
  String get _shortText {
    const maxLen = 80;
    if (_proposalText.length <= maxLen) return _proposalText;
    return '${_proposalText.substring(0, maxLen)}...';
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 타이틀
                      Center(
                        child: Text(
                          '협상 결과',
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 21,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 협상 결렬 안내
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF83062),
                        ),
                        child: const Center(
                          child: Text(
                            '최종 협상이 결렬되었습니다.',
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

                      // 최종 협상안 (축약형/전체보기)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFFFA91D)),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Column(
                          children: [
                            // 최종 협상안 레이블
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 110),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xFFFFA91D)),
                              ),
                              child: const Center(
                                child: Text(
                                  '최종 협상안',
                                  style: TextStyle(
                                    fontFamily: 'NanumSquare_ac',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),

                            // 최종 협상안 내용
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: _isLoading
                                  ? const Center(
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _isExpanded
                                              ? _proposalText
                                              : _shortText,
                                          style: const TextStyle(
                                            fontFamily: 'NanumSquare_ac',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF282B35),
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Container(
                                            width: 60,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF282B35),
                                              borderRadius:
                                                  BorderRadius.circular(3.2),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.25),
                                                  offset:
                                                      const Offset(0, 1.6),
                                                  blurRadius: 1.6,
                                                ),
                                              ],
                                            ),
                                            child: TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _isExpanded = !_isExpanded;
                                                });
                                              },
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          3.2),
                                                ),
                                              ),
                                              child: Text(
                                                _isExpanded ? '접기' : '전체보기',
                                                style: const TextStyle(
                                                  fontFamily:
                                                      'NanumSquare_ac',
                                                  fontSize: 10,
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 하단 버튼
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () {
                    // 문서 다운로드 기능
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('협상안 문서를 다운로드합니다.'),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '협상안 문서로 받아보기',
                    style: TextStyle(
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
        onTap: (index) {
          BottomNavBar.navigateToIndex(context, index);
        },
      ),
    );
  }
}
