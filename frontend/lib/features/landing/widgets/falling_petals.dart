import 'dart:math';
import 'package:flutter/material.dart';

class FallingPetals extends StatefulWidget {
  const FallingPetals({super.key, this.count = 18});
  final int count;

  @override
  State<FallingPetals> createState() => _FallingPetalsState();
}

class _FallingPetalsState extends State<FallingPetals>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Petal> _petals;
  final _rng = Random(42);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _petals = List.generate(
      widget.count,
      (i) => _Petal(
        x: _rng.nextDouble(),
        size: 8 + _rng.nextDouble() * 14,
        speed: 0.3 + _rng.nextDouble() * 0.7,
        sway: _rng.nextDouble() * 0.15,
        startAt: _rng.nextDouble(),
        rotateSpeed: 1 + _rng.nextDouble() * 3,
        hue: _rng.nextDouble(),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return CustomPaint(
            painter: _PetalPainter(_petals, _ctrl.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Petal {
  _Petal({
    required this.x,
    required this.size,
    required this.speed,
    required this.sway,
    required this.startAt,
    required this.rotateSpeed,
    required this.hue,
  });
  final double x;
  final double size;
  final double speed;
  final double sway;
  final double startAt;
  final double rotateSpeed;
  final double hue;
}

class _PetalPainter extends CustomPainter {
  _PetalPainter(this.petals, this.t);
  final List<_Petal> petals;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in petals) {
      final progress = (t * p.speed + p.startAt) % 1.0;
      final dy = -size.height * 0.1 + progress * (size.height + size.height * 0.2);
      final dx = p.x * size.width + sin(progress * 6.28 + p.startAt * 6) * size.width * p.sway;
      final angle = progress * p.rotateSpeed * 6.28;
      final color = Color.lerp(
        const Color(0xFFFFC2D1),
        const Color(0xFFE55A7E),
        p.hue,
      )!.withOpacity(0.65);
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(angle);
      final paint = Paint()..color = color;
      final path = Path()
        ..moveTo(0, -p.size / 2)
        ..quadraticBezierTo(p.size, 0, 0, p.size / 2)
        ..quadraticBezierTo(-p.size, 0, 0, -p.size / 2)
        ..close();
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _PetalPainter old) => true;
}
