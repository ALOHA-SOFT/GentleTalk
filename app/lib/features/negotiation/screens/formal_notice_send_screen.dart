import 'package:flutter/material.dart';
import '../../user/widgets/bottom_nav_bar.dart';

class FormalNoticeSendScreen extends StatefulWidget {
  const FormalNoticeSendScreen({super.key});

  @override
  State<FormalNoticeSendScreen> createState() => _FormalNoticeSendScreenState();
}

class _FormalNoticeSendScreenState extends State<FormalNoticeSendScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  // 선택된 카테고리 키
  String? _selectedCategoryKey;

  // 필요하면 백엔드에서 내려주는 categoryNo 등을 여기로 매핑 가능
  final List<_NoticeCategory> _categories = const [
    _NoticeCategory(
      key: 'LOAN',
      title: '대여금',
      subtitle: '상대방에게 빌려준 돈을 돌려받고 싶어요',
      icon: Icons.attach_money,
    ),
    _NoticeCategory(
      key: 'LEASE',
      title: '임대차',
      subtitle: '보증금 반환 또는 월세 문제',
      icon: Icons.home_outlined,
    ),
    _NoticeCategory(
      key: 'CONTRACT',
      title: '계약 관련',
      subtitle: '계약 이행 요구 또는 계약 위반',
      icon: Icons.description_outlined,
    ),
    _NoticeCategory(
      key: 'MEMBERSHIP_REFUND',
      title: '회원권 환불',
      subtitle: '헬스장, 골프레슨, 학원 환불',
      icon: Icons.card_membership_outlined,
    ),
    _NoticeCategory(
      key: 'DIRECT',
      title: '직접 작성',
      subtitle: 'AI 없이 직접 작성',
      icon: Icons.edit_outlined,
    ),
    _NoticeCategory(
      key: 'EXPERT',
      title: '전문가 의뢰',
      subtitle: '전문가에게 의뢰',
      icon: Icons.support_agent_outlined,
    ),
  ];

  /// (옵션) 추후 API로 카테고리 불러오고 싶으면 이 함수로 교체
  Future<void> _fetchCategoriesIfNeeded() async {
    // 지금은 고정 리스트 사용 (필요 시 구현)
    // 예:
    // final prefs = await SharedPreferences.getInstance();
    // final token = prefs.getString('token');
    // final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/formal-notice/categories');
    // final res = await http.get(uri, headers: {...});
  }

  void _onConfirm() {
    if (_selectedCategoryKey == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('문제 유형을 선택해주세요.')));
      return;
    }

    // ✅ 다음 단계 화면으로 이동 (예시)
    // Navigator.pushNamed(
    //   context,
    //   '/formalNotice/step2',
    //   arguments: {'categoryKey': _selectedCategoryKey},
    // );

    // 지금은 확인만 하고 뒤로가기/혹은 임시 처리
    debugPrint(
      '✅ [FormalNoticeSendScreen] selectedCategory=$_selectedCategoryKey',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('카테고리가 선택되었습니다. (다음 단계로 연결하세요)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _selectedCategoryKey != null && !_isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 6),

                    // 타이틀
                    // 상단 헤더 (뒤로가기 + 타이틀)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(), // 아이콘 버튼 여백 줄이기
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            '내용 증명 카테고리 선택',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Step Indicator (1~5)
                    _StepIndicator(currentStep: 1, totalSteps: 5),

                    const SizedBox(height: 18),

                    // 안내 바
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00949F),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '문제 유형을 선택하세요',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                    ],

                    // 카테고리 리스트
                    Column(
                      children: _categories.map((c) {
                        final selected = c.key == _selectedCategoryKey;
                        return _CategoryTile(
                          category: c,
                          selected: selected,
                          onTap: () {
                            setState(() => _selectedCategoryKey = c.key);
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // 확인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: canConfirm
                                ? const [Color(0xFF00ADB5), Color(0xFF00576A)]
                                : const [Color(0xFFB9C3C7), Color(0xFF8E9AA0)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: canConfirm ? _onConfirm : null,
                            borderRadius: BorderRadius.circular(10),
                            child: const Center(
                              child: Text(
                                '확인',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),

      // 하단 네비게이션 (예시: currentIndex=2는 '협상내역'처럼 보이니 프로젝트에 맞게 조정)
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          BottomNavBar.navigateToIndex(context, index);
        },
      ),
    );
  }
}

/* ----------------------------- UI Components ----------------------------- */

class _NoticeCategory {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;

  const _NoticeCategory({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _CategoryTile extends StatelessWidget {
  final _NoticeCategory category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected
                    ? const Color(0xFF00ADB5)
                    : const Color(0xFFE9EAEC),
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(category.icon, size: 22, color: const Color(0xFF2B2E3A)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2B2E3A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7A7F8C),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (selected)
                  const Icon(Icons.check_circle, color: Color(0xFF00ADB5))
                else
                  const Icon(
                    Icons.radio_button_unchecked,
                    color: Color(0xFFB9BDC6),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep; // 1-based
  final int totalSteps;

  const _StepIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(totalSteps, (i) => i + 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.map((step) {
        final isActive = step == currentStep;
        final isDone = step < currentStep;

        Color bg;
        Color fg;
        if (isActive) {
          bg = const Color(0xFF1F63FF);
          fg = Colors.white;
        } else if (isDone) {
          bg = const Color(0xFF00ADB5);
          fg = Colors.white;
        } else {
          bg = const Color(0xFFE6E8EE);
          fg = const Color(0xFF7A7F8C);
        }

        return Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                '$step',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ),
            if (step != totalSteps)
              Container(
                width: 22,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: const Color(0xFFD8DBE3),
              ),
          ],
        );
      }).toList(),
    );
  }
}
