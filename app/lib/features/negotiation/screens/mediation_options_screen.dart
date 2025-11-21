import 'package:flutter/material.dart';
import '../../user/widgets/bottom_nav_bar.dart';

class MediationOptionsScreen extends StatefulWidget {
  const MediationOptionsScreen({super.key});

  @override
  State<MediationOptionsScreen> createState() => _MediationOptionsScreenState();
}

class _MediationOptionsScreenState extends State<MediationOptionsScreen> {
  int? selectedOption;

  @override
  Widget build(BuildContext context) {
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
                '중재안 제시',
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
                    '아래의 중재안을 선택하여 보내거나,  추가조건을\n입력하거나, 협상가 연결을 선택하실 수 있습니다.',
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
              // 중재안 옵션들
              _buildMediationOption(
                1,
                '임차인은 위약금의 50%를 지불하고,\n임대인은 나머지 50%를 감면한다. ...',
              ),
              const SizedBox(height: 10),
              _buildMediationOption(
                2,
                '임차인이 계약 종료일까지 새로운\n임차인을 직접 찾아 계약을 성사시킨다. ...',
              ),
              const SizedBox(height: 10),
              _buildMediationOption(3, '임차인이 계약서에 명시된 대로\n위약금을 전액 지급하고, ...'),
              const SizedBox(height: 10),
              _buildMediationOption(
                4,
                '임차인이 위약금을 내는 대신, 임대인이 새로운 세입자를 구할 때 발생하는\n...',
              ),
              const SizedBox(height: 25),
              // 버튼들
              // 중재안 선택 버튼
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00ADB5), Color(0xFF00576A)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: selectedOption != null
                        ? () {
                            Navigator.pushNamed(
                              context,
                              '/mediation-send',
                              arguments: {
                                'optionNumber': selectedOption,
                                'hasAdditionalConditions': false,
                              },
                            );
                          }
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Center(
                      child: Text(
                        '중재안 선택',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: selectedOption != null
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // 추가 조건 입력 버튼
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF282B35)),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: selectedOption != null
                        ? () {
                            Navigator.pushNamed(
                              context,
                              '/mediation-send',
                              arguments: {
                                'optionNumber': selectedOption,
                                'hasAdditionalConditions': true,
                              },
                            );
                          }
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Center(
                      child: Text(
                        '추가 조건 입력',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: selectedOption != null
                              ? Colors.black
                              : Colors.black.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // 협상가 연결 버튼
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
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/find-negotiator');
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: const Center(
                      child: Text(
                        '협상가 연결',
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

  Widget _buildMediationOption(int number, String text) {
    final isSelected = selectedOption == number;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = number;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00949F)
                : const Color(0xFF888888),
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 번호 뱃지
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF00949F),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // 텍스트와 전체보기 버튼
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 1.83,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF282B35),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 1.6,
                          offset: const Offset(0, 1.6),
                        ),
                      ],
                    ),
                    child: const Text(
                      '전체보기',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
