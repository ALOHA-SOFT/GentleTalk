import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/config.dart';
import '../../user/widgets/bottom_nav_bar.dart';

class FormalNoticePaymentScreen extends StatelessWidget {
  const FormalNoticePaymentScreen({super.key});

  String _wayLabel(String way) {
    switch (way) {
      case 'KAKAO':
        return '카카오 발송';
      case 'SMS':
        return 'SMS 발송';
      case 'POST':
        return '우체국 발송';
      default:
        return '발송 방식';
    }
  }

  String _priceLabel(String way) {
    switch (way) {
      case 'KAKAO':
        return '15,000원';
      case 'SMS':
        return '15,000원';
      case 'POST':
        return '25,000원';
      default:
        return '0원';
    }
  }

  String _description(String way) {
    switch (way) {
      case 'KAKAO':
        return '카카오톡으로 문서 링크를 전송합니다.';
      case 'SMS':
        return '문자 메시지로 문서 링크를 전송합니다.';
      case 'POST':
        return '출력 후 등기우편으로 발송합니다.';
      default:
        return '선택한 발송 방식 정보입니다.';
    }
  }

  Future<void> _completePaymentAndSend(BuildContext context) async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final no = args?['no'];
    final sendWay = args?['sendWay'];

    if (no == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용증명 번호가 없습니다.')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');

      final res = await http.put(
        Uri.parse(
          '${AppConfig.baseUrl}/api/v1/formal-notice/$no/status?status=발송완료',
        ),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/formal-notice-complete',
          (route) => false,
          arguments: {
            'no': no,
            'sendWay': sendWay,
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('발송 처리 실패: ${res.statusCode} / ${res.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final sendWay = (args?['sendWay'] ?? 'KAKAO').toString();
    final wayLabel = _wayLabel(sendWay);
    final priceLabel = _priceLabel(sendWay);
    final description = _description(sendWay);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '내용증명 발송 결제',
          style: AppTextStyles.heading.copyWith(fontSize: 21),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 345),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F7FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE9EAEC)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '결제 정보',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _InfoRow(label: '발송 방식', value: wayLabel),
                        const SizedBox(height: 10),
                        _InfoRow(label: '안내', value: description),
                        const SizedBox(height: 10),
                        _InfoRow(
                          label: '결제 금액',
                          value: priceLabel,
                          isPrice: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FBFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD7E6FF)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.credit_card,
                            size: 42,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '결제 페이지입니다.',
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '선택한 발송 방식에 따라 결제가 진행됩니다.\n현재는 준비중 화면으로 연결됩니다.',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 15,
                            height: 1.6,
                            color: const Color(0xFF282B35),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildPrimaryButton(
                      '결제 후 발송하기',
                      () => _completePaymentAndSend(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE9EAEC)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Text(
                          '이전으로',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onCenterTap: () {
          Navigator.pushReplacementNamed(context, '/formal-notice-send');
        },
        onTap: (index) {
          BottomNavBar.navigateToIndex(context, index);
        },
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPrice;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isPrice = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isPrice ? const Color(0xFF2563EB) : AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}