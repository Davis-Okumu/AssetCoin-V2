import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/splash_page.dart';
import '../../features/introduction/presentation/introduction_page.dart';

import '../../features/authentication/presentation/controllers/auth_controller.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/reset_password_page.dart';
import '../../features/assets/presentation/pages/asset_details_page.dart';
import '../../features/assets/presentation/pages/my_submitted_assets_page.dart';
import '../../features/assets/presentation/pages/submission_details_page.dart';
import '../../features/assets/presentation/pages/submit_asset_page.dart';

import '../network/api_test_page.dart';
import '../../features/main/presentation/pages/main_shell.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: RouteNames.splash,

    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final currentPath = state.uri.path;

      final isSplashRoute = currentPath == RouteNames.splash;

      final isPublicRoute = [
        RouteNames.splash,
        RouteNames.introduction,
        RouteNames.login,
        RouteNames.register,
        RouteNames.forgotPassword,
        RouteNames.resetPassword,
        '/api-test',
      ].contains(currentPath);

      // --------------------------------------------------
      // AUTHENTICATION STATE IS STILL BEING RESTORED
      // --------------------------------------------------

      if (authState.isLoading) {
        /*
         * Keep the splash screen visible while the saved
         * authentication session is being restored.
         *
         * Do not redirect public authentication pages while
         * an explicit login/register request is in progress.
         */
        if (isSplashRoute) {
          return null;
        }

        return isPublicRoute ? null : RouteNames.splash;
      }

      // --------------------------------------------------
      // DETERMINE AUTHENTICATION STATUS
      // --------------------------------------------------

      final isAuthenticated = authState.when(
        data: (user) => user != null,
        loading: () => false,
        error: (_, _) => false,
      );

      // --------------------------------------------------
      // SESSION RESTORATION ERROR
      // --------------------------------------------------

      if (authState.hasError) {
        /*
         * If restoring the session failed because of a temporary
         * server/network problem, the AuthController preserves
         * the stored token.
         *
         * We do not force the user into an authentication loop.
         *
         * Public routes remain accessible.
         */
        if (!isPublicRoute) {
          return RouteNames.login;
        }

        return null;
      }

      // --------------------------------------------------
      // SPLASH ROUTE
      // --------------------------------------------------

      if (isSplashRoute) {
        /*
         * Session restoration has completed.
         *
         * Authenticated → Home
         * No authenticated user → Introduction
         */
        return isAuthenticated
            ? RouteNames.home
            : RouteNames.introduction;
      }

      // --------------------------------------------------
      // AUTHENTICATED USERS
      // --------------------------------------------------

      if (isAuthenticated) {
        /*
         * Authenticated users should not return to the
         * introduction or authentication pages.
         */
        if (currentPath == RouteNames.introduction ||
            currentPath == RouteNames.login ||
            currentPath == RouteNames.register) {
          return RouteNames.home;
        }

        return null;
      }

      // --------------------------------------------------
      // UNAUTHENTICATED USERS
      // --------------------------------------------------

      /*
       * Protect every route that is not explicitly public.
       */
      if (!isAuthenticated && !isPublicRoute) {
        return RouteNames.login;
      }

      return null;
    },

    routes: [
      // --------------------------------------------------
      // SPLASH
      // --------------------------------------------------

      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // --------------------------------------------------
      // INTRODUCTION
      // --------------------------------------------------

      GoRoute(
        path: RouteNames.introduction,
        name: 'introduction',
        builder: (context, state) => const IntroductionPage(),
      ),

      // --------------------------------------------------
      // LOGIN
      // --------------------------------------------------

      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // --------------------------------------------------
      // REGISTER
      // --------------------------------------------------

      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // --------------------------------------------------
      // HOME
      // --------------------------------------------------

      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const MainShell(),
      ),

      // --------------------------------------------------
      // ASSET DETAILS
      // --------------------------------------------------

      GoRoute(
        path: RouteNames.assetDetails,
        name: 'asset-details',
        builder: (context, state) {
          final assetId = int.tryParse(
            state.pathParameters['id'] ?? '',
          );

          if (assetId == null || assetId <= 0) {
            return const Scaffold(
              body: Center(
                child: Text('Invalid asset identifier.'),
              ),
            );
          }

          return AssetDetailsPage(assetId: assetId);
        },
      ),
        GoRoute(
          path: RouteNames.mySubmissions,
          name: 'my-submissions',
          builder: (context, state) {
          return const MySubmittedAssetsPage();
          },
        ),

        GoRoute(
          path: RouteNames.submitAsset,
          name: 'submit-asset',
          builder: (context, state) => const SubmitAssetPage(),
        ),

        GoRoute(
          path: RouteNames.submissionDetails,
          name: 'submission-details',
          builder: (context, state) {
          final assetId = int.tryParse(
         state.pathParameters['id'] ?? '',
        );

    if (assetId == null || assetId <= 0) {
      return const Scaffold(
        body: Center(
          child: Text('Invalid submission identifier.'),
        ),
      );
    }

    return SubmissionDetailsPage(assetId: assetId);
  },
),

      // --------------------------------------------------
      // FORGOT PASSWORD
      // --------------------------------------------------

      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // --------------------------------------------------
      // RESET PASSWORD
      // --------------------------------------------------

      GoRoute(
        path: RouteNames.resetPassword,
        name: 'reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];

          if (token == null || token.isEmpty) {
            return const Scaffold(
              body: Center(
                child: Text(
                  'Invalid or missing password reset token.',
                ),
              ),
            );
          }

          return ResetPasswordPage(token: token);
        },
      ),

      // --------------------------------------------------
      // TEMPORARY BACKEND CONNECTION TEST
      // --------------------------------------------------

      GoRoute(
        path: '/api-test',
        name: 'api-test',
        builder: (context, state) => const ApiTestPage(),
      ),
    ],
  );

  // --------------------------------------------------
  // REFRESH ROUTER WHEN AUTH STATE CHANGES
  // --------------------------------------------------

  ref.listen(
    authControllerProvider,
    (previous, next) {
      router.refresh();
    },
  );

  ref.onDispose(router.dispose);

  return router;
});