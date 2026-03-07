import 'package:flutter/material.dart';
import 'package:app/features/formal_notice/screens/formal_notice_form_screen.dart';
import 'package:app/features/user/widgets/bottom_nav_bar.dart';

class FormalNoticeSendScreen extends StatelessWidget {
  const FormalNoticeSendScreen({super.key});

  void _goForm(BuildContext context, String key) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormalNoticeFormScreen(categoryKey: key),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String key,
  ) {
    return InkWell(
      onTap: () => _goForm(context, key),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE9EAEC)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F5FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF3B4BFF)),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12.5, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          '내용 증명 카테고리 선택',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _item(
            context,
            '대여금',
            '상대방에게 빌려준 돈을 돌려받고 싶어요',
            Icons.attach_money,
            'LOAN',
          ),

          const SizedBox(height: 12),

          _item(context, '임대차', '보증금 반환 또는 월세 문제', Icons.home, 'LEASE'),

          const SizedBox(height: 12),

          _item(
            context,
            '계약 관련',
            '계약 위반 또는 이행 요청',
            Icons.description,
            'CONTRACT',
          ),

          const SizedBox(height: 12),

          _item(
            context,
            '회원권 환불',
            '헬스장, 학원, 서비스 환불 요청',
            Icons.refresh,
            'MEMBERSHIP_REFUND',
          ),

          const SizedBox(height: 12),

          _item(context, '직접 작성', '내용 증명을 직접 작성합니다', Icons.edit, 'DIRECT'),

          const SizedBox(height: 12),

          _item(
            context,
            '전문가 의뢰',
            '전문가에게 내용증명 작성을 의뢰합니다',
            Icons.support_agent,
            'EXPERT',
          ),
        ],
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onCenterTap: () {
          Navigator.pushReplacementNamed(context, '/formal-notice-send');
        },
        onTap: (index) {
          BottomNavBar.navigateToIndex(context, index);
        },
      ),
    );
  }
}
