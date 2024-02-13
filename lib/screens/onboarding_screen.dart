import 'package:cropsync/main.dart';
import 'package:cropsync/utils/user_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:watch_it/watch_it.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final numPages = 3;
  final pageController = PageController(initialPage: 0);
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final userPrefsBox = Hive.box('userPrefs');

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.1, 0.4, 0.7, 0.9],
              colors: [
                Color(0xFF0C4B2C),
                Color(0xFF0E6B3B),
                Color(0xFF0E8241),
                Color(0xFF169447),
                // Color(0xFF30B149),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.only(right: 16),
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      pageController.jumpToPage(numPages - 1);
                    },
                    child: Text(
                      currentPage != numPages - 1 ? 'Skip' : '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.7,
                  child: PageView(
                    physics: const ClampingScrollPhysics(),
                    controller: pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        currentPage = page;
                      });
                    },
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40, left: 40.0, right: 40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Lottie.asset(
                                'assets/lottie/onboarding1.json',
                                height: 300,
                                width: 300,
                              ),
                            ),
                            const Gap(30),
                            const Text(
                              'Plant Life Made Easier',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(15),
                            const Text(
                              'Are you ready to take your farming to the next level?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Lottie.asset(
                                'assets/lottie/onboarding2.json',
                                height: 300,
                                width: 300,
                              ),
                            ),
                            const Gap(30),
                            const Text(
                              'A New Way to Farm',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Gap(15),
                            const Text(
                              'Get the best out of your farm with our next generation methods',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      showSelectTheme(userPrefsBox),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: buildPagesIndicator(),
                ),
                const Spacer(),
                if (currentPage != numPages - 1)
                  Align(
                    alignment: FractionalOffset.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                          Gap(10),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
      bottomSheet: currentPage == numPages - 1
          ? SizedBox(
              height: 100,
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  userPrefsBox.put('showOnboarding', false);
                  Navigator.of(context).pushReplacementNamed('/welcome');
                },
                child: const Center(
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      color: Color(0xFF0E8241),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ).animate().fade()
          : null,
    );
  }

  Widget showSelectTheme(userPrefsBox) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Get Started',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(15),
          const Text(
            'Choose your theme and start farming',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          const Gap(30),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    // userPrefsBox.put(
                    //   'darkModeEnabled',
                    //   false,
                    // );
                    di<UserPrefs>().darkModeEnabled = false;
                    setState(() {
                      MyApp.themeNotifier.value = ThemeMode.light;
                    });
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.light_mode_rounded,
                          size: 100,
                          color: Colors.black,
                        ),
                        const Gap(10),
                        const Text(
                          'Light Mode',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: MyApp.themeNotifier.value == ThemeMode.dark
                              ? 0
                              : 50,
                          width: MyApp.themeNotifier.value == ThemeMode.dark
                              ? 0
                              : 50,
                          margin: MyApp.themeNotifier.value == ThemeMode.dark
                              ? const EdgeInsets.only(top: 0)
                              : const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF006B49),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(10),
              Expanded(
                child: InkWell(
                  onTap: () {
                    // userPrefsBox.put(
                    //   'darkModeEnabled',
                    //   true,
                    // );
                    di<UserPrefs>().darkModeEnabled = true;
                    setState(() {
                      MyApp.themeNotifier.value = ThemeMode.dark;
                    });
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1C1B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.dark_mode_outlined,
                          size: 100,
                          color: Colors.white,
                        ),
                        const Gap(10),
                        const Text(
                          'Dark Mode',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: MyApp.themeNotifier.value == ThemeMode.light
                              ? 0
                              : 50,
                          width: MyApp.themeNotifier.value == ThemeMode.light
                              ? 0
                              : 50,
                          margin: MyApp.themeNotifier.value == ThemeMode.light
                              ? const EdgeInsets.only(top: 0)
                              : const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF23342C),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  List<Widget> buildPagesIndicator() {
    final List<Widget> list = [];
    for (int i = 0; i < numPages; i++) {
      list.add(i == currentPage ? indicator(true) : indicator(false));
    }
    return list;
  }

  Widget indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: 8,
      width: isActive ? 24 : 16,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white54,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}
