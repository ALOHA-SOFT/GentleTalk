import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/config.dart';
import '../../user/widgets/bottom_nav_bar.dart';

class OpponentFinalProposalScreen extends StatefulWidget {
  const OpponentFinalProposalScreen({super.key});

  @override
  State<OpponentFinalProposalScreen> createState() =>
      _OpponentFinalProposalScreenState();
}

class _OpponentFinalProposalScreenState
    extends State<OpponentFinalProposalScreen> {
  String? _issueNo;
  String _proposalText = "";
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    _issueNo = args?['issueNo']?.toString();
    if (_issueNo != null) {
      _loadIssueDetail();
    }
  }

  /// 🔥 issues/{issueNo} 조회 → selectedMediationProposal 가져오기
  Future<void> _loadIssueDetail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/issues/$_issueNo');
      debugPrint('📡 GET $uri (opponent final proposal)');

      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode != 200) {
        throw Exception('이슈 조회 실패 (${res.statusCode})');
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
        text = const JsonEncoder.withIndent('  ').convert(raw);
      }

      setState(() {
        _proposalText = text;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ 오류: $e');
      setState(() {
        _proposalText = '최종 협상안을 불러오지 못했습니다.';
        _isLoading = false;
      });
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
                      // 타이틀
                      Center(
                        child: Text(
                          '최종 협상안 수신',
                          style: AppTextStyles.heading.copyWith(fontSize: 21),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 협상 안내
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00949F),
                        ),
                        child: const Center(
                          child: Text(
                            '협상 요청자로부터 최종 협상안이 도착했습니다.\n승인 또는 거절을 선택하여 협상을 종결합니다.',
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

                      // 최종 협상안 박스
                      Container(
                        width: double.infinity,
                        height: 303,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Column(
                          children: [
                            // 레이블
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

                            // 내용
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: _isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : SingleChildScrollView(
                                        child: Text(
                                          _proposalText,
                                          style: const TextStyle(
                                            fontFamily: 'NanumSquare_ac',
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF282B35),
                                            height: 1.5,
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
              ),
            ),

            // 하단 버튼
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      // 승인 버튼
                      Expanded(
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/opponent-negotiation-success',
                                arguments: {'issueNo': _issueNo},
                              );
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle,
                                    color: Color(0xFF00949F), size: 32),
                                SizedBox(height: 10),
                                Text(
                                  '승인하기',
                                  style: TextStyle(
                                    fontFamily: 'NanumSquare_ac',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00949F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // 거절 버튼
                      Expanded(
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFF83062)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('협상 거절'),
                                  content:
                                      const Text('협상을 거절하시겠습니까?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pushNamed(
                                          context,
                                          '/opponent-negotiation-failed',
                                          arguments: {'issueNo': _issueNo},
                                        );
                                      },
                                      child: const Text('거절'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cancel,
                                    color: Color(0xFFF83062), size: 32),
                                SizedBox(height: 10),
                                Text(
                                  '거절하기',
                                  style: TextStyle(
                                    fontFamily: 'NanumSquare_ac',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF83062),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
