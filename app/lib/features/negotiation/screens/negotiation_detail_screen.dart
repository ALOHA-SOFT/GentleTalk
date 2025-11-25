import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  String? _issueNo;           // issues.no
  String _initialStatus = '대기'; // 목록에서 넘어온 status
  Future<Map<String, dynamic>>? _detailFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // 첫 진입 시에만 세팅
    if (_issueNo == null && args != null) {
      _initialStatus = (args['status'] ?? '대기').toString();
      _issueNo = args['issueNo']?.toString(); // 목록에서 넘겨준 no

      debugPrint('NegotiationDetail => issueNo=$_issueNo, status=$_initialStatus');

      if (_issueNo != null) {
        _detailFuture = _fetchIssueDetail(_issueNo!);
      }
    }
  }

  /// issues 테이블 상세 조회 API
  Future<Map<String, dynamic>> _fetchIssueDetail(String issueNo) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/issues/$issueNo');
    debugPrint('📡 GET $uri');   // << 여기
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
      // 항상 같은 폼 유지 + Future 결과로 값만 채우기
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailFuture ?? Future.value(<String, dynamic>{}),
        builder: (context, snapshot) {
          // 1) 기본값 (기존 static 문구 + 목록에서 넘어온 status)
          String status = _initialStatus;
          String conflictSituation = '이런 갈등 상황이 있습니다.';
          String requirements = '이런 요구조건이 필요합니다.';
          String analysisResult = '';
          String mediationProposal = '';

          String? errorMessage;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          // 2) 에러 발생 시: 폼은 유지 + 상단에 에러 문구만
          if (snapshot.hasError) {
            errorMessage =
                '이슈 정보를 불러오는 중 오류가 발생했습니다.\n${snapshot.error}';
          }

          // 3) 데이터 있으면 issues 테이블 값으로 덮어쓰기
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final data = snapshot.data!;

            status = (data['status'] ?? status).toString();
            conflictSituation =
                (data['conflictSituation'] ?? conflictSituation).toString();
            requirements =
                (data['requirements'] ?? requirements).toString();
            analysisResult =
                (data['analysisResult'] ?? analysisResult).toString();
            mediationProposal =
                (data['mediationProposal'] ?? mediationProposal).toString();
          }

          final Color statusColor = _getStatusColor(status);

          // 4) 분석내용 / 협상메시지 문구는 기존 로직 그대로 사용
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
                      : '분석내용에 맞춘 협상 메시지 입니다.';

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

                        // 에러 메시지 (있을 때만)
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

                        // 로딩 표시 (옵션)
                        if (isLoading) ...[
                          const LinearProgressIndicator(),
                          const SizedBox(height: 8),
                        ],

                        const SizedBox(height: 10),

                        // Status Badge (기존 UI 유지)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '진행 상태',
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 175),
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

                        // Info Sections (issues 테이블 값 연동)
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

                        _InfoSection(
                          title: '협상 메시지',
                          content: negotiationText,
                          textColor: status == '분석실패'
                              ? const Color(0xFFF83062)
                              : (status == '대기' || status == '분석중')
                                  ? const Color(0xFF888888)
                                  : AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom Buttons (status에 따라 기존 그대로)
              _buildBottomButtons(context, status),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, String status) {
    if (status == '대기') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Row(
          children: [
            Expanded(
              child: _GradientButton(
                text: '요청 분석',
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/request-analysis',
                  arguments: {'issueNo': _issueNo},
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _OutlineButton(
                text: '삭제하기',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      );
    } else if (status == '분석중' || status == '상대방대기') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: _OutlineButton(
          text: '삭제하기',
          onPressed: () => Navigator.pop(context),
        ),
      );
    } else if (status == '분석완료') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Row(
          children: [
            Expanded(
              child: _GradientButton(
                text: '발송하기',
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/send-request',
                  arguments: {'issueNo': _issueNo},
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _OutlineButton(
                text: '삭제하기',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      );
    } else if (status == '분석실패') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Row(
          children: [
            Expanded(
              child: _SpecialButton(
                text: '✨다시 분석 요청하기',
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/request-analysis',
                  arguments: {'issueNo': _issueNo},
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _OutlineButton(
                text: '삭제하기',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      );
    } else if (status == '상대방응답' || status == '중재안제시') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Row(
          children: [
            Expanded(
              child: _SpecialButton(
                text: '✨중재안 분석 요청하기',
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/request-analysis',
                  arguments: {'issueNo': _issueNo},
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _OutlineButton(
                text: '삭제하기',
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String content;
  final Color textColor;

  const _InfoSection({
    required this.title,
    required this.content,
    this.textColor = const Color(0xFF282B35),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF1F1F2)),
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
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
          style:
              AppTextStyles.button.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
