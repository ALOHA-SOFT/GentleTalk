import 'package:app/core/widgets/step_indicator.dart';
import 'package:app/features/formal_notice/screens/formal_notice_generate_screen.dart';
import 'package:app/features/user/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class FormalNoticeFormScreen extends StatefulWidget {
  final String categoryKey;

  const FormalNoticeFormScreen({super.key, required this.categoryKey});

  @override
  State<FormalNoticeFormScreen> createState() => _FormalNoticeFormScreenState();
}

class _FormalNoticeFormScreenState extends State<FormalNoticeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _senderName = TextEditingController();
  final _senderPhone = TextEditingController();
  final _senderAddress = TextEditingController();

  final _receiverName = TextEditingController();
  final _receiverPhone = TextEditingController();
  final _receiverAddress = TextEditingController();

  final Map<String, TextEditingController> _c = {};

  final bool _isLoading = false;

  bool get _isExpert => widget.categoryKey == 'EXPERT';

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '필수 입력 항목입니다.';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    for (final f in _config(widget.categoryKey).fields) {
      _c[f.key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _senderName.dispose();
    _senderPhone.dispose();
    _senderAddress.dispose();
    _receiverName.dispose();
    _receiverPhone.dispose();
    _receiverAddress.dispose();

    for (final ctrl in _c.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _onGenerate() async {
    debugPrint('=== _onGenerate called ===');

    final isValid = _formKey.currentState!.validate();
    debugPrint('=== form valid === $isValid');

    if (!isValid) return;

    final cfg = _config(widget.categoryKey);

    final payload = <String, dynamic>{
      "categoryKey": widget.categoryKey,
      "senderName": _senderName.text.trim(),
      "senderPhone": _senderPhone.text.trim(),
      "senderAddress": _senderAddress.text.trim(),
      "receiverName": _receiverName.text.trim(),
      "receiverPhone": _receiverPhone.text.trim(),
      "receiverAddress": _receiverAddress.text.trim(),
      "categoryData": {
        for (final f in cfg.fields) f.key: (_c[f.key]?.text.trim() ?? ""),
      },
    };

    debugPrint('=== payload === $payload');

    if (_isExpert) {
      debugPrint('=== go expert page ===');
      Navigator.pushNamed(
        context,
        '/formal-notice-expert-request',
        arguments: payload,
      );
      return;
    }

    debugPrint('=== go generating page ===');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormalNoticeGeneratingScreen(requestPayload: payload),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _config(widget.categoryKey);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 220),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '내용 증명 작성 - ${cfg.title}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const StepIndicator(currentStep: 2, totalSteps: 5),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cfg.guideBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cfg.guideText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: '발신인 정보',
                  child: Column(
                    children: [
                      _LabeledField(
                        label: '발신인 이름 *',
                        controller: _senderName,
                        hint: '홍길동',
                        validator: _required,
                      ),
                      _LabeledField(
                        label: '연락처 *',
                        controller: _senderPhone,
                        hint: '010-0000-0000',
                        keyboardType: TextInputType.phone,
                        validator: _required,
                      ),
                      _LabeledField(
                        label: '주소 *',
                        controller: _senderAddress,
                        hint: '서울특별시 강남구...',
                        validator: _required,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: '수신인 정보',
                  child: Column(
                    children: [
                      _LabeledField(
                        label: '수신인 이름 *',
                        controller: _receiverName,
                        hint: '김철수',
                        validator: _required,
                      ),
                      _LabeledField(
                        label: '연락처 *',
                        controller: _receiverPhone,
                        hint: '010-0000-0000',
                        keyboardType: TextInputType.phone,
                        validator: _required,
                      ),
                      _LabeledField(
                        label: '주소 *',
                        controller: _receiverAddress,
                        hint: '서울특별시 중구...',
                        validator: _required,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _SectionCard(
                  title: cfg.sectionTitle,
                  child: Column(
                    children: cfg.fields.map((f) {
                      final isDateField =
                          f.key.toLowerCase().contains("date") ||
                          f.key.toLowerCase().contains("deadline") ||
                          f.key.toLowerCase().contains("due");

                      return _LabeledField(
                        label: f.required ? '${f.label} *' : f.label,
                        controller: _c[f.key]!,
                        hint: f.hint,
                        maxLines: f.maxLines,
                        keyboardType: f.keyboardType,
                        validator: f.required ? _required : null,
                        isDate: isDateField,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE9EAEC)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          '이전',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2B2E3A),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 48,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4FD2FF), Color(0xFF3B4BFF)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isLoading ? null : _onGenerate,
                            borderRadius: BorderRadius.circular(10),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _isExpert ? '전문가 의뢰하기' : '내용 증명 생성하기',
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            BottomNavBar(
              currentIndex: 3,
              onCenterTap: () {
                Navigator.pushReplacementNamed(context, '/formal-notice-send');
              },
              onTap: (index) {
                BottomNavBar.navigateToIndex(context, index);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/* ----------------------------- Category Config ----------------------------- */

_FormConfig _config(String key) {
  switch (key) {
    case 'LOAN':
      return _FormConfig(
        title: '대여금',
        guideText: '대여금 관련 내용을 내용을 증명 형식으로 작성해주세요.',
        guideBg: const Color(0xFF00A6B2),
        sectionTitle: '대여금 정보',
        fields: const [
          _FormFieldDef(
            key: 'loanDate',
            label: '대여 일자',
            hint: '예: 2025-01-01',
            required: true,
          ),
          _FormFieldDef(
            key: 'loanAmount',
            label: '대여 금액',
            hint: '예: 5,000,000원',
            required: true,
            keyboardType: TextInputType.number,
          ),
          _FormFieldDef(
            key: 'interest',
            label: '이자/이율',
            hint: '예: 연 5% 또는 무이자',
            required: false,
          ),
          _FormFieldDef(
            key: 'repayDue',
            label: '변제 기한',
            hint: '예: 2025-03-31',
            required: true,
          ),
          _FormFieldDef(
            key: 'requestAmount',
            label: '요구 금액',
            hint: '예: 5,000,000원',
            required: true,
            keyboardType: TextInputType.number,
          ),
          _FormFieldDef(
            key: 'requestDeadline',
            label: '요구 기한',
            hint: '예: 7일 이내',
            required: true,
          ),
          _FormFieldDef(
            key: 'detail',
            label: '상세 내용',
            hint: '상황을 간단히 설명해주세요.',
            required: false,
            maxLines: 4,
          ),
        ],
      );

    case 'LEASE':
      return _FormConfig(
        title: '임대차',
        guideText: '임대차 관련 내용을 내용을 증명 형식으로 작성해주세요.',
        guideBg: const Color(0xFF00A6B2),
        sectionTitle: '임대차 정보',
        fields: const [
          _FormFieldDef(
            key: 'contractDate',
            label: '임대차 계약일',
            hint: '예: 2024-06-01',
            required: true,
          ),
          _FormFieldDef(
            key: 'leaseAddress',
            label: '임대차 주소',
            hint: '예: 서울특별시 강남구...',
            required: true,
            maxLines: 2,
          ),
          _FormFieldDef(
            key: 'deposit',
            label: '보증금',
            hint: '예: 10,000,000원',
            required: true,
            keyboardType: TextInputType.number,
          ),
          _FormFieldDef(
            key: 'endDate',
            label: '계약 종료일',
            hint: '예: 2025-06-01',
            required: false,
          ),
          _FormFieldDef(
            key: 'returnRequest',
            label: '보증금 반환 요구',
            hint: '예: 보증금 전액 반환 요청',
            required: true,
            maxLines: 2,
          ),
          _FormFieldDef(
            key: 'detail',
            label: '상세 내용',
            hint: '문제 상황(미반환 사유 등)을 적어주세요.',
            required: false,
            maxLines: 4,
          ),
        ],
      );

    case 'CONTRACT':
      return _FormConfig(
        title: '계약 관련',
        guideText: '계약 관련 내용을 내용을 증명 형식으로 작성해주세요.',
        guideBg: const Color(0xFF00A6B2),
        sectionTitle: '계약 정보',
        fields: const [
          _FormFieldDef(
            key: 'contractName',
            label: '계약 제목',
            hint: '예: 용역 계약',
            required: true,
          ),
          _FormFieldDef(
            key: 'contractDate',
            label: '계약 체결일',
            hint: '예: 2025-02-01',
            required: true,
          ),
          _FormFieldDef(
            key: 'contractContent',
            label: '계약 내용',
            hint: '계약 내용을 간단히 설명해주세요.',
            required: true,
            maxLines: 4,
          ),
          _FormFieldDef(
            key: 'counterBreach',
            label: '상대방 불이행',
            hint: '상대방의 위반/불이행 내용을 적어주세요.',
            required: true,
            maxLines: 4,
          ),
          _FormFieldDef(
            key: 'myRequest',
            label: '계약 이행 요구',
            hint: '상대방에게 요구하는 내용을 적어주세요.',
            required: true,
            maxLines: 3,
          ),
          _FormFieldDef(
            key: 'deadline',
            label: '이행 요구 기한',
            hint: '예: 7일 이내',
            required: true,
          ),
        ],
      );

    case 'MEMBERSHIP_REFUND':
      return _FormConfig(
        title: '회원권 환불',
        guideText: '회원권 관련 내용을 내용을 증명 형식으로 작성해주세요.',
        guideBg: const Color(0xFF00A6B2),
        sectionTitle: '회원권 정보',
        fields: const [
          _FormFieldDef(
            key: 'serviceName',
            label: '이용 서비스',
            hint: '예: 헬스장/골프레슨/학원',
            required: true,
          ),
          _FormFieldDef(
            key: 'payDate',
            label: '결제 일자',
            hint: '예: 2025-01-10',
            required: true,
          ),
          _FormFieldDef(
            key: 'payAmount',
            label: '결제 금액',
            hint: '예: 1,200,000원',
            required: true,
            keyboardType: TextInputType.number,
          ),
          _FormFieldDef(
            key: 'usedPeriod',
            label: '이용 기간',
            hint: '예: 2개월 이용',
            required: false,
          ),
          _FormFieldDef(
            key: 'refundReason',
            label: '환불 요청 사유',
            hint: '환불을 요청하는 이유를 설명해주세요.',
            required: true,
            maxLines: 4,
          ),
          _FormFieldDef(
            key: 'refundRequest',
            label: '환불 요청 금액/방식',
            hint: '예: 잔여기간 환불 요청',
            required: true,
            maxLines: 2,
          ),
        ],
      );

    case 'DIRECT':
      return _FormConfig(
        title: '직접 작성',
        guideText: '내용 증명을 직접 작성해주세요.',
        guideBg: const Color(0xFF00A6B2),
        sectionTitle: '분쟁 정보',
        fields: const [
          _FormFieldDef(
            key: 'summary',
            label: '사건 개요',
            hint: '어떤 일이 있었는지 간단히 적어주세요.',
            required: true,
            maxLines: 5,
          ),
          _FormFieldDef(
            key: 'amount',
            label: '금액',
            hint: '예: 5,000,000원',
            required: false,
            keyboardType: TextInputType.number,
          ),
          _FormFieldDef(
            key: 'request',
            label: '요구 사항',
            hint: '상대방에게 요구하는 사항',
            required: true,
            maxLines: 3,
          ),
          _FormFieldDef(
            key: 'deadline',
            label: '요구 기한',
            hint: '예: 7일 이내',
            required: false,
          ),
        ],
      );

    case 'EXPERT':
      return _FormConfig(
        title: '전문가 의뢰',
        guideText: '내용 증명을 전문가에게 의뢰하시려면 정보를 입력해주세요.',
        guideBg: const Color(0xFF00A6B2),
        sectionTitle: '전문가 의뢰 정보',
        fields: const [
          _FormFieldDef(
            key: 'caseSummary',
            label: '사건 설명',
            hint: '전문가에게 전달할 사건 설명',
            required: true,
            maxLines: 6,
          ),
          _FormFieldDef(
            key: 'preferredContact',
            label: '연락 가능한 연락처',
            hint: '예: 010-0000-0000',
            required: true,
            keyboardType: TextInputType.phone,
          ),
          _FormFieldDef(
            key: 'extra',
            label: '추가 요청 사항',
            hint: '추가로 전달할 내용이 있다면 적어주세요.',
            required: false,
            maxLines: 4,
          ),
        ],
      );

    default:
      return _FormConfig(
        title: '알 수 없음',
        guideText: '카테고리를 다시 선택해주세요.',
        guideBg: const Color(0xFF8E9AA0),
        sectionTitle: '정보',
        fields: const [],
      );
  }
}

class _FormConfig {
  final String title;
  final String guideText;
  final Color guideBg;
  final String sectionTitle;
  final List<_FormFieldDef> fields;

  const _FormConfig({
    required this.title,
    required this.guideText,
    required this.guideBg,
    required this.sectionTitle,
    required this.fields,
  });
}

class _FormFieldDef {
  final String key;
  final String label;
  final String hint;
  final bool required;
  final int maxLines;
  final TextInputType keyboardType;

  const _FormFieldDef({
    required this.key,
    required this.label,
    required this.hint,
    required this.required,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9EAEC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2B2E3A),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType keyboardType;
  final bool isDate;

  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    this.validator,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.isDate = false,
  });

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B2E3A),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            maxLines: maxLines,
            keyboardType: keyboardType,
            readOnly: isDate,
            onTap: isDate ? () => _pickDate(context) : null,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: isDate
                  ? const Icon(Icons.calendar_today, size: 18)
                  : null,
              hintStyle: const TextStyle(
                color: Color(0xFFB9BDC6),
                fontSize: 12.5,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE9EAEC)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE9EAEC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF00ADB5),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
