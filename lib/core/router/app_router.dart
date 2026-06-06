import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_ai/core/widgets/main_shell.dart';
import 'package:finance_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:finance_ai/features/auth/presentation/screens/signup_screen.dart';
import 'package:finance_ai/features/home/presentation/screens/home_screen.dart';
import 'package:finance_ai/features/upi/presentation/screens/upi_screen.dart';
import 'package:finance_ai/features/portfolio/presentation/screens/portfolio_screen.dart';
import 'package:finance_ai/features/add/presentation/screens/add_screen.dart';
import 'package:finance_ai/features/insights/presentation/screens/insights_screen.dart';
import 'package:finance_ai/features/profile/presentation/screens/profile_screen.dart';
import 'package:finance_ai/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:finance_ai/features/scanner/presentation/screens/scanner_screen.dart';
import 'package:finance_ai/features/portfolio/presentation/screens/add_portfolio_item_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorUpiKey = GlobalKey<NavigatorState>(debugLabel: 'shellUpi');
final _shellNavigatorPortfolioKey = GlobalKey<NavigatorState>(debugLabel: 'shellPortfolio');
final _shellNavigatorInsightsKey = GlobalKey<NavigatorState>(debugLabel: 'shellInsights');
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

final appRouter = GoRouter(
  initialLocation: '/login',
  navigatorKey: _rootNavigatorKey,
  routes: [
    // ─── Auth Routes (no bottom nav) ─────────────────────────
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ),
    GoRoute(
      path: '/signup',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const SignupScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    ),

    // ─── Main Shell (with bottom nav) ────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorUpiKey,
          routes: [
            GoRoute(
              path: '/upi',
              builder: (context, state) => const UpiScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorPortfolioKey,
          routes: [
            GoRoute(
              path: '/portfolio',
              builder: (context, state) => const PortfolioScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorInsightsKey,
          routes: [
            GoRoute(
              path: '/insights',
              builder: (context, state) => const InsightsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProfileKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // ─── Overlay Routes (over bottom nav) ────────────────────
    GoRoute(
      path: '/add',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const AddScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/scanner',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const ScannerScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/edit-profile',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const EditProfileScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/portfolio/add',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          child: const AddPortfolioItemScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        );
      },
    ),
  ],
);
