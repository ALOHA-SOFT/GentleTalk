import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/config.dart';

class NegotiationDetailScreen extends StatefulWidget {
  const NegotiationDetailScreen({super.key});

  @override
  State<NegotiationDetailScreen> createState() =>
      _NegotiationDetailScreenState();
}

class _NegotiationDetailScreenState extends State<NegotiationDetailScreen> {
  String? _issueNo; // String 기반으로 유지
  String _initialStatus = '대기';
  bool _isOpponentView = false; // 👈 추가: 상대방 입장 여부
  Future<Map<String, dynamic>>? _detailFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (_issueNo == null && args != null) {
      _initialStatus = (args['status'] ?? '대기').toString();
      _issueNo = args['issueNo']?.toString();
      _isOpponentView = args['isOpponentView'] == true; // 👈 추가: 플래그 세팅

      debugPrint(
          'NegotiationDetail => issueNo=$_issueNo, status=$_initialStatus, isOpponentView=$_isOpponentView');

      if (_issueNo != null) {
        _detailFuture = _fetchIssueDetail(_issueNo!);
      }
    }
  }

  /// issues 상세 조회 API
  Future<Map<String, dynamic>> _fetchIssueDetail(String issueNo) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/issues/$issueNo');
    debugPrint('📡 GET $uri');
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final data = json.decode(utf8.decode(res.bodyBytes));
      return data as Map<String, dynamic>;
    } else {
      throw Exception('상세 정보를 불러오지 못했습니다. (${res.statusCode})');
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '분석중':
        return const Color(0xFF001497);
      case '대기':
        return const Color(0xFF409CFF);
      case '분석완료':
        return const Color(0xFF6EBD82);
      case '분석실패':
        return const Color(0xFFA3A3A3);
      case '중재안제시':
        return const Color(0xFFB452FF);
      case '상대방대기':
        return const Color(0xFFFFB340);
      case '상대방응답':
        return const Color(0xFFD96E40);
      default:
        return const Color(0xFF409CFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailFuture ?? Future.value(<String, dynamic>{}),
        builder: (context, snapshot) {
          // 기본값
          String status = _initialStatus;
          String conflictSituation = '이런 갈등 상황이 있습니다.';
          String requirements = '이런 요구조건이 필요합니다.';
          String analysisResult = '';
          String mediationProposal = '';
          String opponentRequirements = '';
          String negotiationMessage = '';
          String selectedMediationProposal = '';

          String? errorMessage;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          if (snapshot.hasError) {
            errorMessage =
                '이슈 정보를 불러오는 중 오류가 발생했습니다.\n${snapshot.error}';
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final data = snapshot.data!;
            status = (data['status'] ?? status).toString();
            conflictSituation =
                (data['conflictSituation'] ?? conflictSituation).toString();
            requirements = (data['requirements'] ?? requirements).toString();
            analysisResult =
                (data['analysisResult'] ?? analysisResult).toString();
            mediationProposal =
                (data['mediationProposal'] ?? mediationProposal).toString();
            opponentRequirements =
                (data['opponentRequirements'] ?? opponentRequirements)
                    .toString();
            negotiationMessage =
                (data['negotiationMessage'] ?? negotiationMessage).toString();
            selectedMediationProposal =
                (data['selectedMediationProposal'] ?? selectedMediationProposal)
                    .toString();
          }

          final Color statusColor = _getStatusColor(status);

          final String analysisText = status == '대기'
              ? '분석 요청 전입니다.'
              : status == '분석중'
                  ? '분석 중입니다.'
                  : status == '분석실패'
                      ? '분석에 실패했습니다.'
                      : (analysisResult.isEmpty
                          ? '분석내용입니다.'
                          : analysisResult);

          final String negotiationText =
              (status == '대기' || status == '분석중')
                  ? (status == '대기' ? '분석 요청 전입니다.' : '분석 중입니다.')
                  : status == '분석실패'
                      ? '분석에 실패했습니다.'
                      : (negotiationMessage.isNotEmpty
                          ? negotiationMessage
                          : '분석내용에 맞춘 협상 메시지 입니다.');

          final String opponentMsgText = opponentRequirements.isNotEmpty
              ? opponentRequirements
              : '상대방의 응답 메시지가 아직 등록되지 않았습니다.';

          final String mediationText = mediationProposal.isNotEmpty
              ? mediationProposal
              : '중재안이 아직 등록되지 않았습니다.';

          final String finalMediationText = selectedMediationProposal.isNotEmpty
              ? selectedMediationProposal
              : mediationText; // selected 값이 없으면 기존 mediationText fallback

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(25),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 345),
                    child: Column(
                      children: [
                        Text(
                          '협상 내용',
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),

                        if (errorMessage != null) ...[
                          Text(
                            errorMessage,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                        ],
                        if (isLoading) ...[
                          const LinearProgressIndicator(),
                          const SizedBox(height: 8),
                        ],

                        const SizedBox(height: 10),

                        // 상태 표시 영역
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '진행 상태',
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                status,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ✅ 상대방응답 상태일 때: 응답 메시지 섹션
                        if (status == '상대방응답') ...[
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/opponent-response',
                                arguments: {
                                  'issueNo': _issueNo,
                                  'analysisResult': analysisResult,
                                  'opponentMessage': opponentMsgText,
                                },
                              );
                            },
                            child: _InfoSection(
                              title: '상대방 응답 메시지',
                              content: opponentMsgText,
                              titleColor: const Color(0xFFD96E40),
                              borderColor: const Color(0xFFD96E40),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],

                        // ✅ 중재안제시 상태일 때: 최종 협상안 + 상대방 응답 메시지
                        if (status == '중재안제시') ...[
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/mediation-send',
                                arguments: {
                                  'issueNo': _issueNo,
                                  'isFinalNegotiation': true, // 발송 모드
                                },
                              );
                            },
                            child: _InfoSection(
                              title: '최종 협상안',
                              content: finalMediationText,
                              titleColor: const Color(0xFFB452FF),
                              borderColor: const Color(0xFFB452FF),
                            ),
                          ),
                          const SizedBox(height: 10),

                          _InfoSection(
                            title: '상대방 응답 메시지',
                            content: opponentMsgText,
                            titleColor: const Color(0xFFD96E40),
                            borderColor: const Color(0xFFD96E40),
                          ),
                          const SizedBox(height: 10),
                        ],

                        _InfoSection(
                          title: '갈등 상황',
                          content: conflictSituation,
                        ),
                        const SizedBox(height: 10),

                        _InfoSection(
                          title: '요구조건',
                          content: requirements,
                        ),
                        const SizedBox(height: 10),

                        _InfoSection(
                          title: '분석내용',
                          content: analysisText,
                          textColor: status == '분석실패'
                              ? const Color(0xFFF83062)
                              : (status == '대기' || status == '분석중')
                                  ? const Color(0xFF888888)
                                  : AppColors.textPrimary,
                        ),
                        const SizedBox(height: 10),

                        if (status != '중재안제시') ...[
                          _InfoSection(
                            title: '협상 메시지',
                            content: negotiationText,
                            textColor: status == '분석실패'
                                ? const Color(0xFFF83062)
                                : (status == '대기' || status == '분석중')
                                    ? const Color(0xFF888888)
                                    : AppColors.textPrimary,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // ✅ 하단 버튼 영역 (상대방 응답 + 상대방 입장일 때 숨김)
              _buildBottomButtons(context, status, _isOpponentView),
            ],
          );
        },
      ),
    );
  }

  // =======================
  // ⭐ 하단 버튼 영역
  // =======================
  Widget _buildBottomButtons(
      BuildContext context, String status, bool isOpponentView) {
    Widget buildTwoButtons(Widget topBtn, Widget bottomBtn) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 48, child: topBtn),
            const SizedBox(height: 12),
            SizedBox(height: 48, child: bottomBtn),
          ],
        ),
      );
    }

    // 👇 핵심 로직: 상대방 입장 + 상대방응답이면 버튼 숨김
    if (isOpponentView && status == '상대방응답') {
      return const SizedBox.shrink();
    }

    if (status == '대기') {
      return buildTwoButtons(
        _GradientButton(
          text: '✨ 요청 분석',
          onPressed: () => Navigator.pushNamed(
            context,
            '/request-analysis',
            arguments: {'issueNo': _issueNo},
          ),
        ),
        _buildDeleteButton(context),
      );
    }

    if (status == '분석중' || status == '상대방대기') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: _buildDeleteButton(context),
        ),
      );
    }

    if (status == '분석완료') {
      return buildTwoButtons(
        _GradientButton(
          text: '발송하기',
          onPressed: () => Navigator.pushNamed(
            context,
            '/send-request',
            arguments: {'issueNo': _issueNo},
          ),
        ),
        _buildDeleteButton(context),
      );
    }

    if (status == '분석실패') {
      return buildTwoButtons(
        _SpecialButton(
          text: '✨ 다시 분석 요청하기',
          onPressed: () => Navigator.pushNamed(
            context,
            '/request-analysis',
            arguments: {'issueNo': _issueNo},
          ),
        ),
        _buildDeleteButton(context),
      );
    }

    // ✅ 작성자 입장에서만 보이는 '상대방응답' 버튼들
    if (status == '상대방응답') {
      return buildTwoButtons(
        _SpecialButton(
          text: '✨ 중재안 분석 요청하기',
          onPressed: () async {
            if (_issueNo == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('이슈 번호가 없습니다. 다시 시도해주세요.')),
              );
              return;
            }

            final success = await _requestMediationAnalysis(_issueNo!);

            if (success) {
              Navigator.pushNamed(
                context,
                '/mediation-options',
                arguments: {
                  'issueNo': _issueNo,
                  'isFinalNegotiation': false, // 분석 후, 발송 전 단계
                },
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('중재안 분석 요청에 실패했습니다. 다시 시도해주세요.'),
                ),
              );
            }
          },
        ),
        _buildDeleteButton(context),
      );
    }

    // ✅ 중재안제시일 때: 삭제하기만
    if (status == '중재안제시') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: _buildDeleteButton(context),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDeleteButton(BuildContext context) {
    return _OutlineButton(
      text: '삭제하기',
      onPressed: () async {
        if (_issueNo == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이슈 번호가 없습니다. 다시 시도해주세요.')),
          );
          return;
        }

        // 확인 다이얼로그
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('이슈 삭제'),
            content: const Text('정말로 이 협상 이슈를 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('삭제'),
              ),
            ],
          ),
        );

        if (confirmed != true) return;

        final ok = await _deleteIssue(_issueNo!);

        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이슈가 삭제되었습니다.')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('삭제에 실패했습니다. 다시 시도해주세요.')),
          );
        }
      },
    );
  }

  // =======================
  // 🍀 중재안 생성 API 요청
  // =======================
  Future<bool> _requestMediationAnalysis(String issueNo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url =
          '${AppConfig.baseUrl}/api/v1/mediation-logs/generate/$issueNo';
      debugPrint('📡 POST $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        debugPrint('✅ 중재안 분석 요청 성공');
        return true;
      } else {
        debugPrint('❌ Error: ${response.statusCode} | ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
      return false;
    }
  }

  // =======================
  // 🧹 이슈 삭제 API
  // =======================
  Future<bool> _deleteIssue(String issueNo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final url = '${AppConfig.baseUrl}/api/v1/issues/$issueNo';
      debugPrint('📡 DELETE $url');

      final res = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('✅ 삭제 API 응답: ${res.statusCode} ${res.body}');

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      debugPrint('❌ 삭제 API 호출 중 오류: $e');
      return false;
    }
  }
}

// =======================
// 공통 섹션 위젯
// =======================
class _InfoSection extends StatelessWidget {
  final String title;
  final String content;
  final Color textColor;
  final Color? borderColor;
  final Color? titleColor;

  const _InfoSection({
    required this.title,
    required this.content,
    this.textColor = const Color(0xFF282B35),
    this.borderColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: borderColor ?? const Color(0xFFF1F1F2),
        ),
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            alignment: Alignment.center,
            child: Text(
              title,
              style: AppTextStyles.body.copyWith(
                fontSize: 16,
                color: titleColor ?? AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Text(
                content,
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =======================
// 버튼 3종
// =======================
class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _GradientButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: AppTextStyles.button.copyWith(color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecialButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _SpecialButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF46D2FD), Color(0xFF5351F0)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              text,
              style: AppTextStyles.button.copyWith(
                color: AppColors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _OutlineButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF282B35)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.white,
        ),
        child: Text(
          text,
          style: AppTextStyles.button.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
