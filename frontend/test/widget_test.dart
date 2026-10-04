import 'package:flutter_test/flutter_test.dart';
import 'package:assetcoin/app.dart';

void main() {
  testWidgets(
    'AssetCoin navigates from splash to introduction',
    (WidgetTester tester) async {
      await tester.pumpWidget(const AssetCoinApp());

      // Initial splash screen.
      await tester.pump();

      expect(find.text('AssetCoin'), findsOneWidget);

      // Complete the 2-second splash delay.
      await tester.pump(const Duration(seconds: 2));

      // Allow navigation to complete.
      await tester.pump();

      expect(
        find.text('Tokenize Your Assets'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Skip from introduction navigates to login',
    (WidgetTester tester) async {
      await tester.pumpWidget(const AssetCoinApp());

      // Complete splash.
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      // We should now be on the introduction page.
      expect(
        find.text('Tokenize Your Assets'),
        findsOneWidget,
      );

      // Tap Skip.
      await tester.tap(find.text('Skip'));
      await tester.pump();

      // Login placeholder should now be displayed.
      expect(
        find.text('Login Page'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Continue moves through introduction slides',
    (WidgetTester tester) async {
      await tester.pumpWidget(const AssetCoinApp());

      // Complete splash.
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      // Slide 1.
      expect(
        find.text('Tokenize Your Assets'),
        findsOneWidget,
      );

      // Continue → Slide 2.
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(
        find.text('Discover Opportunities'),
        findsOneWidget,
      );

      // Continue → Slide 3.
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(
        find.text('Trade Securely'),
        findsOneWidget,
      );

      // Continue → Slide 4.
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(
        find.text('Track Everything'),
        findsOneWidget,
      );

      // Last slide should show Get Started.
      expect(
        find.text('Get Started'),
        findsOneWidget,
      );

      // Get Started → Login.
      await tester.tap(find.text('Get Started'));
      await tester.pump();

      expect(
        find.text('Login Page'),
        findsOneWidget,
      );
    },
  );
}