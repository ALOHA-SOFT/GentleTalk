import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/config.dart';
import '../widgets/bottom_nav_bar.dart';

import 'package:shared_preferences/shared_preferences.dart';

class NegotiationsHistoryScreen extends StatefulWidget {
  const NegotiationsHistoryScreen({super.key});

  @override
  State<NegotiationsHistoryScreen> createState() => _NegotiationsHistoryScreenState();
}

class _NegotiationsHistoryScreenState extends State<NegotiationsHistoryScreen> {
  List<dynamic> _issues = [];
  bool _isLoading = true;

  final List<String> historyStatuses = [
    '협상완료',
    '협상결렬',
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
          '협상 내역',
          style: AppTextStyles.heading.copyWith(fontSize: 21),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _issues.isEmpty
              ? const Center(child: Text("지난 협상 기록이 없습니다."))
              : SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 345),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var item in _issues)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: _buildHistoryCard(
                                    _safeDate(item['created_at']),
                                    (item['conflict_situation'] ?? '').toString(),
                                    (item['status'] ?? '').toString(),
                                  ),
                                ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          BottomNavBar.navigateToIndex(context, index);
        },
      ),
    );
  }

    Widget _buildHistoryCard(String date, String title, String status) {
    final isCompleted = status == '협상완료';
    final isFailed = status == '협상결렬';

    // 상태별 대표 색
    final Color statusColor = isCompleted
        ? const Color(0xFF1DCBD3)
        : isFailed
            ? const Color(0xFFFF6B6B)
            : Colors.grey;

    final String statusLabel =
        isCompleted || isFailed ? status : '진행 상태';

    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/negotiation-result',
            arguments: {
              'date': date,
              'title': title,
              'status': status,
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽 아이콘
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
                    // 날짜
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
                    // 협상 내용 요약입니다.
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

              // 오른쪽 상단 점3개 + 상태 배지
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Icon(
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
      ),
    );
  }
  }