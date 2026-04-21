import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:osho/utils/constants/colors.dart';

class OLoader extends StatelessWidget {
  const OLoader({super.key, this.color, this.size = 44.0});

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _ModernSpinner(
        color: color ?? OColors.primary,
        size: size,
      ),
    );
  }
}

class _ModernSpinner extends StatefulWidget {
  final Color color;
  final double size;

  const _ModernSpinner({
    required this.color,
    required this.size,
  });

  @override
  State<_ModernSpinner> createState() => _ModernSpinnerState();
}

class _ModernSpinnerState extends State<_ModernSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Smooth 1s rotation
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _SpinnerPainter(
              color: widget.color,
              angle: _controller.value * 2 * 3.14159,
            ),
          );
        },
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final Color color;
  final double angle;

  _SpinnerPainter({required this.color, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 // Slightly thicker for visibility but still elegant
      ..strokeCap = StrokeCap.round; // Round ends for softness

    final double radius = (size.width - paint.strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Rotate the canvas
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(-center.dx, -center.dy);

    // Draw the gradient arc (the "tail")
    // We draw multiple small arcs with decreasing opacity to simulate a gradient
    // This is more performant and cleaner than a sweep gradient for a simple spinner sometimes,
    // but a SweepGradient is actually "smoother" if we want a true continuous fade.
    // Let's use a SweepGradient for the "perfect" soft look.

    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    
    final Gradient gradient = SweepGradient(
      startAngle: 0.0,
      endAngle: 3.14159 * 1.5, // 270 degrees arc
      colors: [
        color.withOpacity(0.0), // Transparent tail
        color.withOpacity(0.1),
        color.withOpacity(0.5),
        color, // Solid head
      ],
      stops: const [0.0, 0.2, 0.7, 1.0],
    );

    paint.shader = gradient.createShader(rect);

    // Draw an arc that isn't a full circle
    canvas.drawArc(rect, 0.0, 3.14159 * 1.5, false, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpinnerPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.color != color;
  }
}

class OLoaders {
  static void warningSnackBar({required String title, String? message}) {
    Get.snackbar(
      title,
      message ?? '',
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: Colors.orange,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      icon: const Icon(Icons.warning, color: Colors.white),
    );
  }

  static void successSnackBar({required String title, String? message, int duration = 3}) {
    Get.snackbar(
      title,
      message ?? '',
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: OColors.primary,
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: duration),
      margin: const EdgeInsets.all(10),
      icon: const Icon(Icons.check, color: Colors.white),
    );
  }

  static void errorSnackBar({required String title, String? message}) {
    Get.snackbar(
      title,
      message ?? '',
      isDismissible: true,
      shouldIconPulse: true,
      colorText: Colors.white,
      backgroundColor: Colors.red.shade600,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      icon: const Icon(Icons.warning, color: Colors.white),
    );
  }
}