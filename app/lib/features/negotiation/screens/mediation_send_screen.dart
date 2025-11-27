import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/config.dart';
import '../../user/widgets/bottom_nav_bar.dart';

class MediationSendScreen extends StatefulWidget {
  const MediationSendScreen({super.key});

  @override
  State<MediationSendScreen> createState() => _MediationSendScreenState();
}

class _MediationSendScreenState extends State<MediationSendScreen> {
  final TextEditingController _additionalConditionsController =
      TextEditingController();

  String? _issueNo;
  bool _hasAdditionalConditions = false;

  bool _isLoading = true;
  String? _errorMessage;

  /// issues.selectedMediationProposal 값 (최종 협상안)
  String _selectedProposalText = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && _issueNo == null) {
      _issueNo = args['issueNo']?.toString();
      _hasAdditionalConditions =
          (args['hasAdditionalConditions'] as bool?) ?? false;

      // optionNumber / selectedProposalText 를 넘겼어도
      // 최종적으로는 DB 기준(selectedMediationProposal)을 신뢰
      _loadIssueDetail();
    }
  }

  @override
  void dispose() {
    _additionalConditionsController.dispose();
    super.dispose();
  }

  /// issues/{issueNo} 조회해서 selectedMediationProposal 가져오기
  Future<void> _loadIssueDetail() async {
    if (_issueNo == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = '이슈 번호가 없습니다.';
      });
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final uri =
          Uri.parse('${AppConfig.baseUrl}/api/v1/issues/$_issueNo');
      debugPrint('📡 GET $uri (mediation-send)');

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

      // 🔥 issues 테이블의 selectedMediationProposal 사용
      final raw = data['selectedMediationProposal'];

      String text;
      if (raw == null) {
        text = '선택된 중재안이 없습니다.';
      } else if (raw is String) {
        // String 이면 그대로 사용 (JSON 문자열이든, plain 텍스트든)
        text = raw;
      } else {
        // 혹시 Map / List 로 내려오면 보기 좋게 JSON 문자열로 변환
        text = const JsonEncoder.withIndent('  ').convert(raw);
      }

      setState(() {
        _selectedProposalText = text;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      debugPrint('❌ 이슈 조회 오류(mediation-send): $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  /// 중재안 발송 API (예시) – 실제 엔드포인트에 맞게 수정해서 사용
  Future<bool> _sendMediation() async {
    if (_issueNo == null) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final uri = Uri.parse(
          '${AppConfig.baseUrl}/api/v1/issues/$_issueNo/send-mediation');
      debugPrint('📡 POST $uri (send mediation)');

      final body = {
        'additionalConditions': _hasAdditionalConditions
            ? _additionalConditionsController.text.trim()
            : null,
      };

      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        debugPrint('✅ 중재안 발송 성공');
        return true;
      } else {
        debugPrint('❌ 중재안 발송 실패: ${res.statusCode} ${res.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ 중재안 발송 예외: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final issueNo = args?['issueNo'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // 타이틀
              Text(
                _hasAdditionalConditions ? '추가 조건 입력' : '중재안 발송',
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 25),

              if (_isLoading) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
              ],

              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
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
                    '한 번 발송된 중재안은 번복이 어렵습니다.\n신중히 검토 후 발송해 주세요.',
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

              // 선택된 중재안 박스
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00949F)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    // 헤더
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 110,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF00949F)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '선택된 중재안',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 선택된 중재안 내용
                    Container(
                      constraints: const BoxConstraints(
                        minHeight: 200, // 최솟높이
                      ),
                      alignment: Alignment.topLeft, // 🔥 텍스트를 위+왼쪽 정렬
                      child: Text(
                        _selectedProposalText.isNotEmpty
                            ? _selectedProposalText
                            : '선택된 중재안이 없습니다.',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF282B35),
                          height: 1.5,
                        ),
                      ),
                    ),
                    if (_hasAdditionalConditions) ...[
                      const SizedBox(height: 10),
                      // 추가 조건 헤더
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 110,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF00949F)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '추가 조건',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // 추가 조건 입력 필드
                      Container(
                        height: 95,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF888888)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextField(
                          controller: _additionalConditionsController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: '추가 조건이 있다면 입력해주세요.',
                            hintStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF00949F),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF282B35),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // 발송하기 버튼
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00ADB5), Color(0xFF00576A)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final ok = await _sendMediation();
                      if (ok) {
                        Navigator.pushNamed(context, '/mediation-sent');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('중재안 발송에 실패했습니다. 다시 시도해주세요.'),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: const Center(
                      child: Text(
                        '최종협상 진행',
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
              const SizedBox(height: 10),

              // 다시 선택 버튼
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF282B35)),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/mediation-options',
                        arguments: {
                          'issueNo': args?['issueNo'],
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: const Center(
                      child: Text(
                        '다시 선택',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
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
