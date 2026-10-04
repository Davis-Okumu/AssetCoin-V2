
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../widgets/introduction_slide.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({super.key});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'image': 'assets/images/onboarding/tokenize.png',
      'title': 'Tokenize Your Assets',
      'description':
          'Unlock the value of eligible real-world assets by transforming them into digital tokens.',
    },
    {
      'image': 'assets/images/onboarding/discover.png',
      'title': 'Discover Opportunities',
      'description':
          'Explore tokenized assets and discover opportunities available through the AssetCoin marketplace.',
    },
    {
      'image': 'assets/images/onboarding/trade.png',
      'title': 'Trade Securely',
      'description':
          'Buy, sell and manage your token holdings through a secure digital marketplace.',
    },
    {
      'image': 'assets/images/onboarding/track.png',
      'title': 'Track Everything',
      'description':
          'Keep track of your assets, wallet, transactions and token holdings in one place.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishIntroduction();
    }
  }

  void _skipIntroduction() {
    _finishIntroduction();
  }

  void _finishIntroduction() {
    context.go(RouteNames.register);
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // SKIP BUTTON
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _skipIntroduction,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Color(0xFF68736D),
                  ),
                ),
              ),
            ),

            // INTRODUCTION SLIDES
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];

                  return IntroductionSlide(
                    imageAsset: slide['image']!,
                    title: slide['title']!,
                    description: slide['description']!,
                  );
                },
              ),
            ),

            // PAGE INDICATORS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) {
                  final selected = index == _currentPage;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: selected ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF0B5D3B)
                          : const Color(0xFFD5DDD8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // CONTINUE / GET STARTED BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(
                    isLastPage ? 'Get Started' : 'Continue',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // EXISTING USER LOGIN
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(
                    color: Color(0xFF68736D),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.go(RouteNames.login);
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Color(0xFF0B5D3B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}