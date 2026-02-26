import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:twizzle/widgets/space_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = [
    const _OnboardPage(
      icon: Icons.chat_bubble_outline,
      title: 'Follow your interests.',
      body: 'See what people are talking about right now.',
    ),
    const _OnboardPage(
      icon: Icons.people_alt_outlined,
      title: 'Hear the buzz.',
      body: 'Join the conversation around topics you care about.',
    ),
    const _OnboardPage(
      icon: Icons.search,
      title: 'Join Twizzle.',
      body: 'Talk with people from around the globe.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SpaceBackground(),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _finish,
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, i) => _pages[i],
                  ),
                ),

                const SizedBox(height: 24),

                // Premium Page Indicator
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _pages.length,
                  effect: WormEffect(
                    dotHeight: 8,
                    dotWidth: 8,
                    activeDotColor: const Color(0xff1da1f2),
                    dotColor: Colors.white.withOpacity(0.2),
                  ),
                ).animate().fadeIn(delay: 800.ms),

                const SizedBox(height: 48),

                // PAGE-AWARE BUTTON ROW
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      if (_currentPage != _pages.length - 1)
                        TextButton(
                          onPressed: () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic),
                          child: const Text(
                            'Next',
                            style: TextStyle(
                                color: Color(0xff1da1f2), 
                                fontSize: 18, 
                                fontWeight: FontWeight.bold),
                          ),
                        ).animate().fadeIn(),
                      const Spacer(),
                      if (_currentPage == _pages.length - 1)
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1da1f2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              elevation: 0,
                            ),
                            onPressed: _finish,
                            child: const Text(
                              'Get Started',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9))
                      else
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                          onPressed: () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic),
                        ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
                    ],
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _finish() {
    Navigator.pushReplacementNamed(context, '/login');
  }
}

class _OnboardPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xff1da1f2).withOpacity(0.2),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 100,
                    color: const Color(0xff1da1f2),
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(duration: 2.seconds, begin: const Offset(0.9, 0.9))
                    .shimmer(duration: 4.seconds),
                ),
                const SizedBox(height: 40),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                const SizedBox(height: 16),
                Text(
                  body,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18, 
                    color: Colors.white.withOpacity(0.7),
                    height: 1.4,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }
}
