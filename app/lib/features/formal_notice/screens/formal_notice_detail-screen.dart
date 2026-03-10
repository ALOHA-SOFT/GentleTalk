import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/config.dart';

class FormalNoticeDetailScreen extends StatefulWidget {
  const FormalNoticeDetailScreen({super.key});

  @override
  State<FormalNoticeDetailScreen> createState() =>
      _FormalNoticeDetailScreenState();
}

class _FormalNoticeDetailScreenState extends State<FormalNoticeDetailScreen> {
  String? _formalNoticeNo;
  String _initialStatus = '대기';
  Future<Map<String, dynamic>>? _detailFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (_formalNoticeNo == null && args != null) {
      _initialStatus = (args['status'] ?? '대기').toString();
      _formalNoticeNo =
          (args['no'] ?? args['formalNoticeNo'] ?? args['id'])?.toString();

      debugPrint(
        'FormalNoticeDetail => no=$_formalNoticeNo, status=$_initialStatus',
      );

      if (_formalNoticeNo != null) {
        _detailFuture = _fetchFormalNoticeDetail(_formalNoticeNo!);
      }
    }
  }

  Future<Map<String, dynamic>> _fetchFormalNoticeDetail(String no) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/formal-notice/$no');
    debugPrint('📡 GET $uri');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      final data = json.decode(utf8.decode(res.bodyBytes));
      return data as Map<String, dynamic>;
    } else {
      throw Exception('상세 정보를 불러오지 못했습니다. (${res.statusCode})');
    }
  }

  Future<(bool, String)> _deleteFormalNotice(String no) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');

      final url = '${AppConfig.baseUrl}/api/v1/formal-notice/$no';
      debugPrint('📡 DELETE $url');

      final res = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final responseText = utf8.decode(res.bodyBytes);
      debugPrint('✅ 삭제 API 응답: ${res.statusCode} $responseText');

      if (res.statusCode == 200 || res.statusCode == 204) {
        return (
          true,
          responseText.isNotEmpty ? responseText : '내용증명이 삭제되었습니다.',
        );
      }

      return (
        false,
        responseText.isNotEmpty ? responseText : '삭제에 실패했습니다. 다시 시도해주세요.',
      );
    } catch (e) {
      debugPrint('❌ 삭제 API 호출 중 오류: $e');
      return (false, '삭제 중 오류가 발생했습니다.');
    }
  }

  String _formatCreatedAt(String raw) {
    if (raw.trim().isEmpty) return '';

    try {
      final dateTime = DateTime.parse(raw).toLocal();
      return DateFormat('yyyy.MM.dd HH:mm').format(dateTime);
    } catch (e) {
      debugPrint('날짜 파싱 실패: $e');
      return raw;
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
      case '발송완료':
      case '완료':
        return const Color(0xFF1DCBD3);
      default:
        return const Color(0xFF409CFF);
    }
  }

  String _categoryName(String key) {
    switch (key) {
      case 'LOAN':
        return '대여금';
      case 'LEASE':
        return '임대차';
      case 'CONTRACT':
        return '계약 관련';
      case 'MEMBERSHIP_REFUND':
        return '회원권 환불';
      case 'DIRECT':
        return '직접 작성';
      case 'EXPERT':
        return '전문가 의뢰';
      default:
        return '내용증명';
    }
  }

  String _categoryDataToText(dynamic raw) {
    if (raw == null) return '입력된 상세 정보가 없습니다.';

    if (raw is Map) {
      if (raw.isEmpty) return '입력된 상세 정보가 없습니다.';

      final buffer = StringBuffer();
      raw.forEach((key, value) {
        buffer.writeln('$key : ${value ?? ''}');
      });
      return buffer.toString().trim();
    }

    return raw.toString();
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
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailFuture ?? Future.value(<String, dynamic>{}),
        builder: (context, snapshot) {
          String status = _initialStatus;
          String categoryKey = '';
          String senderName = '';
          String senderPhone = '';
          String senderAddress = '';
          String receiverName = '';
          String receiverPhone = '';
          String receiverAddress = '';
          String previewText = '';
          String createdAt = '';
          dynamic categoryData;

          String? errorMessage;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          if (snapshot.hasError) {
            errorMessage =
                '내용증명 정보를 불러오는 중 오류가 발생했습니다.\n${snapshot.error}';
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final data = snapshot.data!;
            status = (data['status'] ?? status).toString();
            categoryKey = (data['categoryKey'] ?? '').toString();
            senderName = (data['senderName'] ?? '').toString();
            senderPhone = (data['senderPhone'] ?? '').toString();
            senderAddress = (data['senderAddress'] ?? '').toString();
            receiverName = (data['receiverName'] ?? '').toString();
            receiverPhone = (data['receiverPhone'] ?? '').toString();
            receiverAddress = (data['receiverAddress'] ?? '').toString();
            previewText = (data['previewText'] ?? '').toString();
            createdAt = (data['createdAt'] ?? '').toString();
            categoryData = data['categoryData'];
          }

          final Color statusColor = _getStatusColor(status);
          final String categoryName = _categoryName(categoryKey);

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
                          '내용증명 상세',
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

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
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

                        _InfoSection(
                          title: '카테고리',
                          content: categoryName,
                        ),
                        const SizedBox(height: 10),

                        _InfoSection(
                          title: '발신인 정보',
                          content:
                              '이름: $senderName\n연락처: $senderPhone\n주소: $senderAddress',
                        ),
                        const SizedBox(height: 10),

                        _InfoSection(
                          title: '수신인 정보',
                          content:
                              '이름: $receiverName\n연락처: $receiverPhone\n주소: $receiverAddress',
                        ),
                        const SizedBox(height: 10),

                        // _InfoSection(
                        //   title: '입력 정보',
                        //   content: _categoryDataToText(categoryData),
                        // ),
                        // const SizedBox(height: 10),

                        _InfoSection(
                          title: '생성된 내용증명',
                          content: previewText.isNotEmpty
                              ? previewText
                              : '생성된 내용이 없습니다.',
                        ),
                        const SizedBox(height: 10),

                        if (createdAt.isNotEmpty) ...[
                          _InfoSection(
                            title: '작성일',
                            content: _formatCreatedAt(createdAt),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomButtons(context, status, categoryKey),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomButtons(
    BuildContext context,
    String status,
    String categoryKey,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (status == '분석완료' || status == '대기') ...[
            SizedBox(
              height: 48,
              child: _GradientButton(
                text: '발송하기',
                onPressed: () {
                  if (_formalNoticeNo == null || _formalNoticeNo!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('내용증명 번호가 없습니다.')),
                    );
                    return;
                  }

                  Navigator.pushNamed(
                    context,
                    '/formal-notice-payment',
                    arguments: {
                      'no': _formalNoticeNo,
                      'status': status,
                      'categoryKey': categoryKey,
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            height: 48,
            child: _OutlineButton(
              text: '삭제하기',
              onPressed: () async {
                if (_formalNoticeNo == null || _formalNoticeNo!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('내용증명 번호가 없습니다.')),
                  );
                  return;
                }

                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('내용증명 삭제'),
                    content: const Text('정말로 이 내용증명을 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text(
                          '삭제',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed != true) return;

                final result = await _deleteFormalNotice(_formalNoticeNo!);

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.$2)),
                );

                if (result.$1) {
                  Navigator.pop(context, true);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

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
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
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

  const _GradientButton({
    required this.text,
    required this.onPressed,
  });

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
              text,
              style: AppTextStyles.button.copyWith(color: AppColors.white),
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

  const _OutlineButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF282B35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.white,
        ),
        child: Text(
          text,
          style: AppTextStyles.button.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}