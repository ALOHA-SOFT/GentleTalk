import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../widgets/primary_button.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
          '이용약관',
          style: AppTextStyles.heading.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Terms Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: AppColors.primary,
            child: Text(
              '젠틀톡 서비스 이용 약관',
              textAlign: TextAlign.center,
              style: AppTextStyles.button.copyWith(color: AppColors.white),
            ),
          ),
          // Terms Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '최종 업데이트: 2025년 9월 26일',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _termsContent,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.darkBackground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Confirm Button
          Padding(
            padding: const EdgeInsets.all(24),
            child: PrimaryButton(
              text: '확인',
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  static const String _termsContent = '''제1조 (목적)
본 약관은 '팀 아르테미스'가 제공하는 '젠틀톡(Gentle Talk)' 서비스(이하 '서비스')의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임 사항을 규정함을 목적으로 합니다.

제2조 (서비스의 정의 및 특징)
서비스의 목적: '젠틀톡'은 일상생활 속의 갈등을 소송 없이 현명하게 해결할 수 있도록 돕는 비소송형 갈등조정 서비스 플랫폼입니다.

서비스의 특징:
• AI 기반 중재: 사용자의 감정적인 글을 AI가 사실과 조건 중심으로 정리하여 불필요한 감정 충돌을 줄이고 중립적인 대화를 시작할 수 있게 돕습니다.
• 데이터 기반 협상 지원: 양측의 조건을 자동으로 비교하여 시각화하고, 유사 사례의 합의 결과를 제공하여 합리적인 선택을 돕습니다.
• 하이브리드 조정: 기본적인 갈등은 AI 자동 조정으로 해결하며, 필요시 전문 중재자 연결 옵션을 통해 신뢰성과 성공률을 높입니다.

제3조 (서비스 이용)
이용자격: 본 서비스는 소액 민사 갈등을 경험했거나 겪고 있는 개인을 주된 초기 고객으로 정의하며, 법적 대응이 부담스럽고 상대방과의 직접 대화가 어려운 사용자를 대상으로 합니다.

서비스 종류:
• 기본 서비스: 무료로 제공됩니다.
• 프리미엄 기능: 갈등조정 전문가 연결, 맞춤형 조정안 도출, 심화 시뮬레이션 등의 기능은 유료로 제공됩니다.

제4조 (이용자의 책임과 의무)
이용자는 본 서비스를 갈등 해결이라는 본래의 목적에 맞게 사용하여야 하며, 불법적이거나 부적절한 목적으로 사용해서는 안 됩니다.
이용자는 서비스에 제공하는 모든 정보(갈등 내용 등)에 대해 정확하고 신뢰할 수 있도록 노력해야 합니다.

제5조 (면책 조항)
법률 자문 아님: '젠틀톡'은 법률 자문이나 법률 대리 서비스를 제공하지 않습니다. 본 서비스는 법률 전문가의 자문을 대체할 수 없으며, 모든 결정과 책임은 이용자 본인에게 있습니다.
결과에 대한 책임 한계: 본 서비스를 통해 도출된 협상안이나 합의 결과에 대해 회사는 어떠한 법적 책임도 지지 않습니다.

제6조 (개인정보 보호 및 데이터 활용)
회사는 서비스 제공을 위해 이용자의 정보를 수집하며, 관련 법령에 따라 안전하게 관리합니다.
이용자는 서비스 개선 및 연구개발을 위해 회사가 익명화된 데이터를 활용하는 것에 동의합니다. 이는 AI 기반 분석 및 유사 사례 데이터 구축을 포함합니다.

제7조 (서비스 중단 및 종료)
회사는 서비스의 안정적인 운영을 위해 필요시 서비스의 전부 또는 일부를 일시적으로 중단할 수 있습니다.
회사는 본 약관 위반 등 부적절한 행위를 한 이용자에 대해 사전 통보 없이 서비스 이용을 제한하거나 계약을 해지할 수 있습니다.''';
}
