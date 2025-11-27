import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../user/widgets/bottom_nav_bar.dart';

class OpponentMessageViewScreen extends StatelessWidget {
  const OpponentMessageViewScreen({super.key});

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
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 타이틀
                      Center(
                        child: Text(
                          '협상 제안 메시지',
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 21,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 요청자 정보
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEDED),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Color(0xFF888888),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  '요청자',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF888888),
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              '안재림',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 협상 절차 안내
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00949F),
                        ),
                        child: const Center(
                          child: Text(
                            '협상 절차 안내\n의견 제출 → 최종 협상안 수신 → 승인 및 거절',
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

                      // 협상 메시지
                      Container(
                        width: double.infinity,
                        height: 303,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: SingleChildScrollView(
                            child: const Text(
                              '''수신인: [임대인 이름] 
발신인: [임차인 이름] 
제목: [임차인 이름] 임대차 계약 건에 대한 협의 요청

안녕하세요,
[임차인 이름]입니다.
저희의 임대차 계약과 관련하여 원활한 협의를 진행하고자,
갈등조정 플랫폼 '젠틀톡'을 통해 연락드립니다.

저의 현재 상황은 다음과 같습니다.
계약서: [계약서 내용 중 관련 조항]
이사 예정일: [이사 희망 날짜]
감정 소모 없이 합리적인 해결책을 찾고 싶습니다.

본 메시지에 대한 답변을 젠틀톡 플랫폼에 남겨주시면, 
양측의 입장을 정리하여 보다 효율적인 대화를 진행할 수 
있도록 돕겠습니다.

감사합니다.''',
                              style: TextStyle(
                                fontFamily: 'NanumSquare_ac',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                height: 1.5,
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

            // 하단 버튼들
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 의견 제출하기 버튼
                  Container(
                    width: double.infinity,
                    height: 40,
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
                        Navigator.pushNamed(context, '/opponent-opinion-submit');
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '의견 제출하기',
                        style: TextStyle(
                          fontFamily: 'NanumSquare_ac',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 즉시 승인하기 버튼
                  Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF46D2FD), Color(0xFF5351F0)],
                      ),
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
                        Navigator.pushNamed(context, '/negotiation-result');
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '즉시 승인하기',
                        style: TextStyle(
                          fontFamily: 'NanumSquare_ac',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 즉시 승인 안내
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Color(0xFF888888),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        '즉시 승인을 통해 협상을 바로 완료할 수 있습니다.',
                        style: TextStyle(
                          fontFamily: 'NanumSquare_ac',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF888888),
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
