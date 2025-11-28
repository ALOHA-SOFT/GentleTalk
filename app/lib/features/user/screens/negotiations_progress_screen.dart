import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/config.dart';
import '../widgets/bottom_nav_bar.dart';

import 'package:shared_preferences/shared_preferences.dart';

class NegotiationsProgressScreen extends StatefulWidget {
  const NegotiationsProgressScreen({super.key});

  @override
  State<NegotiationsProgressScreen> createState() =>
      _NegotiationsProgressScreenState();
}

class _NegotiationsProgressScreenState
    extends State<NegotiationsProgressScreen> {
  List<dynamic> _issues = [];
  bool _isLoading = true;

  /// 진행 중으로 볼 상태 목록
  final List<String> progressStatuses = [
    '대기',
    '분석중',
    '분석완료',
    '분석실패',
    '상대방대기',
    '상대방응답',
    '중재안제시',
  ];

  @override
  void initState() {
    super.initState();
    _fetchIssues();
  }

  Future<void> _fetchIssues() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userNo = prefs.getInt('userNo');

      if (userNo == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/v1/issues/user/$userNo'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          _issues = data.where((item) {
            final status = (item["status"] ?? '').toString().trim();
            if (!progressStatuses.contains(status)) return false;

            final ownerRaw = item['userNo'];
            final opponentRaw = item['opponentUserNo'];

            int? owner = ownerRaw is int
                ? ownerRaw
                : int.tryParse(ownerRaw?.toString() ?? '');
            int? opponent = opponentRaw is int
                ? opponentRaw
                : int.tryParse(opponentRaw?.toString() ?? '');

            // ✅ 1) 내가 작성자인 경우: 모든 진행 상태 다 보여줌
            if (owner != null && owner == userNo) {
              return true;
            }

            // ✅ 2) 내가 상대방인 경우: "상대방대기" 이후 단계만 보여줌
            if (opponent != null && opponent == userNo) {
              final step = _statusStep(status); // 1~6 단계
              return step >= 4; // 4: 상대방대기, 5: 상대방응답, 6: 중재안제시
            }

            // ✅ 3) 나와 상관없는 이슈는 안 보이게
            return false;
          }).toList();

          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// 상태별 진행 스텝 (총 6단계)
  int _statusStep(String status) {
    switch (status.trim()) {
      case '대기':
        return 1;
      case '분석중':
        return 2;
      case '분석완료':
      case '분석실패':
        return 3;
      case '상대방대기':
        return 4;
      case '상대방응답':
        return 5;
      case '중재안제시':
        return 6;
      default:
        return 1;
    }
  }

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
          '진행중인 협상',
          style: AppTextStyles.heading.copyWith(fontSize: 21),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _issues.isEmpty
              ? const Center(child: Text("진행중인 협상이 없습니다."))
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 345),
                      child: ListView.separated(
                        itemCount: _issues.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 25),
                        itemBuilder: (context, index) {
                          final item = _issues[index];

                          final status =
                              (item['status'] ?? '').toString().trim();
                          final fullTitle =
                              (item['conflictSituation'] ?? '').toString();
                          final title = _shortenTitle(fullTitle, 20);
                          final rawDate =
                              (item['createdAt'] ?? '').toString();
                          final date = rawDate.length >= 10
                              ? rawDate.substring(0, 10)
                              : rawDate;

                          final step = _statusStep(status);
                          final issueNo = item['no'];

                          final userNo = item['userNo']; // 작성자
                          final opponentUserNo =
                              item['opponentUserNo']; // 상대방

                          return _buildNegotiationCard(
                            context,
                            status,
                            title,
                            date,
                            '$step/6',
                            _statusColor(status),
                            issueNo,
                            userNo,
                            opponentUserNo,
                          );
                        },
                      ),
                    ),
                  ),
                ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) => BottomNavBar.navigateToIndex(context, index),
      ),
    );
  }

  /// 상태 컬러 (아이콘/프로그레스바/뱃지)
  Color _statusColor(String? rawStatus) {
    final status = (rawStatus ?? '').trim();
    switch (status) {
      case '분석중':
        return const Color(0xFF001497); // 딥블루
      case '대기':
        return const Color(0xFF409CFF); // 라이트블루
      case '분석완료':
        return const Color(0xFF6EBD82); // 그린
      case '분석실패':
        return const Color.fromARGB(255, 247, 51, 1); // 레드
      case '중재안제시':
        return const Color(0xFFB452FF); // 퍼플
      case '상대방대기':
        return const Color(0xFFFFB340); // 옐로우/오렌지
      case '상대방응답':
        return const Color(0xFFD96E40); // 진한 오렌지
      default:
        return Colors.grey;
    }
  }

  String _shortenTitle(String text, int maxLen) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '제목 없음';
    if (trimmed.length <= maxLen) return trimmed;
    return '${trimmed.substring(0, maxLen)}…';
  }

  Widget _buildNegotiationCard(
    BuildContext context,
    String status,
    String title,
    String date,
    String progress,
    Color progressColor,
    dynamic issueNo,
    dynamic userNo,
    dynamic opponentUserNo,
  ) {
    double progressPercent = 0.0;
    if (progress.contains('/')) {
      final parts = progress.split('/');
      progressPercent = int.parse(parts[0]) / int.parse(parts[1]);
    }

    return GestureDetector(
      onTap: () async {
        debugPrint("📌 [Tap] issueNo = $issueNo (${issueNo.runtimeType})");

        final prefs = await SharedPreferences.getInstance();
        final currentUserNo = prefs.getInt('userNo');

        if (currentUserNo == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인 정보가 없습니다. 다시 로그인 해주세요.')),
          );
          return;
        }

        // JSON 값이 int / String 섞일 수 있으니 안전하게 변환
        int? owner;
        int? opponent;

        if (userNo != null) {
          owner = userNo is int ? userNo : int.tryParse(userNo.toString());
        }
        if (opponentUserNo != null) {
          opponent = opponentUserNo is int
              ? opponentUserNo
              : int.tryParse(opponentUserNo.toString());
        }

        final trimmedStatus = status.trim();

        // 1) 내가 작성자(user)인 경우 → 기존 상세 플로우
        if (owner != null && currentUserNo == owner) {
          Navigator.pushNamed(
            context,
            '/negotiation-detail',
            arguments: {
              'status': status,
              'issueNo': issueNo,
              'isOpponentView': false, // 작성자 입장
            },
          );
          return;
        }

        // 2) 내가 상대방(opponent)인 경우
        if (opponent != null && currentUserNo == opponent) {
          if (trimmedStatus == '상대방대기') {
            // 상대방이 최초로 요청 메시지를 확인하는 화면
            Navigator.pushNamed(
              context,
              '/opponent-message-view',
              arguments: {
                'status': status,
                'issueNo': issueNo,
              },
            );
          } else if (trimmedStatus == '중재안제시') {
            // 최종 중재안이 제시된 상태에서 상대방이 보는 화면
            Navigator.pushNamed(
              context,
              '/opponent-final-proposal',
              arguments: {
                'status': status,
                'issueNo': issueNo,
              },
            );
          } else {
            // 그 외 상태는 읽기/상세 공용 화면 (상대방 입장 플래그 같이 전달)
            Navigator.pushNamed(
              context,
              '/negotiation-detail',
              arguments: {
                'status': status,
                'issueNo': issueNo,
                'isOpponentView': true, // 상대방 입장
              },
            );
          }
          return;
        }

        // 3) 둘 다 아니면 (예외적인 경우)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이 협상에 대한 권한이 없습니다.')),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14.5),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F6),
          borderRadius: BorderRadius.circular(7.3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 9.08,
              offset: const Offset(0, 4.54),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(5.45),
                  ),
                  child: const Icon(
                    Icons.folder_outlined,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10.9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.toUpperCase(),
                        style: AppTextStyles.body.copyWith(
                          fontSize: 9,
                          color: const Color(0xFF797979),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.45,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 11.8,
                          color: const Color(0xFF1B1212),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 9,
                          color: const Color(0xFF797979),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert,
                    size: 22, color: AppColors.textPrimary),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9E9E9),
                          borderRadius: BorderRadius.circular(90),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progressPercent,
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: progressColor,
                            borderRadius: BorderRadius.circular(90),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10.9),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7.3,
                    vertical: 9.08,
                  ),
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(90),
                  ),
                  child: Text(
                    progress,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.45,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
