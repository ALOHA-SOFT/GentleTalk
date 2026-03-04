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

  /// 🔥 DB flag (mediationSentYn) 값
  bool _alreadySent = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && _issueNo == null) {
      _issueNo = args['issueNo']?.toString();
      _hasAdditionalConditions =
          (args['hasAdditionalConditions'] as bool?) ?? false;

      // 🔥 arguments로 전달된 selectedProposalText가 있으면 우선 사용
      final passedProposal = args['selectedProposalText'] as String?;
      if (passedProposal != null && passedProposal.isNotEmpty) {
        setState(() {
          _selectedProposalText = passedProposal;
          _isLoading = false;
        });
        // API 호출은 발송 여부 확인용으로만
        _checkMediationSentStatus();
      } else {
        // 전달된 값이 없으면 기존대로 API로 불러오기
        _loadIssueDetail();
      }
    }
  }

  @override
  void dispose() {
    _additionalConditionsController.dispose();
    super.dispose();
  }

  /// issues/{issueNo} 조회해서 selectedMediationProposal + mediationSentYn 가져오기
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

      // 🔥 DB flag(mediationSentYn) 읽어서 이미 발송 여부 반영
      final mediationSentYnRaw = data['flag'];

      // null 방어 + 공백 제거
      String yn = (mediationSentYnRaw ?? '').toString().trim();

      // 전각(풀와이드) 문자 -> 반각으로 변환
      yn = yn
          .replaceAll('Ｙ', 'Y')
          .replaceAll('Ｎ', 'N');

      // 최종 비교
      final alreadySent = yn.toUpperCase() == 'Y';

      debugPrint('flag(mediationSentYn): $yn, alreadySent: $alreadySent');

      setState(() {
        _selectedProposalText = text;
        _alreadySent = alreadySent;
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

  /// 발송 여부만 확인하는 API (중재안 텍스트는 이미 전달받은 상태)
  Future<void> _checkMediationSentStatus() async {
    if (_issueNo == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final uri =
          Uri.parse('${AppConfig.baseUrl}/api/v1/issues/$_issueNo');
      debugPrint('📡 GET $uri (check sent status only)');

      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data =
            json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

        final mediationSentYnRaw = data['flag'];
        String yn = (mediationSentYnRaw ?? '').toString().trim();
        yn = yn.replaceAll('Ｙ', 'Y').replaceAll('Ｎ', 'N');
        final alreadySent = yn.toUpperCase() == 'Y';

        debugPrint('flag(mediationSentYn): $yn, alreadySent: $alreadySent');

        setState(() {
          _alreadySent = alreadySent;
        });
      }
    } catch (e) {
      debugPrint('❌ 발송 상태 확인 오류: $e');
    }
  }

  /// 중재안 발송 API
  Future<bool> _sendMediation() async {
    if (_issueNo == null) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final uri = Uri.parse(
          '${AppConfig.baseUrl}/api/v1/issues/$_issueNo/send-mediation');
      debugPrint('📡 PUT $uri (send mediation)');

      // 추가 조건 입력 모드일 때는 입력된 텍스트를, 아니면 빈 문자열 전송
      final additionalConditionsText = _hasAdditionalConditions
          ? _additionalConditionsController.text.trim()
          : '';

      final body = {
        'additionalConditions': additionalConditionsText,
      };

      debugPrint('📤 발송 데이터: $body');
      debugPrint('추가조건 모드: $_hasAdditionalConditions, 추가조건: "$additionalConditionsText"');

      final res = await http.put(
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

    // 필요하면 issueNo 사용
    // final issueNo = args?['issueNo'];

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
                      alignment: Alignment.topLeft, // 텍스트를 위+왼쪽 정렬
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

              // 🔥 발송 여부에 따른 버튼 분기
              if (_alreadySent) ...[
                // 이미 발송된 상태
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // 👉 목록 화면으로 이동 (route 이름은 실제 사용하는 걸로 맞춰줘)
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/negotiations-progress', // TODO: 필요 시 route 이름 변경
                          (route) => false,
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: const Center(
                        child: Text(
                          '이미 발송이 완료되었습니다.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // 발송 전: 기존 버튼들
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
              ],
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
