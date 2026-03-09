import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/config.dart';
import '../../user/widgets/bottom_nav_bar.dart';

class FormalNoticeContentScreen extends StatefulWidget {
  const FormalNoticeContentScreen({super.key});

  @override
  State<FormalNoticeContentScreen> createState() =>
      _FormalNoticeContentScreenState();
}

class _FormalNoticeContentScreenState extends State<FormalNoticeContentScreen>
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

  Future<void> _goCreate() async {
    final result = await Navigator.pushNamed(context, '/formal-notice-send');
    if (result == true && mounted) {
      setState(() {});
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
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          },
        ),
        title: Text(
          '내용증명 내역',
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
            Tab(text: '진행중인 내용증명'),
            Tab(text: '발송 내역'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_FormalNoticeProgressTab(), _FormalNoticeHistoryTab()],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onCenterTap: _goCreate,
        onTap: (index) {
          BottomNavBar.navigateToIndex(context, index);
        },
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                          진행중인 내용증명 TAB                              */
/* -------------------------------------------------------------------------- */

class _FormalNoticeProgressTab extends StatefulWidget {
  const _FormalNoticeProgressTab();

  @override
  State<_FormalNoticeProgressTab> createState() =>
      _FormalNoticeProgressTabState();
}

class _FormalNoticeProgressTabState extends State<_FormalNoticeProgressTab> {
  List<dynamic> _items = [];
  bool _isLoading = true;

  final List<String> progressStatuses = ['대기', '분석중', '분석완료'];

  @override
  void initState() {
    super.initState();
    _fetchFormalNotices();
  }

  Future<void> _fetchFormalNotices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userNo = prefs.getInt('userNo');
      final token = prefs.getString('jwt');

      debugPrint('=== FormalNoticeContent userNo === $userNo');
      debugPrint('=== FormalNoticeContent jwt === $token');

      if (userNo == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/v1/formal-notice/user/$userNo'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data =
            json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;

        setState(() {
          _items = data.where((item) {
            final status = (item['status'] ?? '').toString().trim();
            return progressStatuses.contains(status);
          }).toList();
          _isLoading = false;
        });
      } else {
        debugPrint(
          'FormalNoticeContent fetch failed: ${response.statusCode} ${response.body}',
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('FormalNoticeContent fetch error: $e');
      setState(() => _isLoading = false);
    }
  }

  int _statusStep(String status) {
    switch (status.trim()) {
      case '대기':
        return 1;
      case '분석중':
        return 2;
      case '분석완료':
        return 3;
      default:
        return 1;
    }
  }

  Color _statusColor(String? rawStatus) {
    final status = (rawStatus ?? '').trim();
    switch (status) {
      case '대기':
        return const Color(0xFF409CFF);
      case '분석중':
        return const Color(0xFF001497);
      case '분석완료':
        return const Color(0xFF6EBD82);
      default:
        return Colors.grey;
    }
  }

  String _shortenTitle(String text, int maxLen) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '내용증명';
    if (trimmed.length <= maxLen) return trimmed;
    return '${trimmed.substring(0, maxLen)}…';
  }

  String _buildTitle(dynamic item) {
    final category = (item['categoryKey'] ?? '').toString();
    final receiver = (item['receiverName'] ?? '').toString().trim();

    String categoryName;
    switch (category) {
      case 'LOAN':
        categoryName = '대여금';
        break;
      case 'LEASE':
        categoryName = '임대차';
        break;
      case 'CONTRACT':
        categoryName = '계약 관련';
        break;
      case 'MEMBERSHIP_REFUND':
        categoryName = '회원권 환불';
        break;
      case 'DIRECT':
        categoryName = '직접 작성';
        break;
      case 'EXPERT':
        categoryName = '전문가 의뢰';
        break;
      default:
        categoryName = '내용증명';
    }

    if (receiver.isNotEmpty) {
      return '$categoryName / $receiver';
    }
    return categoryName;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) return const Center(child: Text('진행중인 내용증명이 없습니다.'));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 345),
          child: ListView.separated(
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              final item = _items[index];

              final status = (item['status'] ?? '').toString().trim();
              final title = _shortenTitle(_buildTitle(item), 20);
              final rawDate = (item['createdAt'] ?? '').toString();
              final date = rawDate.length >= 10
                  ? rawDate.substring(0, 10)
                  : rawDate;

              final step = _statusStep(status);
              final no = item['no'] ?? item['formalNoticeNo'] ?? item['id'];

              return _buildCard(
                context,
                no: no,
                status: status,
                title: title,
                date: date,
                progress: '$step/3',
                progressColor: _statusColor(status),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required dynamic no,
    required String status,
    required String title,
    required String date,
    required String progress,
    required Color progressColor,
  }) {
    double progressPercent = 0.0;
    if (progress.contains('/')) {
      final parts = progress.split('/');
      progressPercent = int.parse(parts[0]) / int.parse(parts[1]);
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/formal-notice-detail',
          arguments: {'no': no, 'status': status},
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
                    Icons.description_outlined,
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
/*                               발송 내역 TAB                                  */
/* -------------------------------------------------------------------------- */

class _FormalNoticeHistoryTab extends StatefulWidget {
  const _FormalNoticeHistoryTab();

  @override
  State<_FormalNoticeHistoryTab> createState() =>
      _FormalNoticeHistoryTabState();
}

class _FormalNoticeHistoryTabState extends State<_FormalNoticeHistoryTab> {
  List<dynamic> _items = [];
  bool _isLoading = true;

  final List<String> historyStatuses = ['발송완료', '완료'];

  @override
  void initState() {
    super.initState();
    _fetchFormalNotices();
  }

  Future<void> _fetchFormalNotices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userNo = prefs.getInt('userNo');
      final token = prefs.getString('jwt');

      if (userNo == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/v1/formal-notice/user/$userNo'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data =
            json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;

        setState(() {
          _items = data.where((item) {
            final status = (item['status'] ?? '').toString().trim();
            return historyStatuses.contains(status);
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String _safeDate(dynamic value) {
    final date = (value ?? '').toString();
    return date.length >= 10 ? date.substring(0, 10) : date;
  }

  String _buildTitle(dynamic item) {
    final category = (item['categoryKey'] ?? '').toString();
    final receiver = (item['receiverName'] ?? '').toString().trim();

    String categoryName;
    switch (category) {
      case 'LOAN':
        categoryName = '대여금';
        break;
      case 'LEASE':
        categoryName = '임대차';
        break;
      case 'CONTRACT':
        categoryName = '계약 관련';
        break;
      case 'MEMBERSHIP_REFUND':
        categoryName = '회원권 환불';
        break;
      case 'DIRECT':
        categoryName = '직접 작성';
        break;
      case 'EXPERT':
        categoryName = '전문가 의뢰';
        break;
      default:
        categoryName = '내용증명';
    }

    if (receiver.isNotEmpty) {
      return '$categoryName / $receiver';
    }
    return categoryName;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) return const Center(child: Text('발송 내역이 없습니다.'));

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
                for (var item in _items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: _buildHistoryCard(
                      no: item['no'] ?? item['formalNoticeNo'] ?? item['id'],
                      date: _safeDate(item['createdAt']),
                      title: _buildTitle(item),
                      status: (item['status'] ?? '').toString(),
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

  Widget _buildHistoryCard({
    required dynamic no,
    required String date,
    required String title,
    required String status,
  }) {
    final trimmedStatus = status.trim();
    final Color statusColor = trimmedStatus == '발송완료' || trimmedStatus == '완료'
        ? const Color(0xFF1DCBD3)
        : Colors.grey;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/formal-notice-detail',
          arguments: {'no': no, 'status': status},
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
                Icons.description_outlined,
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
                        '발송된 내용증명입니다.',
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
                    status,
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
