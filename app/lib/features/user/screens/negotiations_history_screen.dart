import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../widgets/bottom_nav_bar.dart';

class NegotiationsHistoryScreen extends StatelessWidget {
  const NegotiationsHistoryScreen({super.key});

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
          '협상 내역',
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
                    _buildHistoryCard('2025.11.11', '프리랜서 계약 조건 분석 중'),
                    const SizedBox(height: 10),
                    _buildHistoryCard('2025.11.10', '프리랜서 계약 조건 분석 중'),
                    const SizedBox(height: 10),
                    _buildHistoryCard('2025.11.10', '프리랜서 계약 조건 분석 중'),
                    const SizedBox(height: 10),
                    _buildHistoryCard('2025.11.10', '프리랜서 계약 조건 분석 중'),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          BottomNavBar.navigateToIndex(context, index);
        },
      ),
    );
  }

  Widget _buildHistoryCard(String date, String title) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/negotiation-result',
            arguments: {'date': date, 'title': title},
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
          child: Row(
            children: [
              // Icon
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFF1DCBD3),
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
                      date,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 9,
                        color: const Color(0xFF797979),
                        fontWeight: FontWeight.w700,
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
                  ],
                ),
              ),
              // More Icon
              Icon(Icons.more_vert, size: 22, color: AppColors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
