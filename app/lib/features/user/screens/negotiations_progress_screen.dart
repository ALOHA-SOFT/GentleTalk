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

  final List<String> progressStatuses = [
    '대기',
    '분석중',
    '분석완료',
    '상대방대기',
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
            return progressStatuses.contains(status);
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

  int _statusStep(String status) {
    switch (status.trim()) {
      case '대기':
        return 1;
      case '분석중':
        return 2;
      case '분석완료':
        return 3;
      case '상대방대기':
        return 4;
      case '중재안제시':
        return 5;
      case '협상완료':
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
                        separatorBuilder: (_, __) => const SizedBox(height: 25),
                        itemBuilder: (context, index) {
                          final item = _issues[index];

                          final status = (item['status'] ?? '').toString().trim();
                          final fullTitle = (item['conflictSituation'] ?? '').toString();
                          final title = _shortenTitle(fullTitle, 20);
                          final rawDate =
                              (item['createdAt'] ?? '').toString();
                          final date = rawDate.length >= 10
                              ? rawDate.substring(0, 10)
                              : rawDate;

                          final step = _statusStep(status);

                          final issueNo = item['no']; // ★ 여기서 issueNo 가져옴

                          return _buildNegotiationCard(
                            context,
                            status,
                            title,
                            date,
                            '$step/6',
                            _statusColor(status),
                            issueNo, // ★ 전달
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

  Color _statusColor(String? rawStatus) {
    final status = (rawStatus ?? '').trim();
    switch (status) {
      case '분석중':
        return const Color(0xFF001497);
      case '대기':
        return const Color(0xFF409CFF);
      case '분석완료':
        return const Color(0xFF6EBD82);
      case '중재안제시':
        return const Color(0xFFB452FF);
      case '상대방대기':
        return const Color(0xFFFFB340);
      default:
        return Colors.grey;
    }
  }

  String _shortenTitle(String text, int maxLen) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '제목 없음';        // 갈등 상황이 비었을 때 기본 문구
    if (trimmed.length <= maxLen) return trimmed;
    return trimmed.substring(0, maxLen) + '…';      // 20자 + "…" 뒤에 붙이기
  }

  Widget _buildNegotiationCard(
    BuildContext context,
    String status,
    String title,
    String date,
    String progress,
    Color progressColor,
    dynamic issueNo, // ★ int든 String이든 OK
  ) {
    double progressPercent = 0.0;
    if (progress.contains('/')) {
      final parts = progress.split('/');
      progressPercent = int.parse(parts[0]) / int.parse(parts[1]);
    }

    return GestureDetector(
      onTap: () {
        print("📌 [Tap] issueNo = $issueNo (${issueNo.runtimeType})");

        Navigator.pushNamed(
          context,
          '/negotiation-detail',
          arguments: {
            'status': status,
            'issueNo': issueNo, // ★ 상세 화면으로 전달
          },
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
                Icon(Icons.more_vert, size: 22, color: AppColors.textPrimary),
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
