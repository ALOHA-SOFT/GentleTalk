import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/config.dart';
import '../../user/widgets/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpponentMessageViewScreen extends StatefulWidget {
  const OpponentMessageViewScreen({super.key});

  @override
  State<OpponentMessageViewScreen> createState() =>
      _OpponentMessageViewScreenState();
}

class _OpponentMessageViewScreenState extends State<OpponentMessageViewScreen> {
  String? _issueNo;
  String? _requesterName;        // 요청자 username (issue.user_no의 사용자)
  String? _negotiationMessage;   // 협상 메시지 본문

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    _issueNo = args?['issueNo']?.toString();

    if (_issueNo == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = '이슈 번호가 없습니다.';
      });
      return;
    }

    _fetchIssueDetail();
  }

  /// 이슈 상세 조회해서 요청자 이름 + 협상 메시지 로드
  Future<void> _fetchIssueDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/issues/$_issueNo');
      debugPrint('📡 [OpponentMessageView] GET $uri');

      final res = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode != 200) {
        throw Exception('이슈 정보를 불러오지 못했습니다. (${res.statusCode})');
      }

      final data =
          json.decode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;

      setState(() {
        // 🔥 백엔드 DTO에서 내려오는 필드를 사용 (예: username / userName / writer)
        _requesterName =
            (data['username'] ?? '요청자')
                .toString();

        _negotiationMessage =
            (data['negotiationMessage'] ?? '협상 메시지가 없습니다.').toString();

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ [OpponentMessageView] 이슈 조회 오류: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = '협상 메시지를 불러오지 못했습니다.\n$e';
      });
    }
  }

  /// 즉시 승인 → status = '협상완료' 로 변경 후 홈으로 이동
  Future<void> _approveImmediately() async {
    if (_issueNo == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // ✅ status를 @RequestParam 으로 전송
      final uri = Uri.parse(
        '${AppConfig.baseUrl}/api/v1/issues/$_issueNo/status',
      ).replace(
        queryParameters: {
          'status': '협상완료', // @RequestParam String status
        },
      );

      debugPrint('📡 [OpponentMessageView] PUT $uri');

      final res = await http.put(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        debugPrint('✅ 협상 즉시 승인 성공');

        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home', // 실제 홈 라우트 이름
          (route) => false,
        );
      } else {
        debugPrint('❌ 협상 즉시 승인 실패: ${res.statusCode} ${res.body}');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('승인 처리에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      debugPrint('❌ 협상 즉시 승인 예외: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('승인 중 오류가 발생했습니다: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final requesterName = _requesterName ?? '요청자';
    final messageText = _negotiationMessage ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 내용
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 30),
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

                            if (_errorMessage != null) ...[
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // 요청자 정보
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDEDED),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                  // 🔥 이슈 생성자의 username 표시
                                  Text(
                                    requesterName,
                                    style: const TextStyle(
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
                                  child: Text(
                                    messageText.isNotEmpty
                                        ? messageText
                                        : '협상 메시지가 없습니다.',
                                    style: const TextStyle(
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pushNamed(
                                context,
                                '/opponent-opinion-submit',
                                arguments: {
                                  'issueNo': _issueNo,
                                },
                              );
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
                      onPressed: (_isLoading || _isSubmitting)
                          ? null
                          : _approveImmediately,
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _isSubmitting ? '처리 중...' : '즉시 승인하기',
                        style: const TextStyle(
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
