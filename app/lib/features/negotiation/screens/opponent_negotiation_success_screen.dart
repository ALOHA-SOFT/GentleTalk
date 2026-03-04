import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/config.dart';
import '../../user/widgets/bottom_nav_bar.dart';

class OpponentNegotiationSuccessScreen extends StatefulWidget {
  const OpponentNegotiationSuccessScreen({super.key});

  @override
  State<OpponentNegotiationSuccessScreen> createState() =>
      _OpponentNegotiationSuccessScreenState();
}

class _OpponentNegotiationSuccessScreenState
    extends State<OpponentNegotiationSuccessScreen> {
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
    debugPrint('📌 [OpponentNegotiationSuccess] issueNo = $_issueNo');

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
      debugPrint('📡 GET $uri (opponent negotiation success)');

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

      final selectedProposal = data['selectedMediationProposal'];
      final analysisResult = data['analysisResult'];

      String text;
      if (selectedProposal != null) {
        // selectedMediationProposal이 있으면 우선 사용
        if (selectedProposal is String) {
          text = selectedProposal;
        } else {
          text = const JsonEncoder.withIndent('  ').convert(selectedProposal);
        }
      } else if (analysisResult != null) {
        // selectedMediationProposal이 없으면 analysisResult 사용
        if (analysisResult is String) {
          text = analysisResult;
        } else {
          text = const JsonEncoder.withIndent('  ').convert(analysisResult);
        }
      } else {
        text = '협상안 정보가 없습니다.';
      }

      setState(() {
        _proposalText = text;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ 이슈 조회 오류(opponent negotiation success): $e');
      setState(() {
        _proposalText = '최종 협상안을 불러오지 못했습니다.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // 🔥 안드로이드 뒤로가기 / 제스처 뒤로가기 제어
      onWillPop: () async {
        // 뒤로가기 누르면 Home 탭으로 이동
        BottomNavBar.navigateToIndex(context, 0);
        // 현재 화면 pop은 막기
        return false;
      },
      child: Scaffold(
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
                            '협상 결과',
                            style: AppTextStyles.heading.copyWith(
                              fontSize: 21,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // 협상 완료 안내
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00949F),
                          ),
                          child: const Center(
                            child: Text(
                              '최종 협상안에 승인하였습니다.',
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

                        // 최종 협상안
                        Container(
                          width: double.infinity,
                          height: 303,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Column(
                            children: [
                              // 최종 협상안 레이블
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

                              // 최종 협상안 내용
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
                      // 문서 다운로드 기능 (TODO: 실제 다운로드 구현)
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
      ),
    );
  }
}
