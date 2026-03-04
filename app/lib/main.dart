import 'package:flutter/material.dart';
import 'features/intro/screens/intro_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/signup_success_screen.dart';
import 'features/auth/screens/find_id_screen.dart';
import 'features/auth/screens/find_password_screen.dart';
import 'features/auth/screens/terms_screen.dart';
import 'features/user/screens/home_screen.dart';
import 'features/user/screens/mypage_screen.dart';
import 'features/user/screens/negotiations_progress_screen.dart';
import 'features/user/screens/negotiations_history_screen.dart';
import 'features/user/screens/find_negotiator_screen.dart';
import 'features/negotiation/screens/conflict_input_screen.dart';
import 'features/negotiation/screens/requirement_input_screen.dart';
import 'features/negotiation/screens/request_analysis_screen.dart';
import 'features/negotiation/screens/send_request_screen.dart';
import 'features/negotiation/screens/request_complete_screen.dart';
import 'features/negotiation/screens/premium_plan_screen.dart';
import 'features/negotiation/screens/negotiation_detail_screen.dart';
import 'features/negotiation/screens/negotiation_result_screen.dart';
import 'features/negotiation/screens/mediation_sent_screen.dart';
import 'features/negotiation/screens/opponent_response_screen.dart';
import 'features/negotiation/screens/mediation_options_screen.dart';
import 'features/negotiation/screens/mediation_send_screen.dart';
import 'features/negotiation/screens/opponent_message_view_screen.dart';
import 'features/negotiation/screens/opponent_opinion_submit_screen.dart';
import 'features/negotiation/screens/opponent_final_proposal_screen.dart';
import 'features/negotiation/screens/opponent_opinion_complete_screen.dart';
import 'features/negotiation/screens/opponent_negotiation_success_screen.dart';
import 'features/negotiation/screens/opponent_negotiation_failed_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GentleTalk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'NanumSquare'),
      initialRoute: '/intro',
      routes: {
        '/intro': (context) => const IntroScreen(),
        '/': (context) => const OnboardingScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/auth': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/signup-success': (context) => const SignupSuccessScreen(),
        '/find-id': (context) => const FindIdScreen(),
        '/find-password': (context) => const FindPasswordScreen(),
        '/terms': (context) => const TermsScreen(),
        '/home': (context) => const HomeScreen(),
        '/mypage': (context) => const MyPageScreen(),
        '/negotiations-progress': (context) => const NegotiationsProgressScreen(),
        '/negotiations-history': (context) => const NegotiationsHistoryScreen(),
        '/find-negotiator': (context) => const FindNegotiatorScreen(),
        '/conflict-input': (context) => const ConflictInputScreen(),
        '/requirement-input': (context) => const RequirementInputScreen(),
        '/request-analysis': (context) => const RequestAnalysisScreen(),
        '/send-request': (context) => const SendRequestScreen(),
        '/request-complete': (context) => const RequestCompleteScreen(),
        '/premium-plan': (context) => const PremiumPlanScreen(),
        '/negotiation-detail': (context) => const NegotiationDetailScreen(),
        '/negotiation-result': (context) => const NegotiationResultScreen(),
        '/mediation-sent': (context) => const MediationSentScreen(),
        '/opponent-response': (context) => const OpponentResponseScreen(),
        '/mediation-options': (context) => const MediationOptionsScreen(),
        '/mediation-send': (context) => const MediationSendScreen(),
        '/opponent-message-view': (context) => const OpponentMessageViewScreen(),
        '/opponent-opinion-submit': (context) => const OpponentOpinionSubmitScreen(),
        '/opponent-final-proposal': (context) => const OpponentFinalProposalScreen(),
        '/opponent-opinion-complete': (context) => const OpponentOpinionCompleteScreen(),
        '/opponent-negotiation-success': (context) => const OpponentNegotiationSuccessScreen(),
        '/opponent-negotiation-failed': (context) => const OpponentNegotiationFailedScreen(),
        '/opponent-failed': (context) => const OpponentNegotiationFailedScreen(),
      },
    );
  }
}
