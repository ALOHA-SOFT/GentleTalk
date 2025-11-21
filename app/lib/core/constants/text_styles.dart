import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  static const String fontFamily = 'NanumSquare';

  static const TextStyle heading = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 24, // 28에서 24로 축소
    height: 1.4,
    letterSpacing: 0.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 14, // 16에서 14로 축소
    height: 1.4,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 16,
    height: 1.105,
    color: AppColors.white,
  );

  // 반응형 텍스트 스타일을 위한 헬퍼 메서드
  static TextStyle responsiveHeading(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = size.height < 700 ? 22.0 : 24.0;
    return heading.copyWith(fontSize: fontSize);
  }

  static TextStyle responsiveBody(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = size.height < 700 ? 13.0 : 14.0;
    return body.copyWith(fontSize: fontSize);
  }
}
