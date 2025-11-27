import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../user/widgets/bottom_nav_bar.dart';

class OpponentNegotiationSuccessScreen extends StatelessWidget {
  const OpponentNegotiationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 타이틀
                      Center(
                        child: Text(
                          '협상 결과',
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 21,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 협상 완료 안내
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00949F),
                        ),
                        child: const Center(
                          child: Text(
                            '최종 협상안에 승인하였습니다.',
                            style: TextStyle(
                              fontFamily: 'NanumSquare_ac',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 최종 협상안
                      Container(
                        width: double.infinity,
                        height: 303,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Column(
                          children: [
                            // 최종 협상안 레이블
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 110),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: const Center(
                                child: Text(
                                  '최종 협상안',
                                  style: TextStyle(
                                    fontFamily: 'NanumSquare_ac',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),

                            // 최종 협상안 내용
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                child: const SingleChildScrollView(
                                  child: Text(
                                    '''임차인은 계약 종료일까지 직접 새로운 임차인을 찾아 계약을 체결해야 합니다. 새로운 임차인과의 계약이 성사되면 기존 임차인의 계약은 종료되며, 그 시점부터 임대인과 기존 임차인 간의 권리와 의무는 종료됩니다. 만약 임차인이 새로운 임차인을 찾지 못할 경우, 계약 종료일까지 발생하는 의무는 기존 임차인이 계속 부담하게 됩니다. 따라서 임차인은 충분한 시간을 두고 새로운 임차인을 모집하고 계약을 체결해야 합니다.''',
                                    style: TextStyle(
                                      fontFamily: 'NanumSquare_ac',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF282B35),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
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

            // 하단 버튼
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () {
                    // 문서 다운로드 기능
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('협상안 문서를 다운로드합니다.'),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '협상안 문서로 받아보기',
                    style: TextStyle(
                      fontFamily: 'NanumSquare_ac',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          BottomNavBar.navigateToIndex(context, index);
        },
      ),
    );
  }
}
