import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../widgets/bottom_nav_bar.dart';

class FindNegotiatorScreen extends StatelessWidget {
  const FindNegotiatorScreen({super.key});

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
          '협상가 찾기',
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
                  children: [
                    const SizedBox(height: 10),
                    _buildNegotiatorCard('김도윤', '이혼 및 위자료 협상 전문 변호사'),
                    const SizedBox(height: 10),
                    _buildNegotiatorCard('박소연', '교통사고 및 보험금 합의 전문 협상가'),
                    const SizedBox(height: 10),
                    _buildNegotiatorCard('이준호', '부동산 매매 및 임대 협상 컨설턴트'),
                    const SizedBox(height: 10),
                    _buildNegotiatorCard('정하나', '기업 분쟁 및 계약 조건 조율 전문 협상 전문가'),
                    const SizedBox(height: 10),
                    _buildNegotiatorCard('최민석', '형사 사건 합의 및 손해배상 협상 중재인'),
                    const SizedBox(height: 10),
                    _buildNegotiatorCard('오유진', '가족 관계 및 상속 분쟁 협상 전문 코치'),
                    const SizedBox(height: 10),
                    _buildNegotiatorCard('한재호', '노사 분쟁 및 급여 협상 전문 컨설턴트'),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          BottomNavBar.navigateToIndex(context, index);
        },
      ),
    );
  }

  Widget _buildNegotiatorCard(String name, String specialty) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.82,
        ),
        borderRadius: BorderRadius.circular(7.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2.73,
            offset: const Offset(0, 1.82),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 36.37,
            height: 36.37,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: Icon(Icons.person, size: 24, color: Colors.white),
          ),
          const SizedBox(width: 14.55),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14.55,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B1212),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  specialty,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 11.82,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF797979),
                  ),
                ),
              ],
            ),
          ),
          // Check Icon
          Container(
            width: 21.82,
            height: 21.82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFDAA5FF),
                  const Color(0xFFAED3FF),
                  const Color(0xFF86FFFA),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Icon(Icons.check, size: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
