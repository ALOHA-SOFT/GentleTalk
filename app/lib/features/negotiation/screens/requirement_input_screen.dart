import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class RequirementInputScreen extends StatefulWidget {
  const RequirementInputScreen({super.key});

  @override
  State<RequirementInputScreen> createState() => _RequirementInputScreenState();
}

class _RequirementInputScreenState extends State<RequirementInputScreen> {
  final List<ChatMessage> _messages = [
    ChatMessage(text: '현재 겪고 있는 갈등상황에 대해 구체적으로 말씀해 주시겠어요?', isUser: false),
    ChatMessage(
      text:
          '최근 교통사고 후 상대 보험사와 합의금을 두고 의견이 엇갈리고 있습니다. 치료비와 후유증 보상 범위에 대한 이견으로 협상이 지연되고 있습니다.',
      isUser: true,
    ),
    ChatMessage(text: '갈등 해결에 있어 가장 중요하게 생각하시는 요구사항이 있으신가요?', isUser: false),
  ];

  bool _hasUserResponse = false;

  void _handleAnalyze() {
    Navigator.pushNamed(context, '/request-analysis');
  }

  void _showUserResponse() {
    setState(() {
      _hasUserResponse = true;
    });
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
          '요구조건 입력',
          style: AppTextStyles.heading.copyWith(fontSize: 21),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 345),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Chat messages
                    ..._messages.map((msg) => _buildChatBubble(msg)),
                    // User response (appears after interaction)
                    if (_hasUserResponse)
                      _buildChatBubble(
                        ChatMessage(
                          text:
                              '상대방의 입장도 고려하되, 제 피해에 대한 정당한 보상과 신속한 합의를 이루는 것이 가장 중요하다고 생각합니다.',
                          isUser: true,
                        ),
                      ),
                    const SizedBox(height: 30),
                    // Analyze button
                    if (_hasUserResponse)
                      _buildPrimaryButton('요청 분석', _handleAnalyze)
                    else
                      _buildPrimaryButton('답변 입력', _showUserResponse),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
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

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
              text,
              style: AppTextStyles.button.copyWith(color: AppColors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
