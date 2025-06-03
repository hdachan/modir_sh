import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../Auth/views/AgreePage.dart';
import '../Auth/views/LoginSelectionScreen.dart';
import '../Auth/views/SignUppage.dart';
import '../MapScreen.dart';
import '../Mypage/views/Mypage.dart';
import '../Mypage/views/SettingScreen.dart';
import '../Mypage/views/WithdrawalScreen.dart';
import '../Mypage/views/termsScreen.dart';
import '../feed/views/FeedDetailScreen.dart';
import '../feed/views/LikedFeedScreen.dart';
import '../feed/views/WriteFeedScreen.dart';
import '../feed/views/Screen2.dart'; // Screen2 임포트 추가
import '../utils/SessionManager.dart';
import 'AuthCheck.dart';
import 'bottom_nav.dart';

final GoRouter router = GoRouter(
  initialLocation: '/auth_check',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/auth_check',
      builder: (context, state) => const AuthCheckScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginSelectionScreen(),
      routes: [
        GoRoute(
          path: 'agree',
          builder: (context, state) => const AgreePage(),
          routes: [
            GoRoute(
              path: 'signup',
              builder: (context, state) => const SignUpPage(),
            ),
          ],
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) => BottomNavScreen(child: child),
      routes: [
        GoRoute(
          path: '/map',
          builder: (context, state) => const FeedScreen(),
        ),
        GoRoute(
          path: '/community',
          builder: (context, state) => const FeedScreen(),
          routes: [
            GoRoute(
              path: 'detail/:feedId',
              builder: (context, state) {
                final feedId = state.pathParameters['feedId']!;
                return FeedDetailScreen(feedId: feedId);
              },
            ),
            GoRoute(
              path: 'write',
              builder: (context, state) => const WriteFeedScreen(),
              routes: [
                GoRoute(
                  path: 'settings2',
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>?;
                    return Screen2(
                      title: extra?['title'],
                      content: extra?['content'],
                      imageBytes: extra?['imageBytes'],
                      categoryItems: extra?['categoryItems'] ?? [],
                      welcomeItems: extra?['welcomeItems'] ?? [],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/mypage',
          builder: (context, state) => MyPageScreen(),
          routes: [
            GoRoute(
              path: 'setting',
              builder: (context, state) => SettingScreen(),
              routes: [
                GoRoute(
                  path: 'withdrawal_reason',
                  pageBuilder: (context, state) => MaterialPage(child: WithdrawalScreen()),
                ),
                GoRoute(
                  path: 'terms',
                  pageBuilder: (context, state) => MaterialPage(child: termsScreen()),
                ),
              ],
            ),
            GoRoute(
              path: 'LikedFeed',
              pageBuilder: (context, state) => MaterialPage(child: LikedFeedScreen()),
            ),
          ],
        ),
      ],
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) async {
    final path = state.uri.toString();
    if (path == '/auth_check') {
      return null;
    }

    final sessionManager = SessionManager();
    final isAuthenticated = await sessionManager.isAuthenticated();

    final protectedPrefixes = ['/map', '/community', '/mypage'];
    final isProtected = protectedPrefixes.any((prefix) => path == prefix || path.startsWith('$prefix/'));

    if (!isAuthenticated && isProtected) {
      return '/login';
    }

    if (isAuthenticated && (path == '/login' || path.startsWith('/login/'))) {
      return '/community';
    }

    return null;
  },
);