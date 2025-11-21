import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../user/widgets/bottom_nav_bar.dart';

class NegotiationResultScreen extends StatelessWidget {
  const NegotiationResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Determine success/failure from API
    final bool isSuccess = true;

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 345),
                child: Column(
                  children: [
                    Text(
                      '협상 결과',
                      style: AppTextStyles.heading.copyWith(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Status Badge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: isSuccess
                            ? AppColors.primary
                            : const Color(0xFFF83062),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isSuccess
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
                    if (!isSuccess) ...[
                      // Failure reason
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFF888888),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              alignment: Alignment.center,
                              child: Text(
                                '사유',
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              child: Text(
                                '상대방 거절 또는 조건 불합의 등으로 합의가 이루어지지 않았습니다.',
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 16,
                                  color: const Color(0xFF282B35),
                                  fontWeight: FontWeight.w700,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                    // Final Negotiation Result
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: isSuccess
                              ? const Color(0xFFFFA91D)
                              : const Color(0xFFFFA91D),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            alignment: Alignment.center,
                            child: Text(
                              '최종 협상안',
                              style: AppTextStyles.body.copyWith(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isSuccess
                                      ? '''임차인은 계약 종료일까지 직접 새로운 임차인을 찾아 계약을 체결해야 합니다. 새로운 임차인과의 계약이 성사되면 기존 임차인의 계약은 종료되며, 그 시점부터 임대인과 기존 임차인 간의 권리와 의무는 종료됩니다. 만약 임차인이 새로운 임차인을 찾지 못할 경우, 계약 종료일까지 발생하는 의무는 기존 임차인이 계속 부담하게 됩니다. 따라서 임차인은 충분한 시간을 두고 새로운 임차인을 모집하고 계약을 체결해야 합니다.'''
                                      : '''임차인은 계약 종료일까지 직접 새로운 임차인을 찾아 계약을 체결해야 합니다. 새로운 임차인과의 계약이 성사되면 기존 임차인의 계약은 종료되며, ...''',
                                  style: AppTextStyles.body.copyWith(
                                    fontSize: 16,
                                    color: const Color(0xFF282B35),
                                    fontWeight: FontWeight.w700,
                                    height: 1.5,
                                  ),
                                ),
                                if (!isSuccess) ...[
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 20,
                                    child: OutlinedButton(
                                      onPressed: () {},
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 58,
                                          vertical: 6,
                                        ),
                                        side: BorderSide.none,
                                        backgroundColor: const Color(
                                          0xFF282B35,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            3.2,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        '전체보기',
                                        style: AppTextStyles.button.copyWith(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
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
