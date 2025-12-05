import 'package:flutter/material.dart';
import 'package:raktosewa/widgets/onboarding_controls.dart'
    show OnboardingControls;
import 'package:raktosewa/widgets/onboarding_page_widget.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'RaktoSewa',
      'subtitle': 'Donate Blood',
      'image': 'assets/images/onboard_bg_remove.png',
    },
    {
      'title': 'RaktoSewa',
      'subtitle': 'Save Lives',
      'image': 'assets/images/onboard_bg_remove.png',
    },
    {
      'title': 'RaktoSewa',
      'subtitle': ' Get Connect to Community',
      'image': 'assets/images/onboard_bg_remove.png',
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _goToLogin();
    }
  }

  void _skip() => _goToLogin();

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEF3340),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(
                    title: _pages[index]['title']!,
                    subtitle: _pages[index]['subtitle']!,
                    image: _pages[index]['image']!,
                  );
                },
              ),
            ),
            OnboardingControls(
              currentPage: _currentPage,
              totalPages: _pages.length,
              onNext: _nextPage,
              onSkip: _skip,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
