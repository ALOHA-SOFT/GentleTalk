import 'package:flutter/material.dart';
import '../../user/widgets/bottom_nav_bar.dart';

class OpponentResponseScreen extends StatelessWidget {
  const OpponentResponseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 arguments에서 데이터 받기
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final opponentAnalysis = args['opponentAnalysis'] ?? "데이터 없음";
    final processDays = args['processDays'] ?? "3일";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // 타이틀
              const Text(
                '상대방 응답 결과 안내',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 25),

              // 안내 박스
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF00949F),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    '상대방의 요구조건을 고려하여 분석한 결과입니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // 🔥 상대방 분석 결과 박스
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                constraints: const BoxConstraints(
                  minHeight: 180,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFF1F1F2)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 상대방 분석 데이터
                    Container(
                      constraints: const BoxConstraints(
                        minHeight: 380,
                      ),
                      alignment: Alignment.topLeft,
                      child: Text(
                        opponentAnalysis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF282B35),
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      '처리기간 : $processDays',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF282B35),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 25),

              // 확인 버튼
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00ADB5), Color(0xFF00576A)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/mediation-options');
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: const Center(
                      child: Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
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
}
