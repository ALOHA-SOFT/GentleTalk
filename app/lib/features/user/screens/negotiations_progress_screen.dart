import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../widgets/bottom_nav_bar.dart';

class NegotiationsProgressScreen extends StatelessWidget {
  const NegotiationsProgressScreen({super.key});

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
        title: Text(
          '진행중인 협상',
          style: AppTextStyles.heading.copyWith(fontSize: 21),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 345),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNegotiationCard(
                      context,
                      '분석중',
                      '프리랜서 계약 조건 분석 중',
                      '2025.11.11',
                      '2/6',
                      const Color(0xFF001497),
                    ),
                    const SizedBox(height: 25),
                    _buildNegotiationCard(
                      context,
                      '대기',
                      '룸메이트 청소 담당 정하기',
                      '2025.11.11',
                      '1/6',
                      const Color(0xFF409CFF),
                    ),
                    const SizedBox(height: 25),
                    _buildNegotiationCard(
                      context,
                      '분석완료',
                      '일정 합의안 분석 완료',
                      '2025.11.11',
                      '3/6',
                      const Color(0xFF6EBD82),
                    ),
                    const SizedBox(height: 25),
                    _buildNegotiationCard(
                      context,
                      '중재안제시',
                      '협상 제안서 전달 완료 – 응답 대기',
                      '2025.11.11',
                      '4/6',
                      const Color(0xFFB452FF),
                    ),
                    const SizedBox(height: 25),
                    _buildNegotiationCard(
                      context,
                      '상대방대기',
                      'AI 추천: 임대료 절충안',
                      '2025.11.11',
                      '5/6',
                      const Color(0xFFFFB340),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
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

  Widget _buildNegotiationCard(
    BuildContext context,
    String status,
    String title,
    String date,
    String progress,
    Color progressColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/negotiation-detail',
          arguments: {'status': status},
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14.5),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F6),
          borderRadius: BorderRadius.circular(7.3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 9.08,
              offset: const Offset(0, 4.54),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(5.45),
                  ),
                  child: const Icon(
                    Icons.folder_outlined,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10.9),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.toUpperCase(),
                        style: AppTextStyles.body.copyWith(
                          fontSize: 9,
                          color: const Color(0xFF797979),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.45,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 11.8,
                          color: const Color(0xFF1B1212),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 9,
                          color: const Color(0xFF797979),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                // More Icon
                Icon(Icons.more_vert, size: 22, color: AppColors.textPrimary),
              ],
            ),
            const SizedBox(height: 16),
            // Progress Bar
            Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9E9E9),
                          borderRadius: BorderRadius.circular(90),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: 0.33, // 2/6 약 33%
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: progressColor,
                            borderRadius: BorderRadius.circular(90),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10.9),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7.3,
                    vertical: 9.08,
                  ),
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(90),
                  ),
                  child: Text(
                    progress,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.45,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
