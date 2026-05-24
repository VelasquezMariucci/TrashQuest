import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final String nextRoute;
  const SplashScreen({super.key, this.nextRoute = '/login'});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _step = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (!mounted) return;
      setState(() {
        _step++;
      });
      if (_step >= 3) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) context.go(widget.nextRoute);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: _buildAnimationStep(),
            ),
            const SizedBox(height: 50),
            const Text(
              'Faunia Eco',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'El plástico destruye su hogar.\nAyúdanos a reciclar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationStep() {
    if (_step == 0) {
      // Paso 0: Tortuga feliz + Basura cayendo
      return Row(
        key: const ValueKey(0),
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('🐢', style: TextStyle(fontSize: 80)),
          SizedBox(width: 30),
          Text('🥤', style: TextStyle(fontSize: 50)),
        ],
      );
    } else if (_step == 1) {
      // Paso 1: Tortuga se come la basura
      return Row(
        key: const ValueKey(1),
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('🐢', style: TextStyle(fontSize: 80)),
          Text('🥤', style: TextStyle(fontSize: 30)),
        ],
      );
    } else if (_step == 2) {
      // Paso 2: Tortuga enferma
      return const Text('🐢🤢', key: ValueKey(2), style: TextStyle(fontSize: 80));
    } else {
      // Paso 3: Consecuencia fatal
      return const Text('☠️', key: ValueKey(3), style: TextStyle(fontSize: 100));
    }
  }
}
