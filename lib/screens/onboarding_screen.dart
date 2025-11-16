import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/models/onboarding_model.dart';
import 'package:fuel_tracker_app/screens/main_navigation_screen.dart';
import 'package:fuel_tracker_app/theme/app_theme.dart';
import 'package:fuel_tracker_app/utils/app_localizations.dart';

final List<OnboardingModel> _onboardingPages = [
  OnboardingModel(
    titleKey: TranslationKeys.onboardingsTitle1,
    descKey: TranslationKeys.onboardingsDesc1,
    icon: Icons.trending_up,
  ),
  OnboardingModel(
    titleKey: TranslationKeys.onboardingsTitle2,
    descKey: TranslationKeys.onboardingsDesc2,
    icon: Icons.directions_car,
  ),
  OnboardingModel(
    titleKey: TranslationKeys.onboardingsTitle3,
    descKey: TranslationKeys.onboardingsDesc3,
    icon: Icons.receipt,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = _onboardingPages.length;

  void _navigateToHomeScreen(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => const MainNavigationScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _navigateToHomeScreen(context),
                child: Text(
                  context.tr(TranslationKeys.onboardingsButtonSkip),
                  style: TextStyle(color: AppTheme.primaryFuelColor),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _numPages,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (_, index) {
                  return OnboardingPageContent(
                    data: _onboardingPages[index],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_numPages, (index) => _buildPageIndicator(index)),
            ),
            const SizedBox(height: 20),
            _buildActionButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: (index == _currentPage) ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: (index == _currentPage) ? AppTheme.primaryFuelColor : Colors.grey.shade600,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            if (_currentPage == _numPages - 1) {
              _navigateToHomeScreen(context);
            } else {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeIn,
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryFuelColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            _currentPage == _numPages - 1
                ? context.tr(TranslationKeys.onboardingsButtonStart)
                : context.tr(TranslationKeys.onboardingsButtonNext),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class OnboardingPageContent extends StatelessWidget {
  final OnboardingModel data;
  const OnboardingPageContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, size: 150.0, color: AppTheme.primaryFuelColor),
          const SizedBox(height: 30.0),
          Text(
            context.tr(data.titleKey),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28.0, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 15.0),
          Text(
            context.tr(data.descKey),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
