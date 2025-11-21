import 'package:flutter/material.dart';
import '../../user/widgets/bottom_nav_bar.dart';

class MediationSendScreen extends StatefulWidget {
  const MediationSendScreen({super.key});

  @override
  State<MediationSendScreen> createState() => _MediationSendScreenState();
}

class _MediationSendScreenState extends State<MediationSendScreen> {
  final TextEditingController _additionalConditionsController =
      TextEditingController();

  @override
  void dispose() {
    _additionalConditionsController.dispose();
    super.dispose();
  }

  String _getOptionText(int optionNumber) {
    switch (optionNumber) {
      case 1:
        return '임차인은 위약금의 50%를 지불하고, 임대인은 나머지 50%를 감면한다. ...';
      case 2:
        return '임차인은 현재 계약이 종료되기 전까지 직접 새로운 임차인을 찾아 계약을 체결해야 합니다. 새로운 임차인과의 계약이 ....';
      case 3:
        return '임차인이 계약서에 명시된 대로 위약금을 전액 지급하고, ...';
      case 4:
        return '임차인이 위약금을 내는 대신, 임대인이 새로운 세입자를 구할 때 발생하는 ...';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final optionNumber = args?['optionNumber'] as int? ?? 1;
    final hasAdditionalConditions =
        args?['hasAdditionalConditions'] as bool? ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // 타이틀
              Text(
                hasAdditionalConditions ? '추가 조건 입력' : '중재안 발송',
                style: const TextStyle(
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
                    '한 번 발송된 중재안은 번복이 어렵습니다.\n신중히 검토 후 발송해 주세요.',
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
              // 선택된 중재안 박스
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF00949F)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    // 헤더
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 110,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF00949F)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '선택된 중재안',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 중재안 내용
                    Text(
                      _getOptionText(optionNumber),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF282B35),
                        height: 1.5,
                      ),
                    ),
                    if (hasAdditionalConditions) ...[
                      const SizedBox(height: 10),
                      // 추가 조건 헤더
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 110,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF00949F)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '추가 조건',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // 추가 조건 입력 필드
                      Container(
                        height: 95,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF888888)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextField(
                          controller: _additionalConditionsController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            hintText: '추가적으로... 이런 내용을 요청드립니다..',
                            hintStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF00949F),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF282B35),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 25),
              // 버튼들
              // 발송하기 버튼
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
                    onTap: () {
                      Navigator.pushNamed(context, '/mediation-sent');
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: const Center(
                      child: Text(
                        '발송하기',
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
              const SizedBox(height: 10),
              // 다시 선택 버튼
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
                    onTap: () {
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: const Center(
                      child: Text(
                        '다시 선택',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
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
