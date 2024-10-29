import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Routes/AppRoutes.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _drawAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)),
    );

    _drawAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeInOut)),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.offNamed(AppRoutes.SIGNINSCREEN);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomPaint(
                    painter: DrawingTextPainter(
                      text: 'PRO-TECH',
                      progress: _drawAnimation.value,
                    ),
                    size: Size(MediaQuery.of(context).size.width, 100),
                  ),
                  const SizedBox(height: 20),
                  Opacity(
                    opacity: _textOpacityAnimation.value,
                    child: const Text(
                      'YOUR HEART, YOUR LIFE',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.teal,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class DrawingTextPainter extends CustomPainter {
  final String text;
  final double progress;

  DrawingTextPainter({required this.text, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const textStyle = TextStyle(
      color: Colors.deepOrangeAccent,
      fontSize: 60,
      fontWeight: FontWeight.bold,
      letterSpacing: 3.0,
    );
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    final totalLength = textPainter.width;
    final drawLength = totalLength * progress;

    // Adjust text to make sure it doesn't split into multiple lines
    final dx = (size.width - totalLength) / 2;
    final dy = (size.height - textPainter.height) / 2;
    
    canvas.saveLayer(Offset.zero & size, Paint());
    textPainter.paint(canvas, Offset(dx, dy));

    if (progress < 1.0) {
      final paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.srcOut;

      canvas.drawRect(
        Rect.fromLTRB(dx + drawLength, dy, dx + totalLength, dy + textPainter.height),
        paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant DrawingTextPainter oldDelegate) =>
    oldDelegate.text != text || oldDelegate.progress != progress;
}