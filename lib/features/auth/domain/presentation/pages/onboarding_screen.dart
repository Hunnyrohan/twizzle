import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
      icon:  Icon(Icons.chat_bubble_outline, size: 90, color: Color(0xff1da1f2)),
      title: 'Follow your interests.',
      body:  'See what people are talking about right now.',
    ),
    const _OnboardPage(
      icon:  Icon(Icons.people_alt_outlined, size: 90, color: Color(0xff1da1f2)),
      title: 'Hear what people are talking about.',
      body:  'Join the conversation around topics you care about.',
    ),
    const _OnboardPage(
      icon:  Icon(Icons.search, size: 90, color: Color(0xff1da1f2)),
      title: 'Join the conversation.',
      body:  'Talk with people from around the globe.',
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text(
                  'Skip',
                  style: TextStyle(color: Color(0xff1da1f2), fontSize: 16),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => SizedBox(
                  width: double.infinity,
                  child: _pages[i],
                ),
              ),
            ),

            SmoothPageIndicator(
              controller: _pageController,
              count: _pages.length,
              effect: const WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Color(0xff1da1f2),
                dotColor: Color(0xffd1d9e6),
              ),
            ),

            const SizedBox(height: 24),

            // PAGE-AWARE BUTTON ROW
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  if (_currentPage != _pages.length - 1)
                    TextButton(
                      onPressed: () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                            color: Color(0xff1da1f2), fontSize: 16),
                      ),
                    ),
                  const Spacer(),
                  if (_currentPage == _pages.length - 1)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1da1f2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        minimumSize: const Size(100, 46),
                        elevation: 0,
                      ),
                      onPressed: _finish,
                      child: const Text(
                        'Get started',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _finish() {
    Navigator.pushReplacementNamed(context, '/login');
  }
}

class _OnboardPage extends StatelessWidget {
  final Widget icon;
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
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}