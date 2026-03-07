import 'package:app/core/widgets/step_indicator.dart';
import 'package:flutter/material.dart';

class FormalNoticePreviewScreen extends StatelessWidget {
  final Map<String, dynamic> previewData;
  final Map<String, dynamic> requestPayload;

  const FormalNoticePreviewScreen({
    super.key,
    required this.previewData,
    required this.requestPayload,
  });

  @override
  Widget build(BuildContext context) {
    final previewText =
        (previewData['previewText'] ??
                previewData['preview_text'] ??
                previewData['content'] ??
                '')
            .toString();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
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
                  const Expanded(
                    child: Text(
                      '내용 증명 미리보기',
                      style: TextStyle(
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

              const StepIndicator(currentStep: 4, totalSteps: 5),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF00A6B2),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const Text(
                  '생성된 내용 증명을 확인해주세요.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 14),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE9EAEC)),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      previewText.isNotEmpty
                          ? previewText
                          : '생성된 내용 증명 미리보기가 없습니다.',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.7,
                        color: Color(0xFF2B2E3A),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
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
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/formal-notice-ways',
                          arguments: {
                            'no': previewData['no'],
                            'previewData': previewData,
                            'requestPayload': requestPayload,
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: const Center(
                        child: Text(
                          '발송하기',
                          style: TextStyle(
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
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE9EAEC)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    '수정하기',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2B2E3A),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
