import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/config.dart';
import '../../user/widgets/bottom_nav_bar.dart';

class NegotiationResultScreen extends StatefulWidget {
  const NegotiationResultScreen({super.key});

  @override
  State<NegotiationResultScreen> createState() =>
      _NegotiationResultScreenState();
}

class _NegotiationResultScreenState extends State<NegotiationResultScreen> {
  bool _initialized = false;

  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _issue;

  String? _status;
  bool _isSuccess = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final issueNo = args['issueNo'];
    _status = args['status'] as String?;

    _isSuccess = _status == '협상완료';

    _fetchIssue(issueNo);
  }

  Future<void> _fetchIssue(dynamic issueNo) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/v1/issues/$issueNo'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _issue = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              '협상 결과를 불러오지 못했습니다. (code: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '오류가 발생했습니다: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String finalProposal =
        (_issue?['selectedMediationProposal'] ?? '').toString().trim();

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
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.body.copyWith(fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(25),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 345,
                            ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 상단 타이틀
                              Center(
                                child: Text(
                                  '협상 결과',
                                  style: AppTextStyles.heading.copyWith(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),

                              // Status Badge
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  color: _isSuccess
                                      ? AppColors.primary
                                      : const Color(0xFFF83062),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _isSuccess
                                      ? '상대방도 수락하여\n협상안이 도착했습니다.'
                                      : '상대방이 거절하여 \n협상이 결렬되었습니다.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 25),

                              if (!_isSuccess) ...[
                                NegotiationBox(
                                  title: '사유',
                                  content:
                                      '상대방 거절 또는 조건 불합의 등으로 합의가 이루어지지 않았습니다.',
                                  borderColor: const Color(0xFF888888),
                                  fixedHeight: 130,
                                ),
                              ],

                              NegotiationBox(
                                title: '최종 협상안',
                                content: finalProposal.isNotEmpty
                                    ? finalProposal
                                    : '등록된 최종 협상안이 없습니다.',
                                borderColor: const Color(0xFFFFA91D),
                                fixedHeight: 250,
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
          // Bottom Button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Export to document
                  // 이때도 _issue와 finalProposal 사용해서 문서 생성하면 됨
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                      '협상안 문서로 받아보기',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          BottomNavBar.navigateToIndex(context, index);
        },
      ),
    );
  }
}

/// 공통 사각형 박스 위젯 (사유 / 최종 협상안 등에 사용)
class NegotiationBox extends StatelessWidget {
  final String title;
  final String content;
  final Color borderColor;
  final double? fixedHeight; // 최소 높이로 쓸 값

  const NegotiationBox({
    super.key,
    required this.title,
    required this.content,
    required this.borderColor,
    this.fixedHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(12),

      // ✅ 여기서 fixedHeight 적용 (최소 높이)
      constraints: fixedHeight != null
          ? BoxConstraints(minHeight: fixedHeight!)
          : const BoxConstraints(),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 영역
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              title,
              style: AppTextStyles.body.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 내용
          Text(
            content,
            style: AppTextStyles.body.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF282B35),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
