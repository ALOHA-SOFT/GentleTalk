import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep; // 1-based
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final items = List.generate(totalSteps, (i) => i + 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.map((step) {
        final isActive = step == currentStep;
        final isDone = step < currentStep;

        Color bg;
        Color fg;

        if (isActive) {
          bg = const Color(0xFF1F63FF);
          fg = Colors.white;
        } else if (isDone) {
          bg = const Color(0xFF00ADB5);
          fg = Colors.white;
        } else {
          bg = const Color(0xFFE6E8EE);
          fg = const Color(0xFF7A7F8C);
        }

        return Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(
                '$step',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ),
            if (step != totalSteps)
              Container(
                width: 18,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: const Color(0xFFD8DBE3),
              ),
          ],
        );
      }).toList(),
    );
  }
}