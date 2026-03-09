import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/config.dart';
import '../../user/widgets/bottom_nav_bar.dart';

import 'package:shared_preferences/shared_preferences.dart';

class NegotiationContentScreen extends StatefulWidget {
  const NegotiationContentScreen({super.key});

  @override
  State<NegotiationContentScreen> createState() =>
      _NegotiationContentScreenState();
}

class _NegotiationContentScreenState extends State<NegotiationContentScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          },
        ),
        title: Text(
          '협상 내역',
          style: AppTextStyles.heading.copyWith(fontSize: 21),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00949F),
          unselectedLabelColor: const Color(0xFFB9BDC6),
          indicatorColor: const Color(0xFF00949F),
          indicatorWeight: 3,
          labelStyle: AppTextStyles.body.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
          tabs: const [
            Tab(text: '진행중인 협상'),
            Tab(text: '협상내역'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _NegotiationsProgressTab(), // ✅ 진행중
          _NegotiationsHistoryTab(), // ✅ 완료/결렬
        ],
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

/* -------------------------------------------------------------------------- */
/*                            진행중인 협상 TAB                                */
/* -------------------------------------------------------------------------- */

class _NegotiationsProgressTab extends StatefulWidget {
  const _NegotiationsProgressTab();

  @override
  State<_NegotiationsProgressTab> createState() =>
      _NegotiationsProgressTabState();
}

class _NegotiationsProgressTabState extends State<_NegotiationsProgressTab> {
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
            if (owner != null && owner == userNo) return true;

            // ✅ 2) 내가 상대방인 경우: "상대방대기" 이후 단계만 보여줌
            if (opponent != null && opponent == userNo) {
              final step = _statusStep(status);
              return step >= 4;
            }

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

  Color _statusColor(String? rawStatus) {
    final status = (rawStatus ?? '').trim();
    switch (status) {
      case '분석중':
        return const Color(0xFF001497);
      case '대기':
        return const Color(0xFF409CFF);
      case '분석완료':
        return const Color(0xFF6EBD82);
      case '분석실패':
        return const Color.fromARGB(255, 247, 51, 1);
      case '중재안제시':
        return const Color(0xFFB452FF);
      case '상대방대기':
        return const Color(0xFFFFB340);
      case '상대방응답':
        return const Color(0xFFD96E40);
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_issues.isEmpty) return const Center(child: Text("진행중인 협상이 없습니다."));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 345),
          child: ListView.separated(
            itemCount: _issues.length,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              final item = _issues[index];

              final status = (item['status'] ?? '').toString().trim();
              final fullTitle = (item['conflictSituation'] ?? '').toString();
              final title = _shortenTitle(fullTitle, 20);
              final rawDate = (item['createdAt'] ?? '').toString();
              final date = rawDate.length >= 10
                  ? rawDate.substring(0, 10)
                  : rawDate;

              final step = _statusStep(status);
              final issueNo = item['no'] ?? item['issueNo'] ?? item['id'];
              final userNo = item['userNo'];
              final opponentUserNo = item['opponentUserNo'];

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
    );
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
        final prefs = await SharedPreferences.getInstance();
        final currentUserNo = prefs.getInt('userNo');

        if (currentUserNo == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인 정보가 없습니다. 다시 로그인 해주세요.')),
          );
          return;
        }

        int? owner = userNo is int
            ? userNo
            : int.tryParse(userNo?.toString() ?? '');
        int? opponent = opponentUserNo is int
            ? opponentUserNo
            : int.tryParse(opponentUserNo?.toString() ?? '');

        final trimmedStatus = status.trim();

        // 작성자
        if (owner != null && currentUserNo == owner) {
          Navigator.pushNamed(
            context,
            '/negotiation-detail',
            arguments: {
              'status': status,
              'issueNo': issueNo,
              'isOpponentView': false,
            },
          );
          return;
        }

        // 상대방
        if (opponent != null && currentUserNo == opponent) {
          if (trimmedStatus == '상대방대기') {
            Navigator.pushNamed(
              context,
              '/opponent-message-view',
              arguments: {'status': status, 'issueNo': issueNo},
            );
          } else if (trimmedStatus == '중재안제시') {
            Navigator.pushNamed(
              context,
              '/opponent-final-proposal',
              arguments: {'status': status, 'issueNo': issueNo},
            );
          } else {
            Navigator.pushNamed(
              context,
              '/negotiation-detail',
              arguments: {
                'status': status,
                'issueNo': issueNo,
                'isOpponentView': true,
              },
            );
          }
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('이 협상에 대한 권한이 없습니다.')));
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
                const Icon(
                  Icons.more_vert,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
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

/* -------------------------------------------------------------------------- */
/*                               협상내역 TAB                                  */
/* -------------------------------------------------------------------------- */

class _NegotiationsHistoryTab extends StatefulWidget {
  const _NegotiationsHistoryTab();

  @override
  State<_NegotiationsHistoryTab> createState() =>
      _NegotiationsHistoryTabState();
}

class _NegotiationsHistoryTabState extends State<_NegotiationsHistoryTab> {
  List<dynamic> _issues = [];
  bool _isLoading = true;

  int? _currentUserNo;

  final List<String> historyStatuses = ['협상완료', '협상결렬'];

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

      _currentUserNo = userNo;

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/v1/issues/user/$userNo'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          _issues = data.where((item) {
            final status = (item["status"] ?? '').toString().trim();
            return historyStatuses.contains(status);
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

  String _safeDate(dynamic value) {
    final date = (value ?? '').toString();
    return date.length >= 10 ? date.substring(0, 10) : date;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_issues.isEmpty) return const Center(child: Text("지난 협상 기록이 없습니다."));

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 345),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var item in _issues)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: _buildHistoryCard(
                      item['issueNo'] ?? item['no'] ?? item['id'],
                      _safeDate(item['createdAt']),
                      (item['conflictSituation'] ?? '').toString(),
                      (item['status'] ?? '').toString(),
                      item['userNo'],
                      item['opponentUserNo'],
                    ),
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
    dynamic issueNo,
    String date,
    String title,
    String status,
    dynamic ownerUserNo,
    dynamic opponentUserNo,
  ) {
    final trimmedStatus = status.trim();
    final isCompleted = trimmedStatus == '협상완료';
    final isFailed = trimmedStatus == '협상결렬';

    final Color statusColor = isCompleted
        ? const Color(0xFF1DCBD3)
        : isFailed
        ? const Color(0xFFFF6B6B)
        : Colors.grey;

    final String statusLabel = (isCompleted || isFailed) ? status : '진행 상태';

    return GestureDetector(
      onTap: () {
        final currentUserNo = _currentUserNo;

        int? owner = ownerUserNo is int
            ? ownerUserNo
            : int.tryParse(ownerUserNo?.toString() ?? '');
        int? opponent = opponentUserNo is int
            ? opponentUserNo
            : int.tryParse(opponentUserNo?.toString() ?? '');

        if (currentUserNo != null && owner != null && currentUserNo == owner) {
          String routeName;
          if (trimmedStatus == '협상완료') {
            routeName = '/opponent-negotiation-success';
          } else if (trimmedStatus == '협상결렬') {
            routeName = '/opponent-failed';
          } else {
            routeName = '/negotiation-result';
          }

          Navigator.pushNamed(
            context,
            routeName,
            arguments: {
              'issueNo': issueNo,
              'date': date,
              'title': title,
              'status': status,
            },
          );
          return;
        }

        if (currentUserNo != null &&
            opponent != null &&
            currentUserNo == opponent) {
          String routeName;
          if (trimmedStatus == '협상완료') {
            routeName = '/opponent-negotiation-success';
          } else if (trimmedStatus == '협상결렬') {
            routeName = '/opponent-negotiation-failed';
          } else {
            routeName = '/opponent-negotiation-success';
          }

          Navigator.pushNamed(
            context,
            routeName,
            arguments: {
              'issueNo': issueNo,
              'date': date,
              'title': title,
              'status': status,
            },
          );
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('이 협상에 대한 권한이 없습니다.')));
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: statusColor,
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
                    date,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 9,
                      color: const Color(0xFF797979),
                      fontWeight: FontWeight.w700,
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: Color(0xFF8A6E00),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '협상 내용 요약입니다.',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 9,
                          color: const Color(0xFF8A6E00),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(
                  Icons.more_vert,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Text(
                    statusLabel,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.w700,
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
