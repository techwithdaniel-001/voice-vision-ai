import 'package:flutter/material.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart' as stream_video;

import 'ai_demo_controller.dart';
import 'ai_speaking_view.dart';
import 'settings_page.dart';
import 'visual_assistance_view.dart';

class HomePage extends StatelessWidget {
  const HomePage(this.controller, {super.key});

  final AiDemoController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LensX'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SizedBox.expand(
        child: LayoutBuilder(
          builder:
              (context, constraints) => ListenableBuilder(
                listenable: controller,
                builder:
                    (context, _) => switch (controller.callState) {
                      AICallState.idle => GestureDetector(
                        onTap: controller.joinCall,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // LensX Logo
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurple.withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/images/lensx.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Welcome to LensX',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Your compassionate AI companion',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 32),
                              Container(
                                padding: const EdgeInsets.all(20),
                                margin: const EdgeInsets.symmetric(horizontal: 40),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
                                ),
                                child: const Column(
                                  children: [
                                    Text(
                                      'I\'m here to help you with:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      '• Emotional support & companionship\n• Navigation & spatial awareness\n• Daily tasks & organization\n• Accessibility & independence\n• Social & communication support',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurple.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Tap to start talking with Lexi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AICallState.joining => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // LensX Logo with pulse animation
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 1500),
                              tween: Tween(begin: 0.8, end: 1.2),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.deepPurple.withOpacity(0.4),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      'assets/images/lensx.png',
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                                                          const Text(
                                'Lexi is connecting...',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            const SizedBox(height: 8),
                            const Text(
                              'Preparing your AI companion',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AICallState.active => Stack(
                        children: [
                          // Show camera view or normal view based on camera state
                          controller.isCameraActive
                              ? VisualAssistanceView(
                                  call: controller.call!,
                                  cameraService: controller.cameraService,
                                  isFullScreen: true,
                                )
                              : AiSpeakingView(
                                  controller.call!,
                                  boxConstraints: constraints,
                                ),
                          // Camera Toggle Button
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FloatingActionButton(
                                  heroTag: 'camera_toggle',
                                  onPressed: controller.toggleCamera,
                                  backgroundColor: controller.isCameraActive 
                                      ? Colors.red 
                                      : Colors.deepPurple,
                                  child: Icon(
                                    controller.isCameraActive 
                                        ? Icons.camera_alt 
                                        : Icons.camera_alt_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Leave Call Button
                          Align(
                            alignment: Alignment.bottomRight,
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: stream_video.LeaveCallOption(
                                  call: controller.call!,
                                  onLeaveCallTap: controller.leaveCall,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    },
              ),
        ),
      ),
    );
  }
}
