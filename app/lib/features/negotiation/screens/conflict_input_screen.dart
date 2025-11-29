import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/constants/config.dart';

class ConflictInputScreen extends StatefulWidget {
  const ConflictInputScreen({super.key});

  @override
  State<ConflictInputScreen> createState() => _ConflictInputScreenState();
}

class _ConflictInputScreenState extends State<ConflictInputScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  int _questionStep = 0;
  String? _answer1;     
  String? _answer2;    
  int? _issueNo;  

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        text: '현재 겪고 있는 갈등상황에 대해 구체적으로 말씀해 주시겠어요?',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

Future<void> _submitIssue() async {
    final first = _answer1 ?? '';
    final second = _answer2 ?? '';

    if (first.isEmpty && second.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt');

      final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/issues');

      final body = {
        'conflictSituation': first,
        'requirements': second,
      };

      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final res = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (res.statusCode == 201 || res.statusCode == 200) {
        // ✅ 응답에서 issueNo 추출
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final no = data['no']; // 백엔드 Issue 객체의 PK 필드 이름이 'no'라고 가정

        setState(() {
          _issueNo = (no is int) ? no : int.tryParse(no.toString());
          _questionStep = 2; // 분석 버튼 노출
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('갈등 상황이 저장되었습니다.')),
        );
      } else {
        debugPrint("Error body: ${res.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: ${res.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('submitIssue error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('서버와 통신 중 오류가 발생했습니다\n상세: $e'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });

    if (_questionStep == 0) {
      _answer1 = text;
    } else if (_questionStep == 1) {
      _answer2 = text;
    }

    _messageController.clear();

    if (_questionStep == 0) {
      // 첫 번째 답변 후 두 번째 질문
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _messages.add(
            ChatMessage(
              text: '갈등 해결에 있어 가장 중요하게 생각하시는 요구사항이 있으신가요?',
              isUser: false,
            ),
          );
          _questionStep = 1;
        });
        _scrollToBottom();
      });
    } else if (_questionStep == 1) {
      // 두 번째 답변까지 끝 → DB 저장 호출
      _submitIssue(); // ✅ 여기서 DB 등록 + issueNo 세팅
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleAnalyze() {
    if (_issueNo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이슈 번호를 찾을 수 없습니다. 다시 시도해주세요.')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/request-analysis',
      arguments: {'issueNo': _issueNo}, // ✅ issueNo 전달
    );
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
          '갈등상황 입력',
          style: AppTextStyles.heading.copyWith(fontSize: 21),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(24),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _buildChatBubble(message);
                },
              ),
            ),
            if (_questionStep == 2) _buildAnalyzeButton(),
            if (_questionStep < 2) _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 268),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFFF1F1F2) : AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: message.isUser
                ? const Radius.circular(12)
                : const Radius.circular(0),
            bottomRight: message.isUser
                ? const Radius.circular(0)
                : const Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: AppTextStyles.body.copyWith(
            fontSize: 16,
            height: 1.4,
            color: message.isUser ? AppColors.textPrimary : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _handleAnalyze,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                '요청 분석',
                style: AppTextStyles.button.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: const Color(0xFFC7C7C7)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message..',
                  hintStyle: AppTextStyles.body.copyWith(
                    fontSize: 16,
                    color: const Color(0xFFC7C7C7),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}