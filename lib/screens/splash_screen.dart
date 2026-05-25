import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  final String nextRoute;

  const SplashScreen({super.key, this.nextRoute = '/login'});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final VideoPlayerController _videoController;
  Timer? _navigationTimer;

  static const String _videoPath = 'assets/trashquest_loading_animation_cropped.mp4';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _startNavigationTimer();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset(_videoPath);

    await _videoController.initialize();

    if (!mounted) return;

    setState(() {});

    _videoController
      ..setLooping(true)
      ..setVolume(0)
      ..play();
  }

  void _startNavigationTimer() {
    _navigationTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        context.go(widget.nextRoute);
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color lightGreenBackground = Color(0xFFE8F5E9);

    return Scaffold(
      backgroundColor: lightGreenBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: primaryGreen.withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 380),
                      color: Colors.white,
                      child: _videoController.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: _videoController.value.aspectRatio,
                              child: VideoPlayer(_videoController),
                            )
                          : const SizedBox(
                              width: 380,
                              height: 214,
                              child: Center(
                                child: Text(
                                  'TrashQuest',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: primaryGreen,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 34),

                const Text(
                  'Faunia Eco',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'Ellos también viven aquí.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B5E20),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Cada residuo que reciclas ayuda a proteger el hogar de los animales.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5F6F61),
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: primaryGreen.withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                  child: const Text(
                    'Recicla. Gana puntos. Protege Faunia.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: primaryGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
