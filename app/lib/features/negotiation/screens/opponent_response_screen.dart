import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/config.dart';
import '../../user/widgets/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpponentResponseScreen extends StatefulWidget {
  const OpponentResponseScreen({super.key});

  @override
  State<OpponentResponseScreen> createState() => _OpponentResponseScreenState();
}

class _OpponentResponseScreenState extends State<OpponentResponseScreen> {
  String? _issueNo;
  String _opponentRequirements = "상대방의 의견이 아직 전달되지 않았습니다.";
  String _processDays = "3일"; // 필요시 백엔드 값으로 교체 가능
  bool _isLoading = true;
  String? _errorMessage;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    _issueNo = args?['issueNo']?.toString();
    debugPrint('💬 [OpponentResponseScreen] issueNo = $_issueNo');

    if (_issueNo == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = '이슈 번호가 없습니다. 다시 시도해주세요.';
      });
      return;
    }

    _fetchIssueDetail();
  }

  /// ✅ /api/v1/issues/{no} 호출해서 opponentRequirements 가져오기
  Future<void> _fetchIssueDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final uri =
          Uri.parse('${AppConfig.baseUrl}/api/v1/issues/$_issueNo');
      debugPrint('📡 [OpponentResponseScreen] GET $uri');

      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode != 200) {
        debugPrint(
            '❌ [OpponentResponseScreen] GET 실패: ${res.statusCode} ${res.body}');
        setState(() {
          _isLoading = false;
          _errorMessage = '이슈 정보를 불러오지 못했습니다. (${res.statusCode})';
        });
        return;
      }

      final data =
          json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      debugPrint('✅ [OpponentResponseScreen] issue data = $data');

      setState(() {
        // 필드명은 백엔드 이슈 엔티티에 맞춰서 사용
        _opponentRequirements = (data['opponentRequirements'] ??
                data['opponent_requirements'] ??
                "상대방의 의견이 아직 전달되지 않았습니다.")
            .toString();

        // processDays도 백엔드에서 내려오면 여기서 세팅
        if (data['processDays'] != null) {
          _processDays = data['processDays'].toString();
        }

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ [OpponentResponseScreen] 예외: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = '이슈 정보를 불러오는 중 오류가 발생했습니다.\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // 타이틀
                    const Text(
                      '상대방 응답 결과 안내',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 25),

                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                    ],

                    // 안내 박스
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00949F),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Text(
                          '상대방이 제출한 의견 내용입니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 🔥 상대방 의견(요구조건) 박스
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      constraints: const BoxConstraints(
                        minHeight: 180,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFF1F1F2)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 상대방 의견 텍스트
                          Container(
                            constraints: const BoxConstraints(
                              minHeight: 180,
                            ),
                            alignment: Alignment.topLeft,
                            child: Text(
                              _opponentRequirements,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF282B35),
                                height: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                          Text(
                            '처리기간 : $_processDays',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF282B35),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 확인 버튼
                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00ADB5), Color(0xFF00576A)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: const Center(
                            child: Text(
                              '확인',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          BottomNavBar.navigateToIndex(context, index);
        },
      ),
    );
  }
}
