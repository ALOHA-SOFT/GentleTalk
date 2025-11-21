# GentleTalk - 온보딩 섹션 구현 완료

## 구현된 기능

### 1. 온보딩 화면
피그마 디자인을 기반으로 4개의 온보딩 화면을 구현했습니다:

1. **화면 1**: "갈등이 생겼을 때, 어떻게 해결하고 있나요?"
2. **화면 2**: "당신의 입장과 상대방의 입장을 AI가 함께 읽습니다."
3. **화면 3**: "대화에서 합의까지, 한 번에."
4. **화면 4**: "전문가의 손길이 필요한 순간"

### 2. 주요 기능
- 페이지 스와이프 네비게이션
- 페이지 인디케이터 (smooth_page_indicator)
- "바로 시작하기" 버튼 (그라디언트 버튼)
- "다음으로" 버튼 (아웃라인 버튼)
- 피그마 디자인의 색상, 폰트, 레이아웃 적용

### 3. 프로젝트 구조
```
lib/
├── core/
│   ├── constants/
│   │   ├── colors.dart          # 앱 전체 색상 정의
│   │   └── text_styles.dart     # 텍스트 스타일 정의
│   └── models/
│       └── onboarding_content.dart  # 온보딩 콘텐츠 모델
├── features/
│   └── onboarding/
│       ├── screens/
│       │   └── onboarding_screen.dart   # 온보딩 메인 화면
│       └── widgets/
│           └── onboarding_page.dart     # 개별 온보딩 페이지
└── main.dart
```

### 4. 필요한 추가 작업

#### 폰트 파일 추가
NanumSquare 폰트 파일을 다운로드하여 다음 경로에 추가해주세요:
```
assets/fonts/
├── NanumSquare_acR.ttf      # Regular (400)
├── NanumSquare_acB.ttf      # Bold (700)
└── NanumSquare_acEB.ttf     # Extra Bold (800)
```

폰트 다운로드: https://hangeul.naver.com/font

## 실행 방법

```bash
# 의존성 설치 (이미 완료됨)
flutter pub get

# 앱 실행
flutter run
```

## 다음 단계
온보딩 섹션이 완료되었습니다. 다음은 인증 섹션 구현을 진행하면 됩니다.
