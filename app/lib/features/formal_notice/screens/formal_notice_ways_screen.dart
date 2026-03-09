import 'package:flutter/material.dart';
import 'package:app/core/constants/colors.dart';
import 'package:app/core/constants/text_styles.dart';
import 'package:app/core/widgets/step_indicator.dart';
import 'package:app/features/user/widgets/bottom_nav_bar.dart';

class FormalNoticeWaysScreen extends StatefulWidget {
  const FormalNoticeWaysScreen({super.key});

  @override
  State<FormalNoticeWaysScreen> createState() => _FormalNoticeWaysScreenState();
}

class _FormalNoticeWaysScreenState extends State<FormalNoticeWaysScreen> {
  String _selectedWay = 'KAKAO';

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '발송 방법 선택',
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const StepIndicator(currentStep: 5, totalSteps: 5),

              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 12),

              _WayCard(
                selected: _selectedWay == 'KAKAO',
                circleColor: const Color(0xFFF8E9A8),
                icon: Icons.chat_bubble_outline,
                iconColor: const Color(0xFFC89A00),
                title: '카카오 발송',
                subtitle: '카카오톡으로 문서 링크 전송',
                price: '15,000원',
                onTap: () {
                  setState(() {
                    _selectedWay = 'KAKAO';
                  });
                },
              ),

              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 14),

              _WayCard(
                selected: _selectedWay == 'SMS',
                circleColor: const Color(0xFFDDF5E3),
                icon: Icons.sms_outlined,
                iconColor: const Color(0xFF16A34A),
                title: 'SMS 발송',
                subtitle: '문자 메시지로 문서 링크 전송',
                price: '15,000원',
                onTap: () {
                  setState(() {
                    _selectedWay = 'SMS';
                  });
                },
              ),

              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 14),

              _WayCard(
                selected: _selectedWay == 'POST',
                circleColor: const Color(0xFFDDE9F9),
                icon: Icons.mail_outline,
                iconColor: AppColors.primary,
                title: '우체국 발송',
                subtitle: '출력 후 등기발송',
                price: '25,000원',
                onTap: () {
                  setState(() {
                    _selectedWay = 'POST';
                  });
                },
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD8E6FF)),
                ),
                child: Text(
                  '💡 우체국 발송은 법적 효력이 가장 강력하여 배달 증명이 제공됩니다.',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 13,
                    height: 1.6,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const Spacer(),

              _buildPrimaryButton(
                '발송하기',
                () {
                  Navigator.pushNamed(
                    context,
                    '/formal-notice-payment',
                    arguments: {
                      'no': args?['no'],
                      'sendWay': _selectedWay,
                    },
                  );
                },
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '삭제하기',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
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
      height: 52,
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
                color: Colors.black.withOpacity(0.18),
                blurRadius: 6,
                offset: const Offset(0, 3),
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

class _WayCard extends StatelessWidget {
  final bool selected;
  final Color circleColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String price;
  final VoidCallback onTap;

  const _WayCard({
    required this.selected,
    required this.circleColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFF7FAFF) : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFFBFD3FF)
                  : Colors.transparent,
              width: 1.4,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      price,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}