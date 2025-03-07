import 'package:flutter/material.dart';
import 'dart:async';

class WaveAnimation extends StatefulWidget {
  @override
  _WaveAnimationState createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Widget> waves = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    // Generar nuevas ondas cada cierto tiempo
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          waves.add(_buildWave());
          if (waves.length > 5) {
            waves.removeAt(0);
          }
        });
      }
    });
  }

  Widget _buildWave() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: WavePainter(_animation.value),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: waves);
  }
}

class WavePainter extends CustomPainter {
  final double progress;

  WavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(1 - progress)
      ..style = PaintingStyle.fill;

    final center = size.center(Offset.zero);
    final radius = size.width * progress;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}
