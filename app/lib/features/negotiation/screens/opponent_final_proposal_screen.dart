import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../user/widgets/bottom_nav_bar.dart';

class OpponentFinalProposalScreen extends StatelessWidget {
  const OpponentFinalProposalScreen({super.key});

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 타이틀
                      Center(
                        child: Text(
                          '최종 협상안 수신',
                          style: AppTextStyles.heading.copyWith(fontSize: 21),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 협상 안내
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00949F),
                        ),
                        child: const Center(
                          child: Text(
                            '협상 요청자로부터, 최종 협상안이 도착했습니다. \n승인 또는 거절을 선택하여 협상을 종결합니다.',
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
                                vertical: 6,
                                horizontal: 110,
                              ),
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
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF888888),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
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

            // 하단 버튼 영역
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 안내 메시지
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(color: Colors.white),
                        child: const Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Color(0xFF888888),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        '협상의 최종 단계입니다. 신중하게 선택해 주세요.',
                        style: TextStyle(
                          fontFamily: 'NanumSquare_ac',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 승인/거절 버튼
                  Row(
                    children: [
                      // 승인하기 버튼
                      Expanded(
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.primary),
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
                              Navigator.pushNamed(
                                context,
                                '/opponent-negotiation-success',
                              );
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF00949F),
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  '승인하기',
                                  style: TextStyle(
                                    fontFamily: 'NanumSquare_ac',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00949F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // 거절하기 버튼
                      Expanded(
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFF83062)),
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
                              // 거절 로직
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('협상 거절'),
                                  content: const Text('협상을 거절하시겠습니까?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pushNamed(
                                          context,
                                          '/opponent-negotiation-failed',
                                        );
                                      },
                                      child: const Text('거절'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: const Icon(
                                    Icons.cancel,
                                    color: Color(0xFFF83062),
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  '거절하기',
                                  style: TextStyle(
                                    fontFamily: 'NanumSquare_ac',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF83062),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
