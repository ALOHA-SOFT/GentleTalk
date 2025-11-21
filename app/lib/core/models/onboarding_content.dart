class OnboardingContent {
  final String image;
  final String title;
  final String description;

  const OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });

  static List<OnboardingContent> contents = [
    const OnboardingContent(
      image: 'assets/images/onboarding1-48f2b5.png',
      title: '갈등이 생겼을 때,\n어떻게 해결하고 있나요?',
      description:
          '감정에 휘둘리기보다, 논리적으로 조율해보세요.\nAI가 당신의 요구를 분석하고 가장 합리적인 방향을 찾아드립니다.',
    ),
    const OnboardingContent(
      image: 'assets/images/onboarding2-2bf694.png',
      title: '당신의 입장과 상대방의 입장을\nAI가 함께 읽습니다.',
      description: '각자의 조건과 입장을 입력하면,\nAI가 공정한 중재안을 제시하고 협상의 밸런스를 맞춥니다.',
    ),
    const OnboardingContent(
      image: 'assets/images/onboarding3-48f2b5.png',
      title: '대화에서 합의까지, 한 번에.',
      description:
          'AI가 제시한 중재안으로 협상을 진행하세요.\n필요하다면 전문 협상가의 도움을 받아\n프리미엄 중재까지 연결할 수 있습니다.',
    ),
    const OnboardingContent(
      image: 'assets/images/onboarding4-158a82.png',
      title: '전문가의 손길이 필요한 순간',
      description: '분쟁이 복잡하거나 감정이 얽혔다면,\n실제 협상 전문가의 프리미엄 중재 서비스를 이용해보세요.',
    ),
  ];
}
