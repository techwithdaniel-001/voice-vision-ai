import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ai_demo_controller.dart';
import 'home_page.dart';

void main() {
  final aiController = AiDemoController();
  runApp(LensXApp(aiController));
}

class LensXApp extends StatelessWidget {
  const LensXApp(this.aiDemoController, {super.key});

  final AiDemoController aiDemoController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LensX - AI Companion for Blind Users',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: LensXSplashScreen(aiDemoController),
    );
  }
}

class LensXSplashScreen extends StatefulWidget {
  const LensXSplashScreen(this.aiDemoController, {super.key});

  final AiDemoController aiDemoController;

  @override
  State<LensXSplashScreen> createState() => _LensXSplashScreenState();
}

class _LensXSplashScreenState extends State<LensXSplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // Provide haptic feedback for accessibility
    HapticFeedback.lightImpact();
    
    Future.delayed(const Duration(seconds: 3), () {
      // Provide haptic feedback when transitioning
      HapticFeedback.mediumImpact();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage(widget.aiDemoController)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated logo
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1500),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                                          child: Semantics(
                        label: 'LensX Logo - AI Assistant for Blind Users',
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/lensx.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // Animated title
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: const Text(
                      'LensX',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Animated subtitle
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 15 * (1 - value)),
                    child: const Text(
                      'Your Personal Guide & Emotional Assistant',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            // Animated tagline
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 10 * (1 - value)),
                    child: const Text(
                      'Powered by AI & Stream Video',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            // Loading indicator
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
