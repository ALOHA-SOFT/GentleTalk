import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../user/widgets/bottom_nav_bar.dart';

class OpponentOpinionSubmitScreen extends StatefulWidget {
  const OpponentOpinionSubmitScreen({super.key});

  @override
  State<OpponentOpinionSubmitScreen> createState() =>
      _OpponentOpinionSubmitScreenState();
}

class _OpponentOpinionSubmitScreenState
    extends State<OpponentOpinionSubmitScreen> {
  final TextEditingController _opinionController = TextEditingController();

  @override
  void dispose() {
    _opinionController.dispose();
    super.dispose();
  }

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
                          '의견 제출하기',
                          style: AppTextStyles.heading.copyWith(fontSize: 21),
                          textAlign: TextAlign.center,
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
                            '협상 제안 요청에 대하여, \n요청자에게 의견을 제출해주세요.',
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

                      // 협상 메시지 (읽기 전용)
                      Container(
                        width: double.infinity,
                        height: 303,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Column(
                          children: [
                            // 의견 레이블
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
                                  '의견',
                                  style: TextStyle(
                                    fontFamily: 'NanumSquare_ac',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),

                            // 의견 입력 필드
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF888888),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: TextField(
                                  controller: _opinionController,
                                  maxLines: null,
                                  expands: true,
                                  textAlignVertical: TextAlignVertical.top,
                                  decoration: const InputDecoration(
                                    hintText: '제 입장에서는 이런 부분이 추가적으로...',
                                    hintStyle: TextStyle(
                                      fontFamily: 'NanumSquare_ac',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00949F),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'NanumSquare_ac',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
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

            // 하단 제출 버튼
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Container(
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
                    // 의견 제출 로직
                    if (_opinionController.text.isNotEmpty) {
                      Navigator.pushNamed(
                        context,
                        '/opponent-opinion-complete',
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('의견을 입력해주세요.')),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '제출하기',
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
