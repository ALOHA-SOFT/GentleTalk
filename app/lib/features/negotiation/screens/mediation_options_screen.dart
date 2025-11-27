import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/config.dart';
import '../../user/widgets/bottom_nav_bar.dart';

class MediationOptionsScreen extends StatefulWidget {
  const MediationOptionsScreen({super.key});

  @override
  State<MediationOptionsScreen> createState() => _MediationOptionsScreenState();
}

class _MediationOptionsScreenState extends State<MediationOptionsScreen> {
  String? _issueNo;
  Future<List<String>>? _optionsFuture;
  int? selectedOption;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (_issueNo == null && args != null) {
      _issueNo = args['issueNo']?.toString();
      if (_issueNo != null) {
        _optionsFuture = _fetchMediationOptions(_issueNo!);
      }
    }
  }

  /// issues/{issueNo} 에서 mediationProposals(JSON 배열) 가져와 파싱
  Future<List<String>> _fetchMediationOptions(String issueNo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/issues/$issueNo');
      debugPrint('📡 GET $uri');

      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode != 200) {
        throw Exception('중재안 정보를 불러오지 못했습니다. (${res.statusCode})');
      }

      final data =
          json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

      /// ⚠️ 백엔드에서 내려오는 타입을 모두 커버
      /// case 1) "mediationProposals": "[\"...\",\"...\"]"  (String)
      /// case 2) "mediationProposals": ["...","..."]       (List)
      final raw = data['mediationProposals'];

      if (raw == null) {
        throw Exception('등록된 중재안이 없습니다.');
      }

      List<dynamic> decoded;

      if (raw is String) {
        if (raw.trim().isEmpty) {
          throw Exception('등록된 중재안이 없습니다.');
        }
        decoded = json.decode(raw) as List<dynamic>;
      } else if (raw is List) {
        decoded = raw;
      } else {
        throw Exception('알 수 없는 중재안 데이터 형식입니다. (${raw.runtimeType})');
      }

      final proposals = decoded.map((e) => e.toString()).toList();

      if (proposals.isEmpty) {
        throw Exception('중재안 데이터가 비어있습니다.');
      }

      debugPrint('✅ 불러온 중재안 개수: ${proposals.length}');
      return proposals;
    } catch (e) {
      debugPrint('❌ 중재안 조회 중 오류: $e');
      rethrow;
    }
  }

  /// 선택된 중재안을 서버로 전송하여 selected_proposal(=selectedMediationProposal)에 저장
  Future<bool> _saveSelectedProposal(
      String issueNo, String selectedProposal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url =
          '${AppConfig.baseUrl}/api/v1/issues/$issueNo/select-proposal';
      debugPrint('📡 PUT $url');

      final res = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(selectedProposal),
      );

      debugPrint('✅ 선택 API 응답: ${res.statusCode} ${res.body}');

      if (res.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('❌ 선택 API 호출 중 오류: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<List<String>>(
          future: _optionsFuture,
          builder: (context, snapshot) {
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;
            String? errorMessage;

            if (snapshot.hasError) {
              errorMessage = snapshot.error.toString();
            }

            final proposals = snapshot.data ?? [];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 타이틀
                  const Text(
                    '중재안 제시',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (isLoading) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 12),
                  ],

                  if (errorMessage != null) ...[
                    Text(
                      errorMessage,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
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
                        '아래의 중재안을 선택하여 보내거나,  추가조건을\n입력하거나, 협상가 연결을 선택하실 수 있습니다.',
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

                  // 🔥 실제 중재안 리스트 출력
                  if (!isLoading && errorMessage == null)
                    if (proposals.isNotEmpty)
                      Column(
                        children: [
                          for (int i = 0; i < proposals.length; i++) ...[
                            _buildMediationOption(i + 1, proposals[i]),
                            const SizedBox(height: 10),
                          ]
                        ],
                      )
                    else
                      const Text(
                        '표시할 중재안이 없습니다.',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),

                  const SizedBox(height: 25),

                  // 버튼들
                  _buildSelectButton(proposals),
                  const SizedBox(height: 10),
                  _buildAdditionalConditionButton(proposals),
                  const SizedBox(height: 10),
                  _buildNegotiatorButton(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
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

  // 중재안 선택 버튼
  Widget _buildSelectButton(List<String> proposals) {
    final isEnabled = selectedOption != null && _issueNo != null;

    return Container(
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
          onTap: isEnabled
            ? () async {
                final index = (selectedOption! - 1);
                if (index < 0 || index >= proposals.length) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('선택된 중재안을 찾을 수 없습니다.')),
                  );
                  return;
                }

                final selectedText = proposals[index];

                final ok = await _saveSelectedProposal(_issueNo!, selectedText);

                if (ok) {
                  Navigator.pushNamed(
                    context,
                    '/mediation-send',
                    arguments: {
                      'issueNo': _issueNo,
                      'selectedProposalText': selectedText,
                      'hasAdditionalConditions': false,
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('중재안 저장에 실패했습니다. 다시 시도해주세요.'),
                    ),
                  );
                }
              }
            : null,

          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(
              '최종협상 진행',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isEnabled ? Colors.white : Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 추가 조건 입력 버튼 (선택된 옵션 기반으로 다음 화면에서 활용)
  Widget _buildAdditionalConditionButton(List<String> proposals) {
    final isEnabled = selectedOption != null && _issueNo != null;

    return Container(
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
          onTap: isEnabled
              ? () {
                  final index = (selectedOption! - 1);
                  if (index < 0 || index >= proposals.length) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('선택된 중재안을 찾을 수 없습니다.')),
                    );
                    return;
                  }

                  final selectedText = proposals[index];

                  Navigator.pushNamed(
                    context,
                    '/mediation-send',
                    arguments: {
                      'issueNo': _issueNo,
                      'selectedProposalText': selectedText, // 🔥 실제 제안 텍스트 전달
                      'hasAdditionalConditions': true,      // 🔥 추가 조건 모드
                    },
                  );
                }
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(
              '추가 조건 입력',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isEnabled ? Colors.black : Colors.black.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 협상가 연결 버튼
  Widget _buildNegotiatorButton() {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF46D2FD), Color(0xFF5351F0)],
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
          onTap: () {
            Navigator.pushNamed(context, '/find-negotiator');
          },
          borderRadius: BorderRadius.circular(8),
          child: const Center(
            child: Text(
              '협상가 연결',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 개별 중재안 카드
  Widget _buildMediationOption(int number, String text) {
    final isSelected = selectedOption == number;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = number;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                isSelected ? const Color(0xFF00949F) : const Color(0xFF888888),
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 번호 뱃지
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF00949F),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 텍스트 + 전체보기
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 1.83,
                    ),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('중재안 $number 전체보기'),
                          content: SingleChildScrollView(
                            child: Text(
                              text,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('닫기'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF282B35),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 1.6,
                            offset: const Offset(0, 1.6),
                          ),
                        ],
                      ),
                      child: const Text(
                        '전체보기',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
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
    );
  }
}
